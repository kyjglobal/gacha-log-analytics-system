import 'dart:math';

import 'package:flutter/material.dart';

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 220,
  });

  final List<Widget> children;
  final double minItemWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = max(
          1,
          min(children.length, (constraints.maxWidth / minItemWidth).floor()),
        );
        const spacing = 14.0;
        final width = (constraints.maxWidth - spacing * (count - 1)) / count;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(width: width, child: child))
              .toList(),
        );
      },
    );
  }
}
