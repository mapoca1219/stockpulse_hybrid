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
                                  color: AppColors.cyberLime,
                                  fontWeight: FontWeight.w700,
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
                                      color: currentStock <= item.minimumThreshold ? AppColors.sunsetCoral : AppColors.cyberLime,
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
                                Text('${marginPct.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.cyberLime)),
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Add Inventory SKU', style: Theme.of(context).textTheme.displaySmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU Code (e.g. TR-X10)')),
            const SizedBox(height: 10),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Product Name')),
            const SizedBox(height: 10),
            TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Initial Stock Quantity')),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cost Price (\$)'))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: retailCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Retail Price (\$)'))),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (skuCtrl.text.isNotEmpty && nameCtrl.text.isNotEmpty) {
                context.read<InventoryRepository>().addItem(
                      InventoryItem(
                        id: 'inv-${DateTime.now().millisecondsSinceEpoch}',
                        sku: skuCtrl.text.trim().toUpperCase(),
                        name: nameCtrl.text.trim(),
                        category: 'General Catalog',
                        currentStock: int.tryParse(stockCtrl.text) ?? 10,
                        minimumThreshold: 5,
                        costPrice: double.tryParse(costCtrl.text) ?? 20.0,
                        retailPrice: double.tryParse(retailCtrl.text) ?? 49.99,
                        lastScannedAt: DateTime.now(),
                      ),
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add SKU'),
          ),
        ],
      ),
    );
  }
}
