import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/ai_telemetry.dart';
import '../models/inference_mode.dart';

class TelemetryBadge extends StatelessWidget {
  final AITelemetry telemetry;
  final bool compact;

  const TelemetryBadge({
    super.key,
    required this.telemetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isOnDevice = telemetry.inferenceSource == InferenceSource.onDevice;
    final accentColor = isOnDevice ? AppColors.cobaltBlue : AppColors.internationalOrange;
    final badgeBg = isOnDevice ? AppColors.cobaltBlueMuted : AppColors.internationalOrangeMuted;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: accentColor, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnDevice ? Icons.bolt_rounded : Icons.cloud_outlined,
            size: compact ? 12 : 14,
            color: accentColor,
          ),
          const SizedBox(width: 5),
          Text(
            telemetry.inferenceSource.code,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(width: 6),
          Container(width: 1, height: 10, color: accentColor.withValues(alpha: 0.4)),
          const SizedBox(width: 6),
          Text(
            '${telemetry.latencyMs}ms',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (isOnDevice && telemetry.tokensSaved > 0) ...[
            const SizedBox(width: 6),
            Container(width: 1, height: 10, color: accentColor.withValues(alpha: 0.4)),
            const SizedBox(width: 6),
            Text(
              '+${telemetry.tokensSaved} tokens saved',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.cobaltBlue,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
