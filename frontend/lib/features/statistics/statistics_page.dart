import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/formatters.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/page_canvas.dart';
import '../../core/widgets/responsive_grid.dart';
import '../../shared/widgets/status_badge.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key, required this.totalDraws});

  final int totalDraws;

  @override
  Widget build(BuildContext context) {
    return PageCanvas(
      title: 'Probability Analytics',
      subtitle: 'Compare official rates with observed acquisition logs.',
      children: [
        ResponsiveGrid(
          minItemWidth: 240,
          children: [
            MetricCard(
              label: 'Sample size',
              value: formatNumber(totalDraws),
              detail: 'Validated personal logs',
              icon: Icons.dataset_outlined,
              accent: AppColors.secondary,
            ),
            const MetricCard(
              label: 'Mythic deviation',
              value: '+0.01%p',
              detail: 'Against official rate',
              icon: Icons.balance,
              accent: AppColors.success,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const ProbabilityTable(),
      ],
    );
  }
}

class ProbabilityTable extends StatelessWidget {
  const ProbabilityTable({super.key});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('Mythic', '1.20%', '1.21%', '+0.01%p', AppColors.warning),
      ('Legendary', '5.00%', '4.96%', '-0.04%p', Color(0xFFFF8A65)),
      ('Epic', '15.00%', '15.18%', '+0.18%p', AppColors.primary),
      ('Rare', '30.00%', '29.82%', '-0.18%p', AppColors.secondary),
      ('Common', '48.80%', '48.83%', '+0.03%p', AppColors.muted),
    ];
    return AppCard(
      title: 'Rate comparison',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Rarity')),
            DataColumn(label: Text('Official')),
            DataColumn(label: Text('Observed')),
            DataColumn(label: Text('Delta')),
          ],
          rows: rows
              .map(
                (row) => DataRow(
                  cells: [
                    DataCell(StatusBadge(row.$1, row.$5)),
                    DataCell(Text(row.$2)),
                    DataCell(Text(row.$3)),
                    DataCell(Text(row.$4)),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
