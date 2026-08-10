import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/app_panel.dart';
import '../../../core/ui/pulse_track_logo.dart';

class MapPreview extends StatelessWidget {
  const MapPreview({super.key, this.label, this.isLive = false});

  final String? label;
  final bool isLive;

  static const _sampleRoute = [
    LatLng(48.85825, 2.29455),
    LatLng(48.85895, 2.29620),
    LatLng(48.86010, 2.29710),
    LatLng(48.86115, 2.29585),
    LatLng(48.86185, 2.29370),
  ];

  @override
  Widget build(BuildContext context) {
    final attributionColor = Theme.of(
      context,
    ).colorScheme.surface.withValues(alpha: 0.9);

    return AppPanel(
      padding: EdgeInsets.zero,
      child: AspectRatio(
        aspectRatio: 1.25,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(48.86020, 2.29525),
              initialZoom: 15.5,
              interactionOptions: InteractionOptions(
                flags:
                    InteractiveFlag.drag |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.perso.sportmvp.mobile_flutter',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _sampleRoute,
                    strokeWidth: 6,
                    color: AppColors.primary,
                    borderStrokeWidth: 2,
                    borderColor: Colors.white,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _sampleRoute.first,
                    width: 34,
                    height: 34,
                    child: const _RouteMarker(color: AppColors.gps),
                  ),
                  Marker(
                    point: _sampleRoute.last,
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
              if (label != null)
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _MapBadge(label: label!, isLive: isLive),
                  ),
                ),
              const Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: PulseTrackLogo(size: 34, showWordmark: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
