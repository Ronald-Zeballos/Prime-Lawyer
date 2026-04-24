import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class PrimeLawyerLogo extends StatelessWidget {
  const PrimeLawyerLogo({
    super.key,
    this.height = 36,
    this.showWordmark = true,
    this.textColor = AppTheme.primaryNavy,
    this.iconColor = AppTheme.accentGold,
  });

  final double height;
  final bool showWordmark;
  final Color textColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final iconWidth = height * 0.7;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: iconWidth,
          height: height,
          child: CustomPaint(
            painter: _PrimeShieldPainter(color: iconColor),
          ),
        ),
        if (showWordmark) ...[
          SizedBox(width: height * 0.34),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRIME',
                style: TextStyle(
                  color: textColor,
                  fontSize: height * 0.42,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                  height: 0.95,
                  fontFamilyFallback: const [
                    'Georgia',
                    'Times New Roman',
                    'Noto Serif',
                  ],
                ),
              ),
              SizedBox(height: height * 0.04),
              Text(
                'LAWYER',
                style: TextStyle(
                  color: textColor,
                  fontSize: height * 0.22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: height * 0.07,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _PrimeShieldPainter extends CustomPainter {
  const _PrimeShieldPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final shield = Path()
      ..moveTo(size.width * 0.18, size.height * 0.14)
      ..quadraticBezierTo(
        size.width * 0.20,
        size.height * 0.04,
        size.width * 0.50,
        size.height * 0.06,
      )
      ..quadraticBezierTo(
        size.width * 0.80,
        size.height * 0.04,
        size.width * 0.82,
        size.height * 0.14,
      )
      ..lineTo(size.width * 0.82, size.height * 0.48)
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.76,
        size.width * 0.50,
        size.height * 0.94,
      )
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.76,
        size.width * 0.18,
        size.height * 0.48,
      )
      ..close();

    canvas.drawPath(shield, stroke);

    final centerX = size.width * 0.50;
    final mastTop = size.height * 0.26;
    final mastBottom = size.height * 0.70;
    final armY = size.height * 0.34;
    final leftAnchor = size.width * 0.33;
    final rightAnchor = size.width * 0.67;
    final bowlY = size.height * 0.53;

    canvas.drawLine(
      Offset(centerX, mastTop),
      Offset(centerX, mastBottom),
      fill,
    );
    canvas.drawLine(
      Offset(size.width * 0.30, armY),
      Offset(size.width * 0.70, armY),
      fill,
    );
    canvas.drawLine(
      Offset(leftAnchor, armY),
      Offset(size.width * 0.29, bowlY - 2),
      fill,
    );
    canvas.drawLine(
      Offset(rightAnchor, armY),
      Offset(size.width * 0.71, bowlY - 2),
      fill,
    );

    final leftBowl = Path()
      ..moveTo(size.width * 0.18, bowlY)
      ..quadraticBezierTo(
        size.width * 0.29,
        size.height * 0.66,
        size.width * 0.40,
        bowlY,
      );
    final rightBowl = Path()
      ..moveTo(size.width * 0.60, bowlY)
      ..quadraticBezierTo(
        size.width * 0.71,
        size.height * 0.66,
        size.width * 0.82,
        bowlY,
      );

    canvas.drawPath(leftBowl, fill);
    canvas.drawPath(rightBowl, fill);
    canvas.drawCircle(
      Offset(centerX, mastTop),
      size.width * 0.03,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _PrimeShieldPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
