import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/display_text.dart';
import '../../domain/community_post.dart';

class ProbabilityResultCard extends StatelessWidget {
  const ProbabilityResultCard({super.key, required this.certification});

  final ProbabilityCertification certification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF251447), Color(0xFF102742)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified, color: AppColors.success),
              SizedBox(width: 8),
              Text('검증된 확률 인증', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            itemDisplayName(certification.itemName),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _Metric('등급', rarityLabel(certification.itemRarity)),
              _Metric('누적 추첨', '${certification.drawCount}회'),
              _Metric('공식 확률', _percent(certification.officialProbability)),
              _Metric('개인 확률', _percent(certification.personalProbability)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '획득 시각 ${certification.obtainedAt.toLocal()}',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _percent(double value) => '${(value * 100).toStringAsFixed(2)}%';
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
