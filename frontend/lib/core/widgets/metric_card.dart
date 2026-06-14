import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'app_card.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(detail, style: TextStyle(color: accent, fontSize: 11)),
        ],
      ),
    );
  }
}
