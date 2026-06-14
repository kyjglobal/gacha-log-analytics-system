import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/page_canvas.dart';
import '../../core/widgets/responsive_grid.dart';
import '../../shared/widgets/status_badge.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageCanvas(
      title: 'Admin Backoffice',
      subtitle:
          'Monitor users, draw logs, anomalies, and manual item adjustments.',
      children: [
        const ResponsiveGrid(
          minItemWidth: 220,
          children: [
            MetricCard(
              label: 'Total users',
              value: '24,891',
              detail: 'Today +184',
              icon: Icons.people_outline,
              accent: AppColors.secondary,
            ),
            MetricCard(
              label: 'Draws today',
              value: '1.82M',
              detail: '1,264 per minute',
              icon: Icons.bolt,
              accent: AppColors.primary,
            ),
            MetricCard(
              label: 'Anomaly logs',
              value: '17',
              detail: 'Waiting for review',
              icon: Icons.warning_amber_rounded,
              accent: AppColors.danger,
            ),
          ],
        ),
        const SizedBox(height: 20),
        AppCard(
          title: 'Recent anomaly logs',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Log ID')),
                DataColumn(label: Text('User')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Time')),
                DataColumn(label: Text('Status')),
              ],
              rows: const [
                DataRow(
                  cells: [
                    DataCell(Text('#GL-918201')),
                    DataCell(Text('user_1842')),
                    DataCell(Text('Duplicate request')),
                    DataCell(Text('18:42:11')),
                    DataCell(StatusBadge('Needs review', AppColors.danger)),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('#GL-918044')),
                    DataCell(Text('user_0391')),
                    DataCell(Text('Rate drift')),
                    DataCell(Text('18:31:04')),
                    DataCell(StatusBadge('Analyzing', AppColors.warning)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
