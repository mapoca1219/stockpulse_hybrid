class InventoryItem {
  final String id;
  final String sku;
  final String name;
  final String category;
  final int currentStock;
  final int minimumThreshold;
  final double costPrice;
  final double retailPrice;
  final DateTime lastScannedAt;
  final String? anomalyFlag;
  final String? locationBay;

  const InventoryItem({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.minimumThreshold,
    required this.costPrice,
    required this.retailPrice,
    required this.lastScannedAt,
    this.anomalyFlag,
    this.locationBay,
  });

  bool get isLowStock => currentStock <= minimumThreshold && currentStock > 0;
  bool get isOutOfStock => currentStock <= 0;
  bool get isOverstocked => currentStock >= (minimumThreshold * 4);

  double get marginPercent {
    if (retailPrice == 0) return 0.0;
    return ((retailPrice - costPrice) / retailPrice) * 100;
  }

  double get totalInventoryValue => currentStock * costPrice;
  double get totalRetailValue => currentStock * retailPrice;

  InventoryItem copyWith({
    String? id,
    String? sku,
    String? name,
    String? category,
    int? currentStock,
    int? minimumThreshold,
    double? costPrice,
    double? retailPrice,
    DateTime? lastScannedAt,
    String? anomalyFlag,
    String? locationBay,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      currentStock: currentStock ?? this.currentStock,
      minimumThreshold: minimumThreshold ?? this.minimumThreshold,
      costPrice: costPrice ?? this.costPrice,
      retailPrice: retailPrice ?? this.retailPrice,
      lastScannedAt: lastScannedAt ?? this.lastScannedAt,
      anomalyFlag: anomalyFlag ?? this.anomalyFlag,
      locationBay: locationBay ?? this.locationBay,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'category': category,
      'currentStock': currentStock,
      'minimumThreshold': minimumThreshold,
      'costPrice': costPrice,
      'retailPrice': retailPrice,
      'lastScannedAt': lastScannedAt.toIso8601String(),
      'anomalyFlag': anomalyFlag,
      'locationBay': locationBay,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map, [String? docId]) {
    return InventoryItem(
      id: docId ?? map['id'] ?? '',
      sku: map['sku'] ?? 'UNKNOWN-SKU',
      name: map['name'] ?? 'Unnamed Product',
      category: map['category'] ?? 'General',
      currentStock: (map['currentStock'] as num?)?.toInt() ?? 0,
      minimumThreshold: (map['minimumThreshold'] as num?)?.toInt() ?? 5,
      costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0.0,
      retailPrice: (map['retailPrice'] as num?)?.toDouble() ?? 0.0,
      lastScannedAt: map['lastScannedAt'] != null
          ? DateTime.tryParse(map['lastScannedAt']) ?? DateTime.now()
          : DateTime.now(),
      anomalyFlag: map['anomalyFlag'],
      locationBay: map['locationBay'],
    );
  }
}
