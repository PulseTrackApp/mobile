import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/features/tracking/models/tracking_point.dart';
import 'package:mobile_flutter/features/tracking/models/tracking_session_draft.dart';

void main() {
  test('conserve les points GPS meme si la seance a ete mise en pause', () {
    final startedAt = DateTime.utc(2026, 8, 11, 16);
    final draft = TrackingSessionDraft(
      startedAt: startedAt,
      endedAt: startedAt.add(const Duration(minutes: 45)),
      elapsed: const Duration(minutes: 30),
      distanceMeters: 5000,
      elevationGainMeters: 10,
      hasPause: true,
      points: [
        TrackingPoint(
          latitude: 12.371,
          longitude: -1.52,
          recordedAt: startedAt,
        ),
        TrackingPoint(
          latitude: 12.372,
          longitude: -1.521,
          recordedAt: startedAt.add(const Duration(minutes: 30)),
        ),
      ],
    );

    expect(draft.canUploadGpsTrack, isTrue);
    expect(draft.apiGpsPoints, hasLength(2));
    expect(draft.apiEndedAt, startedAt.add(const Duration(minutes: 30)));
  });
}
