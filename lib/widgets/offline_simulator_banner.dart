import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../services/hybrid_inference_engine.dart';
import '../services/offline_sync_service.dart';

class OfflineSimulatorBanner extends StatelessWidget {
  const OfflineSimulatorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<HybridInferenceEngine>();
    final syncService = context.watch<OfflineSyncService>();
    final isOffline = engine.simulateOffline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isOffline ? AppColors.offlineBg : AppColors.emeraldBg,
        border: Border(
          bottom: BorderSide(
            color: isOffline ? AppColors.offlineBorder : const Color(0xFFA7F3D0),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
            size: 18,
            color: isOffline ? AppColors.offlineText : AppColors.emeraldGreen,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  isOffline ? 'SIMULATED OFFLINE MODE ACTIVE' : 'LIVE ONLINE NETWORK',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isOffline ? AppColors.offlineText : AppColors.emeraldGreen,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                ),
                Text(
                  isOffline
                      ? '• Gemini Nano 4 running local 0ms queries | Cloud synthesis queued'
                      : '• Hybrid routing: Local NPU primary (Cobalt) + Cloud Flash fallback (Vermilion)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isOffline ? AppColors.offlineText : const Color(0xFF065F46),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (syncService.hasPending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.internationalOrangeMuted,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.internationalOrange, width: 1),
                    ),
                    child: Text(
                      '${syncService.pendingCount} Tasks Queued',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.internationalOrange,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Simulate Offline',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: isOffline,
                onChanged: (val) => engine.toggleOfflineSimulation(val),
                activeThumbColor: AppColors.offlineBorder,
                activeTrackColor: AppColors.offlineBg,
                inactiveThumbColor: AppColors.textSecondary,
                inactiveTrackColor: AppColors.borderMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
