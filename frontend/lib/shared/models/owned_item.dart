import 'package:flutter/material.dart';

import '../../app/theme.dart';

enum ItemRarity {
  mythic('신화', AppColors.warning),
  legendary('전설', Color(0xFFFF8A65)),
  epic('영웅', AppColors.primary),
  rare('희귀', AppColors.secondary),
  common('일반', AppColors.muted);

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
