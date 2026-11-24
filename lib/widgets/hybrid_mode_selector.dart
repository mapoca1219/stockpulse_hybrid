import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/inference_mode.dart';
import '../services/hybrid_inference_engine.dart';

class HybridModeSelector extends StatelessWidget {
  const HybridModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<HybridInferenceEngine>();
    final currentMode = engine.mode;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14111827),
            blurRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment(
            context,
            mode: InferenceMode.auto,
            label: 'Auto (Nano 4)',
            icon: Icons.auto_awesome_rounded,
            isSelected: currentMode == InferenceMode.auto,
            activeColor: AppColors.border,
            activeTextColor: Colors.white,
            onTap: () => engine.setMode(InferenceMode.auto),
          ),
          const SizedBox(width: 4),
          _buildSegment(
            context,
            mode: InferenceMode.forceOnDevice,
            label: 'Force Edge',
            icon: Icons.memory_rounded,
            isSelected: currentMode == InferenceMode.forceOnDevice,
            activeColor: AppColors.cobaltBlue,
            activeTextColor: Colors.white,
            onTap: () => engine.setMode(InferenceMode.forceOnDevice),
          ),
          const SizedBox(width: 4),
          _buildSegment(
            context,
            mode: InferenceMode.forceCloud,
            label: 'Force Cloud',
            icon: Icons.cloud_outlined,
            isSelected: currentMode == InferenceMode.forceCloud,
            activeColor: AppColors.internationalOrange,
            activeTextColor: Colors.white,
            onTap: () => engine.setMode(InferenceMode.forceCloud),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(
    BuildContext context, {
    required InferenceMode mode,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required Color activeTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? activeTextColor : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected ? activeTextColor : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
