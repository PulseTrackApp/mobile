import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/tracking_point.dart';
import '../models/tracking_session_draft.dart';
import '../models/tracking_state.dart';

class TrackingController extends ChangeNotifier {
  TrackingController();

  static const _fallbackLocationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
  );
  static final _androidLocationSettings = AndroidSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
    intervalDuration: const Duration(seconds: 2),
    useMSLAltitude: true,
    foregroundNotificationConfig: const ForegroundNotificationConfig(
      notificationTitle: 'GymFlow suit ta seance',
      notificationText:
          'Tracking GPS actif pour mesurer distance, allure et denivele.',
      notificationChannelName: 'Tracking sportif GymFlow',
      notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
      enableWakeLock: true,
      setOngoing: true,
      color: Color(0xFF00A676),
    ),
  );
  static final _androidCurrentPositionSettings = AndroidSettings(
    accuracy: LocationAccuracy.high,
    intervalDuration: const Duration(seconds: 1),
    timeLimit: const Duration(seconds: 12),
  );
  static const _maxAcceptedAccuracyMeters = 80.0;
  static const _minAcceptedSegmentMeters = 2.0;
  static const _maxAcceptedSpeedMps = 25.0;
  static const _minElevationDeltaMeters = 3.0;

  final _distance = const Distance();

  TrackingState _state = TrackingState.idle();
  Timer? _timer;
  StreamSubscription<Position>? _positionSubscription;
  DateTime? _startedAt;
  DateTime? _pauseStartedAt;
  Duration _pausedDuration = Duration.zero;
  TrackingPoint? _lastPoint;
  bool _hasPause = false;

  TrackingState get state => _state;

  Future<void> start() async {
    if (_state.status != TrackingStatus.idle) return;

    _state = TrackingState.idle().copyWith(status: TrackingStatus.locating);
    notifyListeners();

    try {
      await _ensureLocationReady();
    } catch (_) {
      _state = TrackingState.idle();
      notifyListeners();
      rethrow;
    }

    _startedAt = DateTime.now().toUtc();
    _pauseStartedAt = null;
    _pausedDuration = Duration.zero;
    _lastPoint = null;
    _hasPause = false;
    _state = TrackingState.idle().copyWith(status: TrackingStatus.running);
    notifyListeners();

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _currentPositionSettings,
      );
      _recordPosition(position);
    } catch (_) {
      // Le flux continu peut encore fournir une position apres le demarrage.
    }

    _startTimer();
    _startPositionStream();
  }

  void pause() {
    if (_state.status != TrackingStatus.running) return;

    _hasPause = true;
    _pauseStartedAt = DateTime.now().toUtc();
    _timer?.cancel();
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _lastPoint = null;
    _state = _state.copyWith(status: TrackingStatus.paused, currentSpeedMps: 0);
    notifyListeners();
  }

  Future<void> resume() async {
    if (_state.status != TrackingStatus.paused) return;

    await _ensureLocationReady();
    final pauseStartedAt = _pauseStartedAt;
    if (pauseStartedAt != null) {
      _pausedDuration += DateTime.now().toUtc().difference(pauseStartedAt);
      _pauseStartedAt = null;
    }
    _lastPoint = null;
    _state = _state.copyWith(status: TrackingStatus.running);
    notifyListeners();
    _startTimer();
    _startPositionStream();
  }

  TrackingSessionDraft finish() {
    final endedAt = DateTime.now().toUtc();
    final pauseStartedAt = _pauseStartedAt;
    if (pauseStartedAt != null) {
      _pausedDuration += endedAt.difference(pauseStartedAt);
    }
    final startedAt = _startedAt ?? endedAt.subtract(_state.elapsed);
    final draft = TrackingSessionDraft(
      startedAt: startedAt,
      endedAt: endedAt,
      elapsed: _state.elapsed,
      distanceMeters: _state.distanceMeters,
      elevationGainMeters: _state.elevationGainMeters,
      points: List.unmodifiable(_state.points),
      hasPause: _hasPause,
    );

    _timer?.cancel();
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _startedAt = null;
    _pauseStartedAt = null;
    _pausedDuration = Duration.zero;
    _lastPoint = null;
    _hasPause = false;
    _state = TrackingState.idle();
    notifyListeners();
    return draft;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _ensureLocationReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const TrackingException(TrackingIssue.locationDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const TrackingException(TrackingIssue.permissionDenied);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _state = _state.copyWith(
        elapsed: _state.elapsed + const Duration(seconds: 1),
      );
      notifyListeners();
    });
  }

  void _startPositionStream() {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: _streamLocationSettings,
    ).listen(_recordPosition);
  }

  void _recordPosition(Position position) {
    if (_state.status != TrackingStatus.running) return;
    if (position.accuracy > _maxAcceptedAccuracyMeters &&
        _state.points.isNotEmpty) {
      return;
    }

    final rawPoint = TrackingPoint.fromPosition(position);
    final point = rawPoint.copyWith(
      recordedAt: rawPoint.recordedAt.subtract(_pausedDuration),
    );
    final points = [..._state.points, point];
    var distanceMeters = _state.distanceMeters;
    var elevationGainMeters = _state.elevationGainMeters;
    var currentSpeedMps = point.speed ?? 0;

    final previous = _lastPoint;
    if (previous != null) {
      final segmentMeters = _distance(previous.latLng, point.latLng);
      final segmentSeconds = point.recordedAt
          .difference(previous.recordedAt)
          .inSeconds;
      final segmentSpeedMps = segmentSeconds > 0
          ? segmentMeters / segmentSeconds
          : 0.0;

      if (segmentMeters >= _minAcceptedSegmentMeters &&
          segmentSpeedMps <= _maxAcceptedSpeedMps) {
        distanceMeters += segmentMeters;
        if (currentSpeedMps <= 0) currentSpeedMps = segmentSpeedMps;
      }

      final previousAltitude = previous.altitude;
      final currentAltitude = point.altitude;
      if (previousAltitude != null && currentAltitude != null) {
        final climb = currentAltitude - previousAltitude;
        if (climb >= _minElevationDeltaMeters) {
          elevationGainMeters += climb;
        }
      }
    }

    _lastPoint = point;
    _state = _state.copyWith(
      points: List.unmodifiable(points),
      distanceMeters: distanceMeters,
      elevationGainMeters: elevationGainMeters,
      currentSpeedMps: currentSpeedMps,
    );
    notifyListeners();
  }
}

LocationSettings get _streamLocationSettings {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return TrackingController._androidLocationSettings;
  }
  return TrackingController._fallbackLocationSettings;
}

LocationSettings get _currentPositionSettings {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return TrackingController._androidCurrentPositionSettings;
  }
  return const LocationSettings(
    accuracy: LocationAccuracy.high,
    timeLimit: Duration(seconds: 12),
  );
}

enum TrackingIssue { locationDisabled, permissionDenied }

class TrackingException implements Exception {
  const TrackingException(this.issue);

  final TrackingIssue issue;
}
