import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool hasGlow;
  final Gradient? borderGradient;
  final VoidCallback? onTap;

  const BentoCard({
    super.key,
    required this.child,
    this.padding,
    this.hasGlow = false,
    this.borderGradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasGlow ? AppColors.cobaltBlue : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          const BoxShadow(
            color: Color(0x14111827),
            blurRadius: 0,
            offset: Offset(0, 3),
          ),
          if (hasGlow)
            BoxShadow(
              color: AppColors.cobaltBlue.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(18),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: card,
      );
    }
    return card;
  }
}
