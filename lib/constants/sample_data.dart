import '../models/inventory_item.dart';

class SampleData {
  static List<InventoryItem> get initialInventory => [
    InventoryItem(
      id: 'inv-001',
      sku: 'TR-X9',
      name: 'Trail Runner X9 All-Terrain Shoes',
      category: 'Footwear',
      currentStock: 14,
      minimumThreshold: 20,
      costPrice: 48.50,
      retailPrice: 139.99,
      lastScannedAt: DateTime.now().subtract(const Duration(minutes: 42)),
      anomalyFlag: 'Stock below safety threshold (14/20)',
      locationBay: 'Bay B-03',
    ),
    InventoryItem(
      id: 'inv-002',
      sku: 'AL-PRO-10',
      name: 'Apex Lithium Pallet Jack 1.5T',
      category: 'Warehouse Equipment',
      currentStock: 4,
      minimumThreshold: 2,
      costPrice: 1250.00,
      retailPrice: 2199.00,
      lastScannedAt: DateTime.now().subtract(const Duration(hours: 3)),
      locationBay: 'Staging Area 1',
    ),
    InventoryItem(
      id: 'inv-003',
      sku: 'BCS-2D-WIRE',
      name: 'OmniScan 2D Rugged Wireless Barcode Scanner',
      category: 'Electronics & Tools',
      currentStock: 22,
      minimumThreshold: 10,
      costPrice: 78.00,
      retailPrice: 169.50,
      lastScannedAt: DateTime.now().subtract(const Duration(hours: 1)),
      locationBay: 'Cage Tech-01',
    ),
    InventoryItem(
      id: 'inv-004',
      sku: 'TLR-4X6-24',
      name: 'Direct Thermal Shipping Labels 4x6 (1000/roll)',
      category: 'Packaging Supplies',
      currentStock: 88,
      minimumThreshold: 30,
      costPrice: 6.20,
      retailPrice: 18.90,
      lastScannedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      locationBay: 'Aisle 04-Rack D',
    ),
    InventoryItem(
      id: 'inv-005',
      sku: 'HV-VEST-O',
      name: 'ANSI Class 3 Hi-Vis Safety Vest (Orange / XL)',
      category: 'Safety & PPE',
      currentStock: 3,
      minimumThreshold: 15,
      costPrice: 11.00,
      retailPrice: 28.50,
      lastScannedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      anomalyFlag: 'Critical stock shortage (< 25% buffer)',
      locationBay: 'Safety Locker 2',
    ),
    InventoryItem(
      id: 'inv-006',
      sku: 'HD-STRAP-50',
      name: 'Heavy-Duty Poly Woven Strapping 19mm x 500m',
      category: 'Packaging Supplies',
      currentStock: 45,
      minimumThreshold: 15,
      costPrice: 24.00,
      retailPrice: 59.00,
      lastScannedAt: DateTime.now().subtract(const Duration(hours: 5)),
      locationBay: 'Aisle 04-Rack B',
    ),
    InventoryItem(
      id: 'inv-007',
      sku: 'STEEL-TOE-M',
      name: 'Titan Pro Waterproof Steel-Toe Workboot 10.5',
      category: 'Footwear',
      currentStock: 19,
      minimumThreshold: 12,
      costPrice: 52.00,
      retailPrice: 129.00,
      lastScannedAt: DateTime.now().subtract(const Duration(hours: 2)),
      locationBay: 'Bay B-08',
    ),
    InventoryItem(
      id: 'inv-008',
      sku: 'AIR-PILLOW-30',
      name: 'Biodegradable Air Cushion Void-Fill (3000 pcs)',
      category: 'Packaging Supplies',
      currentStock: 62,
      minimumThreshold: 25,
      costPrice: 19.50,
      retailPrice: 44.00,
      lastScannedAt: DateTime.now().subtract(const Duration(hours: 6)),
      locationBay: 'Aisle 02-Rack A',
    ),
  ];

  static const String sampleReceiptApex = '''
=== APEX FREIGHT & SUPPLIES INVOICE ===
INVOICE #: INV-2026-8821
VENDOR: APEX INDUSTRIAL LOGISTICS CORP.
DATE: 2026-11-24
PO NUMBER: PO-99412
DESTINATION: WAREHOUSE DC-WEST BAY 4

LINE ITEMS:
1. SKU: TR-X9 | Trail Runner X9 All-Terrain Shoes
   QTY: 25 Units | UNIT COST: \$46.80 | TOTAL: \$1,170.00
   NOTE: 2 boxes show outer seal puncture, inspect soles.

2. SKU: HV-VEST-O | ANSI Class 3 Hi-Vis Safety Vest
   QTY: 30 Units | UNIT COST: \$10.50 | TOTAL: \$315.00
   STATUS: Verified compliant.

3. SKU: TLR-4X6-24 | Thermal Shipping Labels (1000/roll)
   QTY: 50 Rolls | UNIT COST: \$5.95 | TOTAL: \$297.50
   STATUS: Pallet strapped.

4. SKU: MISC-TAPE-R | Reinforced Water-Activated Kraft Tape
   QTY: 20 Rolls | UNIT COST: \$14.20 | TOTAL: \$284.00
   ANOMALY: Unregistered SKU in warehouse catalog!

SUBTOTAL: \$2,066.50
TAX & FREIGHT: \$145.00
TOTAL PAYABLE: \$2,211.50
=======================================
''';

  static const String sampleShelfAudit = '''
=== MOBILE AUDIT LOG: AISLE 04 BAY C-4 ===
AUDITOR: Scanner Terminal #07 (Staff: Elena R.)
TIMESTAMP: 2026-11-24 09:30 AM
FACILITY: Regional Fulfillment Hub 3

BIN INSPECTION:
- Shelf C4-A: SKU TLR-4X6-24 | Counted: 88 rolls. Label integrity: 100%.
- Shelf C4-B: SKU HD-STRAP-50 | Counted: 45 units. Barcode unscannable on 3 units, re-tagged.
- Shelf C4-C: SKU AIR-PILLOW-30 | Counted: 62 packs. Stock overflowing onto lower deck.
- Floor Pallet: Unlabeled wooden skid containing 12 crates of industrial safety gloves (SKU GLV-NIT-L).

ANOMALIES RECORDED:
1. Floor Pallet blocking emergency forklift route.
2. Missing inventory record for GLV-NIT-L in DC-3 ledger.
=========================================
''';
}
