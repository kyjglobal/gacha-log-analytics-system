import 'package:flutter/material.dart';

import '../../shared/models/owned_item.dart';

class DemoData {
  const DemoData._();

  static const initialCrystals = 12840;
  static const totalDraws = 248;
  static const pity = 62;

  static const inventory = [
    OwnedItem('Astra Crown', ItemRarity.mythic, 1, Icons.auto_awesome),
    OwnedItem('Abyss Codex', ItemRarity.legendary, 2, Icons.menu_book),
    OwnedItem('Starblade', ItemRarity.epic, 1, Icons.gavel),
    OwnedItem('Spirit Ring', ItemRarity.rare, 4, Icons.circle_outlined),
    OwnedItem('Mana Potion', ItemRarity.common, 18, Icons.science),
    OwnedItem('Guardian Shield', ItemRarity.epic, 2, Icons.shield),
  ];
}
