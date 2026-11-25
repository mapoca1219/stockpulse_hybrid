import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/inventory_item.dart';
import '../services/inventory_repository.dart';
import 'bento_card.dart';

class InventoryManagementView extends StatefulWidget {
  const InventoryManagementView({super.key});

  @override
  State<InventoryManagementView> createState() => _InventoryManagementViewState();
}

class _InventoryManagementViewState extends State<InventoryManagementView> {
  String _filterQuery = '';

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryRepository>();
    final items = inventory.items.where((i) {
      if (_filterQuery.isEmpty) return true;
      final q = _filterQuery.toLowerCase();
      return i.sku.toLowerCase().contains(q) ||
          i.name.toLowerCase().contains(q) ||
          i.category.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Warehouse Inventory & Catalog',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add SKU'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          TextField(
            onChanged: (val) => setState(() => _filterQuery = val),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
              hintText: 'Filter by SKU, product name, or category...',
            ),
          ),
          const SizedBox(height: 16),

          // Inventory Table / List
          Expanded(
            child: BentoCard(
              padding: EdgeInsets.zero,
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, idx) {
                  final item = items[idx];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onTap: () => _showItemDetailDialog(context, item),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.borderHighlight),
                          ),
                          child: Text(
                            item.sku,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.cobaltBlue,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(context, item),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Text('${item.category}  •  ${item.locationBay ?? "General Bay"}', style: Theme.of(context).textTheme.bodySmall),
                          const Spacer(),
                          Text(
                            'Stock: ${item.currentStock} units (Min: ${item.minimumThreshold})  |  Cost: \$${item.costPrice.toStringAsFixed(2)}  |  Retail: \$${item.retailPrice.toStringAsFixed(2)}  |  Margin: ${item.marginPercent.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      color: AppColors.surfaceElevated,
                      onSelected: (val) {
                        if (val == 'restock') {
                          inventory.logUnits(sku: item.sku, quantityDelta: 10);
                        } else if (val == 'delete') {
                          inventory.deleteItem(item.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'restock', child: Text('Quick Restock (+10)')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete SKU', style: TextStyle(color: AppColors.error))),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, InventoryItem item) {
    if (item.isOutOfStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.internationalOrangeMuted,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.internationalOrange, width: 1),
        ),
        child: const Text('OUT OF STOCK', style: TextStyle(color: AppColors.internationalOrange, fontSize: 10, fontWeight: FontWeight.w800)),
      );
    }
    if (item.isLowStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.internationalOrangeMuted,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.internationalOrange, width: 1),
        ),
        child: const Text('LOW STOCK', style: TextStyle(color: AppColors.internationalOrange, fontSize: 10, fontWeight: FontWeight.w800)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.emeraldBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.emeraldGreen, width: 1),
      ),
      child: const Text('HEALTHY', style: TextStyle(color: AppColors.emeraldGreen, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }

  void _showItemDetailDialog(BuildContext context, InventoryItem item) {
    int currentStock = item.currentStock;
    final thresholdCtrl = TextEditingController(text: item.minimumThreshold.toString());
    final locationCtrl = TextEditingController(text: item.locationBay ?? 'General Bay');
    final retailCtrl = TextEditingController(text: item.retailPrice.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final retail = double.tryParse(retailCtrl.text) ?? item.retailPrice;
          final marginPct = retail > 0 ? ((retail - item.costPrice) / retail) * 100 : 0.0;

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppColors.border, width: 1.5),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cobaltBlueMuted,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.cobaltBlue, width: 1.2),
                  ),
                  child: Text(
                    item.sku,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.cobaltBlue,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stock Counter & Quick Adjusters
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Stock Level:', style: Theme.of(context).textTheme.bodySmall),
                              Text(
                                '$currentStock units',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: currentStock <= item.minimumThreshold ? AppColors.internationalOrange : AppColors.emeraldGreen,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton(
                                onPressed: currentStock >= 10
                                    ? () => setDialogState(() => currentStock -= 10)
                                    : null,
                                child: const Text('-10'),
                              ),
                              OutlinedButton(
                                onPressed: currentStock >= 1
                                    ? () => setDialogState(() => currentStock -= 1)
                                    : null,
                                child: const Text('-1'),
                              ),
                              ElevatedButton(
                                onPressed: () => setDialogState(() => currentStock += 1),
                                child: const Text('+1'),
                              ),
                              ElevatedButton(
                                onPressed: () => setDialogState(() => currentStock += 10),
                                child: const Text('+10'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Metrics summary
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(6)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Unit Cost', style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 2),
                                Text('\$${item.costPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(6)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Margin Spread', style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 2),
                                Text('${marginPct.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.emeraldGreen)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: thresholdCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Safety Threshold (Min Units)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: locationCtrl,
                      decoration: const InputDecoration(labelText: 'Warehouse Bay Location'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: retailCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Retail Price (\$)'),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final newThreshold = int.tryParse(thresholdCtrl.text) ?? item.minimumThreshold;
                  final newRetail = double.tryParse(retailCtrl.text) ?? item.retailPrice;
                  final newLocation = locationCtrl.text.trim();

                  final updated = item.copyWith(
                    currentStock: currentStock,
                    minimumThreshold: newThreshold,
                    retailPrice: newRetail,
                    locationBay: newLocation.isNotEmpty ? newLocation : item.locationBay,
                    lastScannedAt: DateTime.now(),
                  );

                  context.read<InventoryRepository>().updateItem(updated);
                  Navigator.pop(ctx);
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final skuCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '20');
    final costCtrl = TextEditingController(text: '35.00');
    final retailCtrl = TextEditingController(text: '79.99');
    final thresholdCtrl = TextEditingController(text: '5');
    final locationCtrl = TextEditingController(text: 'Bay B-01');
    String selectedCategory = 'Footwear';
    String? validationError;

    final categories = [
      'Footwear',
      'Warehouse Equipment',
      'Electronics & Tools',
      'Packaging Supplies',
      'Safety & PPE',
      'General Catalog',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cobaltBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.inventory_2_rounded, color: AppColors.cobaltBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Add Inventory SKU', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Presets (1-Click Fill):',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ActionChip(
                        label: const Text('Shoes (TR-X11)'),
                        onPressed: () {
                          setDialogState(() {
                            skuCtrl.text = 'TR-X11';
                            nameCtrl.text = 'Trail Runner Pro X11 All-Terrain';
                            selectedCategory = 'Footwear';
                            stockCtrl.text = '35';
                            costCtrl.text = '48.50';
                            retailCtrl.text = '129.99';
                            thresholdCtrl.text = '8';
                            locationCtrl.text = 'Bay B-04';
                            validationError = null;
                          });
                        },
                      ),
                      ActionChip(
                        label: const Text('Gloves (GLV-NIT-L)'),
                        onPressed: () {
                          setDialogState(() {
                            skuCtrl.text = 'GLV-NIT-L';
                            nameCtrl.text = 'Heavy-Duty Nitrile Industrial Gloves';
                            selectedCategory = 'Safety & PPE';
                            stockCtrl.text = '120';
                            costCtrl.text = '4.20';
                            retailCtrl.text = '12.50';
                            thresholdCtrl.text = '25';
                            locationCtrl.text = 'Safety Locker 3';
                            validationError = null;
                          });
                        },
                      ),
                      ActionChip(
                        label: const Text('Tape (KRAFT-50M)'),
                        onPressed: () {
                          setDialogState(() {
                            skuCtrl.text = 'KRAFT-50M';
                            nameCtrl.text = 'Reinforced Water-Activated Kraft Tape';
                            selectedCategory = 'Packaging Supplies';
                            stockCtrl.text = '75';
                            costCtrl.text = '8.90';
                            retailCtrl.text = '21.00';
                            thresholdCtrl.text = '15';
                            locationCtrl.text = 'Aisle 04-Rack C';
                            validationError = null;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (validationError != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0x1AFF4500),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFF4500), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF4500), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              validationError!,
                              style: const TextStyle(
                                color: Color(0xFFFF4500),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: skuCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'SKU Code *',
                            hintText: 'e.g. TR-X11',
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: validationError != null && skuCtrl.text.trim().isEmpty ? const Color(0xFFFF4500) : AppColors.cobaltBlue,
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: validationError != null && skuCtrl.text.trim().isEmpty ? const Color(0xFFFF4500) : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (_) {
                            if (validationError != null) setDialogState(() => validationError = null);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedCategory,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => selectedCategory = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Product Name *',
                      hintText: 'e.g. Trail Runner Pro X11',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: validationError != null && nameCtrl.text.trim().isEmpty ? const Color(0xFFFF4500) : AppColors.cobaltBlue,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: validationError != null && nameCtrl.text.trim().isEmpty ? const Color(0xFFFF4500) : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (_) {
                      if (validationError != null) setDialogState(() => validationError = null);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: stockCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Initial Units *'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: thresholdCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Safety Min *'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: costCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Unit Cost (\$)'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: retailCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Retail Price (\$)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Warehouse Bay Location',
                      hintText: 'e.g. Bay B-04 / Aisle 02',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add SKU'),
              onPressed: () async {
                final sku = skuCtrl.text.trim().toUpperCase();
                final name = nameCtrl.text.trim();

                if (sku.isEmpty || name.isEmpty) {
                  setDialogState(() {
                    validationError = 'SKU Code and Product Name are required';
                  });
                  return;
                }

                final stock = int.tryParse(stockCtrl.text.trim()) ?? 10;
                final threshold = int.tryParse(thresholdCtrl.text.trim()) ?? 5;
                final cost = double.tryParse(costCtrl.text.trim()) ?? 25.0;
                final retail = double.tryParse(retailCtrl.text.trim()) ?? (cost * 1.6);
                final bay = locationCtrl.text.trim().isNotEmpty ? locationCtrl.text.trim() : 'General Bay';

                final newItem = InventoryItem(
                  id: 'inv-${DateTime.now().millisecondsSinceEpoch}',
                  sku: sku,
                  name: name,
                  category: selectedCategory,
                  currentStock: stock,
                  minimumThreshold: threshold,
                  costPrice: cost,
                  retailPrice: retail,
                  locationBay: bay,
                  lastScannedAt: DateTime.now(),
                );

                final repo = context.read<InventoryRepository>();
                final navigator = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);

                // Close modal instantly
                navigator.pop();

                // Add to inventory & persist
                await repo.addItem(newItem);

                if (mounted) {
                  setState(() => _filterQuery = '');
                  messenger.showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.emeraldGreen, width: 1.5),
                      ),
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.emeraldGreen, size: 20),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'SKU added to Firestore & offline cache',
                              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
