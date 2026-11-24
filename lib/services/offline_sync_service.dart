import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/offline_task.dart';

class OfflineSyncService extends ChangeNotifier {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  final List<OfflineTask> _pendingTasks = [];
  final List<OfflineTask> _completedTasks = [];
  bool _isSyncing = false;

  List<OfflineTask> get pendingTasks => List.unmodifiable(_pendingTasks);
  List<OfflineTask> get completedTasks => List.unmodifiable(_completedTasks);
  int get pendingCount => _pendingTasks.length;
  bool get hasPending => _pendingTasks.isNotEmpty;
  bool get isSyncing => _isSyncing;

  OfflineTask queueTask({
    required String type,
    required String summary,
    required Map<String, dynamic> payload,
  }) {
    final task = OfflineTask(
      id: const Uuid().v4(),
      type: type,
      summary: summary,
      payload: payload,
      queuedAt: DateTime.now(),
    );
    _pendingTasks.insert(0, task);
    notifyListeners();
    return task;
  }

  Future<int> flushQueue({Future<void> Function(OfflineTask task)? onSyncItem}) async {
    if (_pendingTasks.isEmpty || _isSyncing) return 0;

    _isSyncing = true;
    notifyListeners();

    int syncedCount = 0;
    final tasksToSync = List<OfflineTask>.from(_pendingTasks);

    for (final task in tasksToSync) {
      try {
        if (onSyncItem != null) {
          await onSyncItem(task);
        } else {
          // Simulated network roundtrip
          await Future.delayed(const Duration(milliseconds: 180));
        }
        task.isSynced = true;
        task.syncedAt = DateTime.now();
        _pendingTasks.remove(task);
        _completedTasks.insert(0, task);
        syncedCount++;
        notifyListeners();
      } catch (e) {
        debugPrint('[OfflineSync] Failed to sync task ${task.id}: $e');
      }
    }

    _isSyncing = false;
    notifyListeners();
    return syncedCount;
  }

  void clearHistory() {
    _completedTasks.clear();
    notifyListeners();
  }
}
