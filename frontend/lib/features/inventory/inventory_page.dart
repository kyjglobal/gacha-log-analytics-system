import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/page_canvas.dart';
import '../../core/widgets/responsive_grid.dart';
import '../../shared/models/owned_item.dart';
import '../../shared/widgets/inventory_card.dart';
import '../auth/presentation/auth_providers.dart';
import '../gacha/domain/gacha_models.dart';
import '../gacha/presentation/gacha_providers.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  ItemRarity? _filter;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider).value;
    final inventory = session == null
        ? const AsyncData<List<InventoryEntry>>([])
        : ref.watch(inventoryProvider(_filter?.name));
    return PageCanvas(
      title: 'Inventory',
      subtitle: '서버에 저장된 보유 아이템을 등급별로 조회합니다.',
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
        inventory.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(inventoryProvider(_filter?.name)),
              child: Text('인벤토리를 불러오지 못했습니다.\n$error\n다시 시도'),
            ),
          ),
          data: (entries) => entries.isEmpty
              ? Center(
                  child: Text(
                    session == null
                        ? '로그인 후 인벤토리를 확인할 수 있습니다.'
                        : '보유한 아이템이 없습니다.',
                  ),
                )
              : ResponsiveGrid(
                  minItemWidth: 185,
                  children: entries
                      .map((entry) => InventoryCard(item: _toOwnedItem(entry)))
                      .toList(),
                ),
        ),
      ],
    );
  }

  OwnedItem _toOwnedItem(InventoryEntry entry) {
    return OwnedItem(
      entry.itemName,
      ItemRarity.values.firstWhere(
        (rarity) => rarity.name == entry.rarity,
        orElse: () => ItemRarity.common,
      ),
      entry.quantity,
      Icons.auto_awesome,
    );
  }
}
