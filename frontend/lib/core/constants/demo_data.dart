import 'package:flutter/material.dart';

import '../../shared/models/owned_item.dart';

class DemoData {
  const DemoData._();

  static const initialCrystals = 12840;
  static const totalDraws = 248;
  static const pity = 62;

  static const inventory = [
    OwnedItem('아스트라 왕관', ItemRarity.mythic, 1, Icons.auto_awesome),
    OwnedItem('심연의 고서', ItemRarity.legendary, 2, Icons.menu_book),
    OwnedItem('별빛 검', ItemRarity.epic, 1, Icons.gavel),
    OwnedItem('정령의 반지', ItemRarity.rare, 4, Icons.circle_outlined),
    OwnedItem('마나 물약', ItemRarity.common, 18, Icons.science),
    OwnedItem('수호자의 방패', ItemRarity.epic, 2, Icons.shield),
  ];
}
