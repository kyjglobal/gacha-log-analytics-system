import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../models/owned_item.dart';

class InventoryCard extends StatelessWidget {
  const InventoryCard({super.key, required this.item});

  final OwnedItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [item.rarity.color.withValues(alpha: .18), AppColors.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: item.rarity.color.withValues(alpha: .5)),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              'x${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const Spacer(),
          Icon(item.icon, size: 58, color: item.rarity.color),
          const Spacer(),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          Text(
            item.rarity.label,
            style: TextStyle(color: item.rarity.color, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
