import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/pulse_track_logo.dart';
import '../../../l10n/app_localizations.dart';

class MapPreview extends StatefulWidget {
  const MapPreview({
    super.key,
    this.label,
    this.isLive = false,
    this.routePoints = const [],
    this.currentPosition,
    this.framed = true,
    this.interactive = true,
    this.showLocateButton = true,
  });

  final String? label;
  final bool isLive;
  final List<LatLng> routePoints;
  final LatLng? currentPosition;
  final bool framed;
  final bool interactive;
  final bool showLocateButton;

  @override
  State<MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<MapPreview> {
  final _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLocating = false;
  bool _autoLocationRequested = false;

  static const _burkinaCenter = LatLng(12.3714, -1.5197);

  @override
  void didUpdateWidget(covariant MapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final latestPoint =
        widget.currentPosition ?? _lastPoint(widget.routePoints);
    final previousPoint =
        oldWidget.currentPosition ?? _lastPoint(oldWidget.routePoints);
    if (latestPoint != null && latestPoint != previousPoint) {
      _currentPosition = latestPoint;
      _mapController.move(latestPoint, widget.routePoints.length > 1 ? 16 : 15);
    }

    if (widget.isLive && !_autoLocationRequested) {
      _autoLocationRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _centerOnCurrentPosition(showError: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final attributionColor = Theme.of(
      context,
    ).colorScheme.surface.withValues(alpha: 0.9);
    final routePoints = widget.routePoints;
    final hasRoute = routePoints.length >= 2;
    final currentPosition =
        widget.currentPosition ?? _lastPoint(routePoints) ?? _currentPosition;

    final map = AspectRatio(
      aspectRatio: 1.25,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: currentPosition ?? _burkinaCenter,
            initialZoom: currentPosition == null ? 13 : 15,
            interactionOptions: InteractionOptions(
              flags: widget.interactive
                  ? InteractiveFlag.drag |
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.doubleTapZoom
                  : InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.millogostudio.gymflow',
            ),
            PolylineLayer(
              polylines: [
                if (hasRoute)
                  Polyline(
                    points: routePoints,
                    strokeWidth: 6,
                    color: AppColors.primary,
                    borderStrokeWidth: 2,
                    borderColor: Colors.white,
                  ),
              ],
            ),
            if (currentPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentPosition,
                    width: 42,
                    height: 42,
                    child: const _CurrentLocationMarker(),
                  ),
                ],
              ),
            if (hasRoute)
              MarkerLayer(
                markers: [
                  Marker(
                    point: routePoints.first,
                    width: 34,
                    height: 34,
                    child: const _RouteMarker(color: AppColors.gps),
                  ),
                  Marker(
                    point: routePoints.last,
                    width: 34,
                    height: 34,
                    child: const _RouteMarker(color: AppColors.danger),
                  ),
                ],
              ),
            SimpleAttributionWidget(
              source: Text(
                'OpenStreetMap contributors',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              backgroundColor: attributionColor,
            ),
            if (widget.label != null)
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _MapBadge(label: widget.label!, isLive: widget.isLive),
                ),
              ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PulseTrackLogo(size: 34, showWordmark: false),
                    if (widget.showLocateButton) ...[
                      const SizedBox(height: 10),
                      _LocateButton(
                        tooltip: l10n.currentLocation,
                        isLoading: _isLocating,
                        onPressed: _centerOnCurrentPosition,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!widget.framed) return map;

    return AppPanel(padding: EdgeInsets.zero, child: map);
  }

  Future<void> _centerOnCurrentPosition({bool showError = true}) async {
    if (_isLocating) return;

    setState(() => _isLocating = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError(showError);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showLocationError(showError);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      if (!mounted) return;

      final point = LatLng(position.latitude, position.longitude);
      setState(() => _currentPosition = point);
      _mapController.move(point, 16);
    } catch (_) {
      _showLocationError(showError);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _showLocationError(bool showError) {
    if (!mounted || !showError) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).currentLocationUnavailable),
      ),
    );
  }
}

LatLng? _lastPoint(List<LatLng> points) {
  return points.isEmpty ? null : points.last;
}

class _MapBadge extends StatelessWidget {
  const _MapBadge({required this.label, required this.isLive});

  final String label;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isLive ? AppColors.primary : AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _RouteMarker extends StatelessWidget {
  const _RouteMarker({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _CurrentLocationMarker extends StatelessWidget {
  const _CurrentLocationMarker();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.gps.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.gps,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.dark.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocateButton extends StatelessWidget {
  const _LocateButton({
    required this.tooltip,
    required this.isLoading,
    required this.onPressed,
  });

  final String tooltip;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 3,
      child: IconButton(
        tooltip: tooltip,
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.my_location_rounded),
      ),
    );
  }
}
