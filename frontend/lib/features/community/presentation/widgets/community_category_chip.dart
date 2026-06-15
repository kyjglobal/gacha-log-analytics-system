import 'package:flutter/material.dart';

import '../../domain/community_category.dart';

class CommunityCategoryChip extends StatelessWidget {
  const CommunityCategoryChip({
    super.key,
    required this.category,
    this.selected = false,
    this.onSelected,
  });

  final CommunityCategory category;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(category.label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}
