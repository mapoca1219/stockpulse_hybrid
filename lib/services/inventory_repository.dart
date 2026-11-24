import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../constants/sample_data.dart';
import '../models/ai_telemetry.dart';
import '../models/inventory_item.dart';
import 'firebase_config_service.dart';

class InventoryRepository extends ChangeNotifier {
  static final InventoryRepository _instance = InventoryRepository._internal();
  factory InventoryRepository() => _instance;
  InventoryRepository._internal();

  final List<InventoryItem> _items = [];
  final List<Map<String, dynamic>> _auditLogs = [];
  bool _isLoading = false;

  List<InventoryItem> get items => List.unmodifiable(_items);
  List<Map<String, dynamic>> get auditLogs => List.unmodifiable(_auditLogs);
  bool get isLoading => _isLoading;

  // Analytics Helpers
  int get totalUniqueSkus => _items.length;
  int get totalStockUnits => _items.fold(0, (acc, item) => acc + item.currentStock);
  double get totalInventoryCostValue => _items.fold(0.0, (acc, item) => acc + item.totalInventoryValue);
  double get totalRetailValue => _items.fold(0.0, (acc, item) => acc + item.totalRetailValue);
  
  double get averageMarginPercent {
    if (_items.isEmpty) return 0.0;
    final totalMargin = _items.fold(0.0, (acc, item) => acc + item.marginPercent);
    return totalMargin / _items.length;
  }

  int get lowStockCount => _items.where((i) => i.isLowStock || i.isOutOfStock).length;
  int get criticalCount => _items.where((i) => i.isOutOfStock || (i.currentStock < (i.minimumThreshold * 0.3))).length;
  int get healthyCount => _items.where((i) => !i.isLowStock && !i.isOutOfStock).length;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // Start with rich sample inventory
    _items.clear();
    _items.addAll(SampleData.initialInventory);

    // If Firebase is available, sync to/from Firestore collection 'inventory'
    if (FirebaseConfigService().isFirebaseInitialized) {
      try {
        final collection = FirebaseFirestore.instance.collection('inventory');
        final snapshot = await collection.limit(50).get(const GetOptions(source: Source.cache));
        if (snapshot.docs.isNotEmpty) {
          _items.clear();
          for (final doc in snapshot.docs) {
            _items.add(InventoryItem.fromMap(doc.data(), doc.id));
          }
        } else {
          // Seed initial data into Firestore with offline persistence
          for (final item in _items) {
            await collection.doc(item.id).set(item.toMap(), SetOptions(merge: true));
          }
        }
      } catch (e) {
        debugPrint('[InventoryRepo] Operating with local cache/sample data: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(InventoryItem item) async {
    _items.insert(0, item);
    notifyListeners();

    if (FirebaseConfigService().isFirebaseInitialized) {
      try {
        await FirebaseFirestore.instance.collection('inventory').doc(item.id).set(item.toMap());
      } catch (e) {
        debugPrint('[InventoryRepo] Firestore offline write queued: $e');
      }
    }
  }

  Future<void> updateItem(InventoryItem updated) async {
    final index = _items.indexWhere((i) => i.id == updated.id || i.sku == updated.sku);
    if (index != -1) {
      _items[index] = updated;
      notifyListeners();

      if (FirebaseConfigService().isFirebaseInitialized) {
        try {
          await FirebaseFirestore.instance.collection('inventory').doc(updated.id).set(updated.toMap(), SetOptions(merge: true));
        } catch (e) {
          debugPrint('[InventoryRepo] Firestore offline update queued: $e');
        }
      }
    }
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();

    if (FirebaseConfigService().isFirebaseInitialized) {
      try {
        await FirebaseFirestore.instance.collection('inventory').doc(id).delete();
      } catch (e) {
        debugPrint('[InventoryRepo] Firestore offline delete queued: $e');
      }
    }
  }

  InventoryItem? findBySku(String sku) {
    try {
      return _items.firstWhere((i) => i.sku.toUpperCase() == sku.trim().toUpperCase());
    } catch (_) {
      return null;
    }
  }

  Future<InventoryItem> logUnits({
    required String sku,
    required int quantityDelta,
    int? minimumThreshold,
    String? name,
    double? costPrice,
    double? retailPrice,
    String? category,
  }) async {
    final existing = findBySku(sku);
    final now = DateTime.now();

    if (existing != null) {
      final updated = existing.copyWith(
        currentStock: existing.currentStock + quantityDelta,
        minimumThreshold: minimumThreshold ?? existing.minimumThreshold,
        lastScannedAt: now,
        anomalyFlag: null,
      );
      await updateItem(updated);
      return updated;
    } else {
      final newItem = InventoryItem(
        id: 'inv-${DateTime.now().millisecondsSinceEpoch}',
        sku: sku.toUpperCase().trim(),
        name: name ?? 'Logged Product $sku',
        category: category ?? 'General Goods',
        currentStock: quantityDelta,
        minimumThreshold: minimumThreshold ?? 5,
        costPrice: costPrice ?? 25.0,
        retailPrice: retailPrice ?? 49.99,
        lastScannedAt: now,
        locationBay: 'Receiving Dock A',
      );
      await addItem(newItem);
      return newItem;
    }
  }

  Future<void> recordAuditLog({
    required String action,
    required String details,
    required AITelemetry telemetry,
    Map<String, dynamic>? extraData,
  }) async {
    final logEntry = {
      'action': action,
      'details': details,
      'telemetry': telemetry.toMap(),
      'timestamp': DateTime.now().toIso8601String(),
      'extra': extraData,
    };
    _auditLogs.insert(0, logEntry);
    notifyListeners();

    if (FirebaseConfigService().isFirebaseInitialized) {
      try {
        await FirebaseFirestore.instance.collection('ai_audit_logs').add(logEntry);
      } catch (e) {
        debugPrint('[InventoryRepo] Audit log offline queued: $e');
      }
    }
  }
}
