import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../services/hybrid_inference_engine.dart';
import '../services/inventory_repository.dart';
import '../services/offline_sync_service.dart';
import 'bento_card.dart';

class AnalyticsDashboardView extends StatelessWidget {
  const AnalyticsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<HybridInferenceEngine>();
    final inventory = context.watch<InventoryRepository>();
    final syncService = context.watch<OfflineSyncService>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Text(
                'Operational Intelligence & Telemetry',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ENGINE: PREFER_ON_DEVICE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bento KPI Row 1: Key Metrics
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: isWide ? 1.7 : 1.3,
                children: [
                  _buildKpiCard(
                    context,
                    title: 'On-Device Split',
                    value: '${engine.onDevicePercentage.toStringAsFixed(0)}%',
                    subtext: '${engine.totalOnDeviceInferences} Local / ${engine.totalCloudInferences} Cloud',
                    icon: Icons.memory_rounded,
                    accent: AppColors.cobaltBlue,
                  ),
                  _buildKpiCard(
                    context,
                    title: 'Tokens Preserved',
                    value: '${engine.totalTokensSaved}',
                    subtext: '\$${engine.totalCostSavedUsd.toStringAsFixed(3)} Cloud Cost Saved',
                    icon: Icons.savings_outlined,
                    accent: AppColors.cobaltBlue,
                  ),
                  _buildKpiCard(
                    context,
                    title: 'Stock Health Index',
                    value: '${inventory.healthyCount}/${inventory.totalUniqueSkus}',
                    subtext: '${inventory.lowStockCount} Low Stock Alerts',
                    icon: Icons.inventory_2_outlined,
                    accent: inventory.criticalCount > 0 ? AppColors.internationalOrange : AppColors.emeraldGreen,
                  ),
                  _buildKpiCard(
                    context,
                    title: 'Average Gross Margin',
                    value: '${inventory.averageMarginPercent.toStringAsFixed(1)}%',
                    subtext: '\$${(inventory.totalRetailValue - inventory.totalInventoryCostValue).toStringAsFixed(0)} Net Potential',
                    icon: Icons.trending_up_rounded,
                    accent: AppColors.cobaltBlue,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Bento Section: Charts
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildInferenceSplitGauge(context, engine)),
                        const SizedBox(width: 16),
                        Expanded(flex: 4, child: _buildMarginBarChart(context, inventory)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildInferenceSplitGauge(context, engine),
                        const SizedBox(height: 16),
                        _buildMarginBarChart(context, inventory),
                      ],
                    );
            },
          ),
          const SizedBox(height: 20),

          // Bento Section: Offline Sync Queue & Recent Audit Logs
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildOfflineQueueMonitor(context, syncService, engine)),
                        const SizedBox(width: 16),
                        Expanded(flex: 4, child: _buildRecentAuditLogs(context, inventory)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildOfflineQueueMonitor(context, syncService, engine),
                        const SizedBox(height: 16),
                        _buildRecentAuditLogs(context, inventory),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color accent,
  }) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              Icon(icon, size: 18, color: accent),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtext,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInferenceSplitGauge(BuildContext context, HybridInferenceEngine engine) {
    final onDeviceCount = engine.totalOnDeviceInferences;
    final cloudCount = engine.totalCloudInferences;

    return BentoCard(
      hasGlow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hybrid Inference Split',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'Gemini Nano 4 (Cobalt) vs Cloud AI Logic (Vermilion)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cobaltBlueMuted,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.cobaltBlue, width: 1),
                ),
                child: Text(
                  '${engine.latestLatencyMs}ms Last',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.cobaltBlue,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    value: onDeviceCount.toDouble(),
                    title: '${engine.onDevicePercentage.toStringAsFixed(0)}%',
                    color: AppColors.cobaltBlue,
                    radius: 35,
                    titleStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  PieChartSectionData(
                    value: cloudCount.toDouble(),
                    title: '${(100 - engine.onDevicePercentage).toStringAsFixed(0)}%',
                    color: AppColors.internationalOrange,
                    radius: 35,
                    titleStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.cobaltBlue, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('On-Device ($onDeviceCount)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ],
              ),
              Row(
                children: [
                  Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.internationalOrange, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('Cloud AI ($cloudCount)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarginBarChart(BuildContext context, InventoryRepository inventory) {
    final items = inventory.items.take(5).toList();

    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gross Margin by Key SKU',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'Cost vs Retail spread across top items',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const Icon(Icons.bar_chart_rounded, color: AppColors.cobaltBlue),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < items.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              items[idx].sku,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (val, meta) => Text(
                        '${val.toInt()}%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => const FlLine(color: AppColors.borderMuted, strokeWidth: 1.0),
                ),
                borderData: FlBorderData(show: false),
                barGroups: items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: item.marginPercent.clamp(0, 100),
                        color: AppColors.cobaltBlue,
                        width: 18,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Target warehouse benchmark: >= 55% margin',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineQueueMonitor(
    BuildContext context,
    OfflineSyncService syncService,
    HybridInferenceEngine engine,
  ) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Offline Task Queue',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (syncService.hasPending)
                ElevatedButton.icon(
                  onPressed: syncService.isSyncing ? null : () => syncService.flushQueue(),
                  icon: syncService.isSyncing
                      ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textDark))
                      : const Icon(Icons.sync_rounded, size: 14),
                  label: const Text('Flush Sync'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (syncService.pendingTasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 36, color: AppColors.success),
                  const SizedBox(height: 10),
                  Text(
                    'All offline tasks synchronized',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                  ),
                  Text(
                    'Toggle "Simulate Offline Mode" to queue cloud synthesis tasks locally',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: syncService.pendingTasks.length,
              separatorBuilder: (_, _) => const Divider(height: 12, color: AppColors.border),
              itemBuilder: (context, idx) {
                final task = syncService.pendingTasks[idx];
                return Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 16, color: AppColors.offline),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.summary, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary)),
                          Text(task.type, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.offline)),
                        ],
                      ),
                    ),
                    const Text('PENDING', style: TextStyle(color: AppColors.offline, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecentAuditLogs(BuildContext context, InventoryRepository inventory) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Operations Audit Trail',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Icon(Icons.history_rounded, size: 18, color: AppColors.cobaltBlue),
            ],
          ),
          const SizedBox(height: 14),
          inventory.auditLogs.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  child: Text(
                    'Audit logs from Copilot & Scanner will appear here in real-time.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: inventory.auditLogs.take(4).length,
                  separatorBuilder: (_, _) => const Divider(height: 12, color: AppColors.borderMuted),
                  itemBuilder: (context, idx) {
                    final log = inventory.auditLogs[idx];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.bolt_rounded, size: 16, color: AppColors.cobaltBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log['action'] ?? 'AI_OPERATION',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.cobaltBlue,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              Text(
                                log['details'] ?? '',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ],
      ),
    );
  }
}
