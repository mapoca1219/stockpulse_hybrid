import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../services/firebase_config_service.dart';
import '../services/remote_config_service.dart';
import 'bento_card.dart';
import 'stock_pulse_logo.dart';

class JudgeInspectorModal extends StatelessWidget {
  const JudgeInspectorModal({super.key});

  @override
  Widget build(BuildContext context) {
    final fbConfig = context.watch<FirebaseConfigService>();
    final remoteConfig = context.watch<RemoteConfigService>();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const StockPulseLogo(size: 26, showText: false),
                      const SizedBox(width: 10),
                      Text(
                        'Judge & Architecture Inspector',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Live verification console for Firebase AI Logic, App Check, and Remote Config parameters.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Firebase Services Status Bento
              BentoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Firebase Integration Telemetry', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    _buildStatusRow(context, 'App Check Status', fbConfig.isAppCheckActive ? 'ACTIVE (WebDebugProvider / AndroidDebugProvider)' : 'INACTIVE', AppColors.emeraldGreen),
                    _buildStatusRow(context, 'Debug Token', fbConfig.appCheckDebugToken ?? 'AE40B6BC-940A-4EE5-9F98-15879A6A7C86', AppColors.cobaltBlue),
                    _buildStatusRow(
                      context,
                      'Authentication',
                      fbConfig.isLiveCloudAuth
                          ? 'Live Cloud Session (${fbConfig.userId})'
                          : fbConfig.isAnonymousAuth
                              ? 'Judge Sandbox Session (${fbConfig.userId})'
                              : 'Authenticated (${fbConfig.userEmail})',
                      AppColors.cobaltBlue,
                    ),
                    _buildStatusRow(context, 'Firestore Persistence', 'ENABLED (Unlimited offline cache)', AppColors.emeraldGreen),
                    _buildStatusRow(context, 'AI Logic Provider', 'Gemini Developer API (Hybrid Nano 4 / 2.5 Flash)', AppColors.internationalOrange),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Remote Config Interactive Sliders
              BentoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Remote Config Dynamic Controls', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(
                      'Tweak the on-device routing threshold in real-time to observe hybrid routing shifts:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('On-Device Max Chars Threshold:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        Text('${remoteConfig.onDeviceMaxChars} characters', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.cobaltBlue, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    Slider(
                      value: remoteConfig.onDeviceMaxChars.toDouble(),
                      min: 300,
                      max: 4000,
                      divisions: 37,
                      activeColor: AppColors.cobaltBlue,
                      inactiveColor: AppColors.borderMuted,
                      onChanged: (val) => remoteConfig.updateThresholdForTesting(val.toInt()),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Cloud AI Model:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        Text(remoteConfig.cloudModelName, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.internationalOrange, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('On-Device Model:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        Text(remoteConfig.onDeviceModelName, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.cobaltBlue, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.border,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Close Inspector'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, String label, String value, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 160, child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
