import 'inference_mode.dart';

class AITelemetry {
  final InferenceSource inferenceSource;
  final String modelName;
  final int latencyMs;
  final int promptTokens;
  final int completionTokens;
  final int tokensSaved;
  final double costSavedUsd;
  final String? fallbackReason;
  final DateTime timestamp;

  const AITelemetry({
    required this.inferenceSource,
    required this.modelName,
    required this.latencyMs,
    required this.promptTokens,
    required this.completionTokens,
    required this.tokensSaved,
    required this.costSavedUsd,
    this.fallbackReason,
    required this.timestamp,
  });

  int get totalTokens => promptTokens + completionTokens;

  Map<String, dynamic> toMap() {
    return {
      'inferenceSource': inferenceSource.code,
      'modelName': modelName,
      'latencyMs': latencyMs,
      'promptTokens': promptTokens,
      'completionTokens': completionTokens,
      'tokensSaved': tokensSaved,
      'costSavedUsd': costSavedUsd,
      'fallbackReason': fallbackReason,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AITelemetry.fromMap(Map<String, dynamic> map) {
    return AITelemetry(
      inferenceSource: map['inferenceSource'] == 'ON_DEVICE'
          ? InferenceSource.onDevice
          : InferenceSource.inCloud,
      modelName: map['modelName'] ?? 'Unknown',
      latencyMs: (map['latencyMs'] as num?)?.toInt() ?? 0,
      promptTokens: (map['promptTokens'] as num?)?.toInt() ?? 0,
      completionTokens: (map['completionTokens'] as num?)?.toInt() ?? 0,
      tokensSaved: (map['tokensSaved'] as num?)?.toInt() ?? 0,
      costSavedUsd: (map['costSavedUsd'] as num?)?.toDouble() ?? 0.0,
      fallbackReason: map['fallbackReason'],
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
