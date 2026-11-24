import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class StockPulseLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showBadge;
  final String? subtitle;

  const StockPulseLogo({
    super.key,
    this.size = 32,
    this.showText = true,
    this.showBadge = true,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Custom Isometric Cube Icon
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: StockPulseCubePainter(),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'STOCKPULSE',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: size * 0.52,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.8,
                    ),
                  ),
                  if (showBadge) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'HYBRID AI',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class StockPulseCubePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(size.width, size.height) * 0.46;

    // Isometric angles: 30 degrees
    const angle30 = math.pi / 6;
    final cos30 = math.cos(angle30);
    final sin30 = math.sin(angle30);

    // Cube vertices
    final v0 = Offset(cx, cy); // Center
    final vTop = Offset(cx, cy - r);
    final vTopRight = Offset(cx + r * cos30, cy - r * sin30);
    final vBottomRight = Offset(cx + r * cos30, cy + r * sin30);
    final vBottom = Offset(cx, cy + r);
    final vBottomLeft = Offset(cx - r * cos30, cy + r * sin30);
    final vTopLeft = Offset(cx - r * cos30, cy - r * sin30);

    // Paints
    final leftFacePaint = Paint()
      ..color = AppColors.cobaltBlue
      ..style = PaintingStyle.fill;

    final rightFacePaint = Paint()
      ..color = AppColors.internationalOrange
      ..style = PaintingStyle.fill;

    // Top face split into royal blue and deep vermilion
    final topLeftFacePaint = Paint()
      ..color = const Color(0xFF1D4ED8)
      ..style = PaintingStyle.fill;

    final topRightFacePaint = Paint()
      ..color = const Color(0xFFEA580C)
      ..style = PaintingStyle.fill;

    final edgePaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 1. Draw Top Left & Top Right Face
    final topLeftPath = Path()
      ..moveTo(v0.dx, v0.dy)
      ..lineTo(vTopLeft.dx, vTopLeft.dy)
      ..lineTo(vTop.dx, vTop.dy)
      ..close();
    canvas.drawPath(topLeftPath, topLeftFacePaint);

    final topRightPath = Path()
      ..moveTo(v0.dx, v0.dy)
      ..lineTo(vTop.dx, vTop.dy)
      ..lineTo(vTopRight.dx, vTopRight.dy)
      ..close();
    canvas.drawPath(topRightPath, topRightFacePaint);

    // 2. Draw Left Face (Cobalt Blue: Edge / Local Nano)
    final leftPath = Path()
      ..moveTo(v0.dx, v0.dy)
      ..lineTo(vTopLeft.dx, vTopLeft.dy)
      ..lineTo(vBottomLeft.dx, vBottomLeft.dy)
      ..lineTo(vBottom.dx, vBottom.dy)
      ..close();
    canvas.drawPath(leftPath, leftFacePaint);

    // 3. Draw Right Face (International Orange: Cloud AI Logic)
    final rightPath = Path()
      ..moveTo(v0.dx, v0.dy)
      ..lineTo(vBottom.dx, vBottom.dy)
      ..lineTo(vBottomRight.dx, vBottomRight.dy)
      ..lineTo(vTopRight.dx, vTopRight.dy)
      ..close();
    canvas.drawPath(rightPath, rightFacePaint);

    // 4. Draw Cube Outline Edges
    final outerCubePath = Path()
      ..moveTo(vTop.dx, vTop.dy)
      ..lineTo(vTopRight.dx, vTopRight.dy)
      ..lineTo(vBottomRight.dx, vBottomRight.dy)
      ..lineTo(vBottom.dx, vBottom.dy)
      ..lineTo(vBottomLeft.dx, vBottomLeft.dy)
      ..lineTo(vTopLeft.dx, vTopLeft.dy)
      ..close();
    canvas.drawPath(outerCubePath, edgePaint);

    // Inner intersecting edges
    canvas.drawLine(v0, vTop, edgePaint);
    canvas.drawLine(v0, vBottom, edgePaint);
    canvas.drawLine(v0, vTopLeft, edgePaint);
    canvas.drawLine(v0, vTopRight, edgePaint);

    // 5. White Pulse / Heartbeat Wave across the center front
    final pulsePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.8, size.width * 0.055)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pulseY = cy + r * 0.15;
    final pulsePath = Path()
      ..moveTo(cx - r * 0.75, pulseY)
      ..lineTo(cx - r * 0.35, pulseY)
      ..lineTo(cx - r * 0.12, pulseY - r * 0.42) // EKG peak
      ..lineTo(cx + r * 0.10, pulseY + r * 0.38) // EKG dip
      ..lineTo(cx + r * 0.28, pulseY)
      ..lineTo(cx + r * 0.75, pulseY);

    canvas.drawPath(pulsePath, pulsePaint);

    // Bright dots at pulse peaks
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx - r * 0.12, pulseY - r * 0.42), 1.6, dotPaint);
    canvas.drawCircle(Offset(cx + r * 0.10, pulseY + r * 0.38), 1.6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
