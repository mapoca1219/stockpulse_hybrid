import 'ai_telemetry.dart';

class ExtractedSkuEntry {
  final String sku;
  final String name;
  final int quantity;
  final double unitCost;
  final String? conditionNotes;

  const ExtractedSkuEntry({
    required this.sku,
    required this.name,
    required this.quantity,
    required this.unitCost,
    this.conditionNotes,
  });
}

class ScanResult {
  final String id;
  final String title;
  final String supplierOrLocation;
  final List<ExtractedSkuEntry> extractedItems;
  final List<String> anomalies;
  final String marginAnalysis;
  final String supplierComparison;
  final AITelemetry onDeviceTelemetry;
  final AITelemetry? cloudTelemetry;
  final DateTime scannedAt;
  final bool isQueuedForCloudSync;

  const ScanResult({
    required this.id,
    required this.title,
    required this.supplierOrLocation,
    required this.extractedItems,
    required this.anomalies,
    required this.marginAnalysis,
    required this.supplierComparison,
    required this.onDeviceTelemetry,
    this.cloudTelemetry,
    required this.scannedAt,
    this.isQueuedForCloudSync = false,
  });
}
