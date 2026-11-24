class OfflineTask {
  final String id;
  final String type; // e.g. "CLOUD_MARGIN_DEEP_DIVE", "FIRESTORE_AUDIT_LOG", "INVENTORY_SYNC"
  final String summary;
  final Map<String, dynamic> payload;
  final DateTime queuedAt;
  bool isSynced;
  DateTime? syncedAt;

  OfflineTask({
    required this.id,
    required this.type,
    required this.summary,
    required this.payload,
    required this.queuedAt,
    this.isSynced = false,
    this.syncedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'summary': summary,
      'payload': payload,
      'queuedAt': queuedAt.toIso8601String(),
      'isSynced': isSynced,
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }
}
