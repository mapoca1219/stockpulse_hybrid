import 'ai_telemetry.dart';

enum MessageSender { user, assistant, system }

class CopilotMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final Map<String, dynamic>? structuredAction;
  final AITelemetry? telemetry;
  final DateTime timestamp;
  final bool isOfflineQueued;

  const CopilotMessage({
    required this.id,
    required this.sender,
    required this.text,
    this.structuredAction,
    this.telemetry,
    required this.timestamp,
    this.isOfflineQueued = false,
  });

  CopilotMessage copyWith({
    String? id,
    MessageSender? sender,
    String? text,
    Map<String, dynamic>? structuredAction,
    AITelemetry? telemetry,
    DateTime? timestamp,
    bool? isOfflineQueued,
  }) {
    return CopilotMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      structuredAction: structuredAction ?? this.structuredAction,
      telemetry: telemetry ?? this.telemetry,
      timestamp: timestamp ?? this.timestamp,
      isOfflineQueued: isOfflineQueued ?? this.isOfflineQueued,
    );
  }
}
