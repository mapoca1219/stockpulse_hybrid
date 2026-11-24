import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/inference_mode.dart';
import '../services/hybrid_inference_engine.dart';

class HybridRoutingVisualizer extends StatefulWidget {
  final bool isDualHybrid;
  final String? subtitle;

  const HybridRoutingVisualizer({
    super.key,
    this.isDualHybrid = false,
    this.subtitle,
  });

  @override
  State<HybridRoutingVisualizer> createState() => _HybridRoutingVisualizerState();
}

class _HybridRoutingVisualizerState extends State<HybridRoutingVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<HybridInferenceEngine>();
    final isLocalActive = engine.latestInferenceSource == InferenceSource.onDevice || widget.isDualHybrid;
    final isCloudActive = engine.latestInferenceSource == InferenceSource.inCloud || widget.isDualHybrid;
    final isOffline = engine.simulateOffline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14111827),
            blurRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOffline ? AppColors.offline : AppColors.cobaltBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'HYBRID INFERENCE PIPELINE',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isOffline ? AppColors.offlineBg : AppColors.cobaltBlueMuted,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isOffline ? AppColors.offlineBorder : AppColors.cobaltBlue,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isOffline
                          ? 'OFFLINE (LOCAL EXCLUSIVE)'
                          : widget.isDualHybrid
                              ? 'DUAL-STAGE ACTIVE'
                              : 'ROUTER: PREFER_ON_DEVICE',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isOffline ? AppColors.offlineText : AppColors.cobaltBlue,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '${engine.latestLatencyMs}ms Last Inference',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dynamic Pipeline Display
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 580;
              return isWide
                  ? Row(
                      children: [
                        // Left Node: On-Device
                        Expanded(
                          flex: 5,
                          child: _buildNodeCard(
                            context,
                            title: 'NPU ON-DEVICE',
                            modelName: 'Gemini Nano 4',
                            latencyText: '${engine.latestLatencyMs}ms • 0ms Network Dependency',
                            accentColor: AppColors.cobaltBlue,
                            accentBg: AppColors.cobaltBlueMuted,
                            isActive: isLocalActive,
                            icon: Icons.memory_rounded,
                            tag: 'LOCAL EDGE',
                          ),
                        ),
                        // Middle Pipeline Connector
                        Expanded(
                          flex: 4,
                          child: _buildAnimatedConnector(
                            context,
                            isOffline: isOffline,
                            isDual: widget.isDualHybrid,
                            toCloud: isCloudActive,
                          ),
                        ),
                        // Right Node: Cloud AI
                        Expanded(
                          flex: 5,
                          child: _buildNodeCard(
                            context,
                            title: 'FIREBASE AI LOGIC',
                            modelName: 'Gemini 2.5 Flash',
                            latencyText: isOffline ? 'Queued (Offline Mode)' : 'Deep Margin & Contract Synthesis',
                            accentColor: AppColors.internationalOrange,
                            accentBg: AppColors.internationalOrangeMuted,
                            isActive: isCloudActive && !isOffline,
                            icon: Icons.cloud_rounded,
                            tag: 'CLOUD AI',
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildNodeCard(
                          context,
                          title: 'NPU ON-DEVICE',
                          modelName: 'Gemini Nano 4',
                          latencyText: '${engine.latestLatencyMs}ms • 0ms Network Dependency',
                          accentColor: AppColors.cobaltBlue,
                          accentBg: AppColors.cobaltBlueMuted,
                          isActive: isLocalActive,
                          icon: Icons.memory_rounded,
                          tag: 'LOCAL EDGE',
                        ),
                        const SizedBox(height: 8),
                        _buildAnimatedConnector(
                          context,
                          isOffline: isOffline,
                          isDual: widget.isDualHybrid,
                          toCloud: isCloudActive,
                        ),
                        const SizedBox(height: 8),
                        _buildNodeCard(
                          context,
                          title: 'FIREBASE AI LOGIC',
                          modelName: 'Gemini 2.5 Flash',
                          latencyText: isOffline ? 'Queued (Offline Mode)' : 'Deep Margin & Contract Synthesis',
                          accentColor: AppColors.internationalOrange,
                          accentBg: AppColors.internationalOrangeMuted,
                          isActive: isCloudActive && !isOffline,
                          icon: Icons.cloud_rounded,
                          tag: 'CLOUD AI',
                        ),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNodeCard(
    BuildContext context, {
    required String title,
    required String modelName,
    required String latencyText,
    required Color accentColor,
    required Color accentBg,
    required bool isActive,
    required IconData icon,
    required String tag,
  }) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final pulse = isActive ? (_animController.value * 0.4) : 0.0;
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive ? accentBg : AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? accentColor : AppColors.borderMuted,
              width: isActive ? 1.8 : 1.0,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.15 + pulse * 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 14, color: isActive ? accentColor : AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isActive ? accentColor : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: isActive ? accentColor : AppColors.borderMuted,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: isActive ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                modelName,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                latencyText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedConnector(
    BuildContext context, {
    required bool isOffline,
    required bool isDual,
    required bool toCloud,
  }) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final progress = _animController.value;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOffline
                        ? Icons.link_off_rounded
                        : isDual
                            ? Icons.compare_arrows_rounded
                            : Icons.arrow_forward_rounded,
                    size: 14,
                    color: isOffline
                        ? AppColors.offline
                        : toCloud
                            ? AppColors.internationalOrange
                            : AppColors.cobaltBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOffline
                        ? 'OFFLINE'
                        : isDual
                            ? 'DUAL PIPELINE'
                            : 'EDGE-FIRST',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isOffline
                          ? AppColors.offline
                          : toCloud
                              ? AppColors.internationalOrange
                              : AppColors.cobaltBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Animated Line with Packet Dot
              SizedBox(
                height: 12,
                child: CustomPaint(
                  painter: _PipelineTrackPainter(
                    progress: progress,
                    isOffline: isOffline,
                    isMoving: toCloud && !isOffline,
                  ),
                  size: const Size(double.infinity, 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PipelineTrackPainter extends CustomPainter {
  final double progress;
  final bool isOffline;
  final bool isMoving;

  _PipelineTrackPainter({
    required this.progress,
    required this.isOffline,
    required this.isMoving,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;

    // Background Track
    final trackPaint = Paint()
      ..color = isOffline ? AppColors.offline.withValues(alpha: 0.3) : const Color(0xFFE5E7EB)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), trackPaint);

    if (isOffline) {
      // Draw cross mark
      final crossPaint = Paint()
        ..color = AppColors.offline
        ..strokeWidth = 2.0;
      canvas.drawLine(
        Offset(size.width / 2 - 4, centerY - 4),
        Offset(size.width / 2 + 4, centerY + 4),
        crossPaint,
      );
      canvas.drawLine(
        Offset(size.width / 2 - 4, centerY + 4),
        Offset(size.width / 2 + 4, centerY - 4),
        crossPaint,
      );
      return;
    }

    // Moving Data Packet Dot
    if (isMoving) {
      final packetX = size.width * progress;
      final packetPaint = Paint()
        ..color = AppColors.internationalOrange
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(packetX, centerY), 3.5, packetPaint);

      final glowPaint = Paint()
        ..color = AppColors.internationalOrange.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(packetX, centerY), 6.0, glowPaint);
    } else {
      // Local pulse stationary at left edge
      final pulsePaint = Paint()
        ..color = AppColors.cobaltBlue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(4, centerY), 3.0, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PipelineTrackPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isOffline != isOffline || oldDelegate.isMoving != isMoving;
}
