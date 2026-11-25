import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/sample_data.dart';
import '../models/scan_result.dart';
import '../services/hybrid_inference_engine.dart';
import '../services/inventory_repository.dart';
import 'bento_card.dart';
import 'hybrid_routing_visualizer.dart';
import 'telemetry_badge.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final TextEditingController _textController = TextEditingController(text: SampleData.sampleReceiptApex);
  ScanResult? _latestResult;
  bool _isProcessing = false;
  final Set<String> _committedResultIds = {};

  void _loadSample(String sampleText, String title) {
    setState(() {
      _textController.text = sampleText;
    });
    _executeScan(title);
  }

  Future<void> _executeScan(String title) async {
    if (_textController.text.trim().isEmpty) return;

    setState(() => _isProcessing = true);
    final engine = context.read<HybridInferenceEngine>();
    final inventory = context.read<InventoryRepository>();

    final result = await engine.processScan(
      rawContent: _textController.text,
      title: title,
    );

    await inventory.recordAuditLog(
      action: 'MULTIMODAL_SCAN',
      details: 'Extracted ${result.extractedItems.length} items from ${result.title}',
      telemetry: result.onDeviceTelemetry,
    );

    setState(() {
      _latestResult = result;
      _isProcessing = false;
    });
  }

  Future<void> _commitToInventory(ScanResult result) async {
    final inventory = context.read<InventoryRepository>();
    int totalAdded = 0;
    for (final item in result.extractedItems) {
      await inventory.logUnits(
        sku: item.sku,
        quantityDelta: item.quantity,
        name: item.name,
        costPrice: item.unitCost,
      );
      totalAdded += item.quantity;
    }
    await inventory.recordAuditLog(
      action: 'INGEST_SCAN_TO_CATALOG',
      details: 'Committed ${result.extractedItems.length} SKUs ($totalAdded units) from ${result.title} into live catalog',
      telemetry: result.onDeviceTelemetry,
    );
    setState(() {
      _committedResultIds.add(result.id);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.emeraldGreen, width: 1.5),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.emeraldGreen, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ingested ${result.extractedItems.length} SKUs ($totalAdded units) into Inventory Catalog!',
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Smart Shelf & Receipt Scanner',
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
                  'DUAL HYBRID PIPELINE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Stage 1: Gemini Nano extracts SKUs in 35ms (0ms network). Stage 2: Firebase AI Logic computes margin spread in cloud.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),

          // Live Animated Dual-Stage Visualizer
          const HybridRoutingVisualizer(isDualHybrid: true),
          const SizedBox(height: 16),

          // Presets & Input Card
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Choose Preset or Input Source', style: Theme.of(context).textTheme.headlineMedium),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _loadSample(SampleData.sampleReceiptApex, 'Apex Logistics Invoice #8821'),
                          icon: const Icon(Icons.receipt_long_rounded, size: 14),
                          label: const Text('Preset: Supplier Receipt'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _loadSample(SampleData.sampleShelfAudit, 'Warehouse Bay C-4 Shelf Scan'),
                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 14),
                          label: const Text('Preset: Shelf Audit'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _textController,
                  maxLines: 7,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontFamily: 'JetBrainsMono',
                      ),
                  decoration: const InputDecoration(
                    hintText: 'Paste supplier invoice text, packing list, or optical OCR output...',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : () => _executeScan('Custom Warehouse Scan'),
                      icon: _isProcessing
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textDark))
                          : const Icon(Icons.bolt_rounded, size: 18),
                      label: Text(_isProcessing ? 'Analyzing Dual Pipeline...' : 'Run Hybrid Scan Pipeline'),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Stage 1: Nano 4 On-Device  →  Stage 2: Gemini 2.5 Cloud Deep Margin',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Scan Results Cards
          if (_latestResult != null) ...[
            Text('Scan Pipeline Output & Telemetry', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),

            // Telemetry Header
            BentoCard(
              hasGlow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _latestResult!.title,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.cobaltBlue),
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          TelemetryBadge(telemetry: _latestResult!.onDeviceTelemetry),
                          if (_latestResult!.cloudTelemetry != null)
                            TelemetryBadge(telemetry: _latestResult!.cloudTelemetry!),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 12),

                  // Dual Split: Stage 1 (On-Device) vs Stage 2 (Cloud)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 800;
                      return isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildStage1OnDevice(context, _latestResult!)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildStage2Cloud(context, _latestResult!)),
                              ],
                            )
                          : Column(
                              children: [
                                _buildStage1OnDevice(context, _latestResult!),
                                const SizedBox(height: 16),
                                _buildStage2Cloud(context, _latestResult!),
                              ],
                            );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCommitToCatalogBar(context, _latestResult!),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStage1OnDevice(BuildContext context, ScanResult result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cobaltBlue, width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10111827),
            blurRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: AppColors.cobaltBlueMuted, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.memory_rounded, size: 16, color: AppColors.cobaltBlue),
              ),
              const SizedBox(width: 8),
              Text(
                'Stage 1: On-Device Gemini Nano 4',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.cobaltBlue, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Extracted ${result.extractedItems.length} SKUs in ${result.onDeviceTelemetry.latencyMs}ms with zero server egress.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: result.extractedItems.length,
            itemBuilder: (context, idx) {
              final item = result.extractedItems[idx];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.cobaltBlueMuted,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.cobaltBlue.withValues(alpha: 0.3)),
                      ),
                      child: Text(item.sku, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.cobaltBlue, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.name, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
                    Text('${item.quantity} units', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text('Detected Anomalies:', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.internationalOrange, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          ...result.anomalies.map((a) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: AppColors.internationalOrange, fontWeight: FontWeight.bold)),
                    Expanded(child: Text(a, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.internationalOrange, fontWeight: FontWeight.w600))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStage2Cloud(BuildContext context, ScanResult result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.internationalOrange, width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10111827),
            blurRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: AppColors.internationalOrangeMuted, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.cloud_rounded, size: 16, color: AppColors.internationalOrange),
              ),
              const SizedBox(width: 8),
              Text(
                'Stage 2: Cloud AI Margin Synthesis',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.internationalOrange, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            result.isQueuedForCloudSync
                ? 'Offline Mode Active: Task placed in Offline Queue for cloud sync'
                : 'Deep cross-document contract & historical price benchmark analysis',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderMuted),
            ),
            child: Text(
              result.marginAnalysis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary, height: 1.5, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderMuted),
            ),
            child: Text(
              result.supplierComparison,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary, height: 1.5, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitToCatalogBar(BuildContext context, ScanResult result) {
    final isCommitted = _committedResultIds.contains(result.id);
    final totalUnits = result.extractedItems.fold(0, (sum, item) => sum + item.quantity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCommitted ? AppColors.emeraldBg : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCommitted ? AppColors.emeraldGreen : AppColors.border,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14111827),
            blurRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isCommitted ? Icons.check_circle_rounded : Icons.inventory_2_rounded,
            color: isCommitted ? AppColors.emeraldGreen : AppColors.cobaltBlue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCommitted
                      ? 'Catalog Ingestion Complete'
                      : 'Commit Scanned Delivery to Live Catalog',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: isCommitted ? AppColors.emeraldGreen : AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  isCommitted
                      ? '${result.extractedItems.length} SKUs ($totalUnits units) successfully logged to inventory. Quantities and safety margins updated.'
                      : 'Nano 4 extracted ${result.extractedItems.length} SKUs ($totalUnits total units). Click to apply stock updates to Firestore cache.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: isCommitted ? null : () => _commitToInventory(result),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCommitted ? AppColors.surfaceSubtle : AppColors.border,
              foregroundColor: isCommitted ? AppColors.textMuted : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: Icon(
              isCommitted ? Icons.done_all_rounded : Icons.add_task_rounded,
              size: 18,
            ),
            label: Text(
              isCommitted ? 'Ingested' : 'Commit to Catalog',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
