import 'package:flutter/material.dart';

import '../../core/widgets/page_canvas.dart';
import '../../core/widgets/responsive_grid.dart';
import '../../shared/models/owned_item.dart';
import '../../shared/widgets/inventory_card.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key, required this.items});

  final List<OwnedItem> items;

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  ItemRarity? _filter;

  @override
  Widget build(BuildContext context) {
    final items = _filter == null
        ? widget.items
        : widget.items.where((item) => item.rarity == _filter).toList();
    return PageCanvas(
      title: 'Inventory',
      subtitle: 'Filter owned items by rarity and quantity.',
      actions: [
        DropdownButton<ItemRarity?>(
          value: _filter,
          hint: const Text('All rarities'),
          items: [
            const DropdownMenuItem(value: null, child: Text('All rarities')),
            ...ItemRarity.values.map(
              (rarity) =>
                  DropdownMenuItem(value: rarity, child: Text(rarity.label)),
            ),
          ],
          onChanged: (value) => setState(() => _filter = value),
        ),
      ],
      children: [
        ResponsiveGrid(
          minItemWidth: 185,
          children: items.map((item) => InventoryCard(item: item)).toList(),
        ),
      ],
    );
  }
}
