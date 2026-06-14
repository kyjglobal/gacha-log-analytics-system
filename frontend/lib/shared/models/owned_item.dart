import 'package:flutter/material.dart';

import '../../app/theme.dart';

enum ItemRarity {
  mythic('Mythic', AppColors.warning),
  legendary('Legendary', Color(0xFFFF8A65)),
  epic('Epic', AppColors.primary),
  rare('Rare', AppColors.secondary),
  common('Common', AppColors.muted);

  const ItemRarity(this.label, this.color);

  final String label;
  final Color color;
}

class OwnedItem {
  const OwnedItem(this.name, this.rarity, this.quantity, this.icon);

  final String name;
  final ItemRarity rarity;
  final int quantity;
  final IconData icon;

  OwnedItem copyWith({int? quantity}) {
    return OwnedItem(name, rarity, quantity ?? this.quantity, icon);
  }
}
