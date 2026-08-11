import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PulseTrackLogo extends StatelessWidget {
  const PulseTrackLogo({super.key, this.size = 48, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final icon = SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomPaint(painter: _PulseTrackLogoPainter()),
      ),
    );

    if (!showWordmark) {
      return icon;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 10),
        Text('GymFlow', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _PulseTrackLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = size.width * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final pulsePaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = size.width * 0.072
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final route = Path()
      ..moveTo(size.width * 0.18, size.height * 0.66)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.32,
        size.width * 0.50,
        size.height * 0.30,
        size.width * 0.58,
        size.height * 0.54,
      )
      ..cubicTo(
        size.width * 0.65,
        size.height * 0.74,
        size.width * 0.78,
        size.height * 0.74,
        size.width * 0.86,
        size.height * 0.42,
      );

    final pulse = Path()
      ..moveTo(size.width * 0.25, size.height * 0.58)
      ..lineTo(size.width * 0.38, size.height * 0.58)
      ..lineTo(size.width * 0.45, size.height * 0.43)
      ..lineTo(size.width * 0.53, size.height * 0.70)
      ..lineTo(size.width * 0.61, size.height * 0.52)
      ..lineTo(size.width * 0.75, size.height * 0.52);

    canvas.drawPath(route, routePaint);
    canvas.drawPath(pulse, pulsePaint);

    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.66),
      size.width * 0.07,
      Paint()..color = AppColors.gps,
    );
    canvas.drawCircle(
      Offset(size.width * 0.86, size.height * 0.42),
      size.width * 0.07,
      Paint()..color = AppColors.danger,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
