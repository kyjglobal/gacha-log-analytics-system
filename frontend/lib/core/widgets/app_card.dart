import 'package:flutter/material.dart';

import '../../app/theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(title!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 18),
          ],
          child,
        ],
      ),
    );
  }
}
