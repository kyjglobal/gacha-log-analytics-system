import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/formatters.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/page_canvas.dart';
import '../../core/widgets/responsive_grid.dart';
import '../../shared/widgets/status_badge.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.crystals,
    required this.totalDraws,
    required this.pity,
    required this.onDraw,
  });

  final int crystals;
  final int totalDraws;
  final int pity;
  final VoidCallback onDraw;

  @override
  Widget build(BuildContext context) {
    return PageCanvas(
      title: '환영합니다',
      subtitle: '인벤토리, 획득 확률, 천장 상태와 시스템 통계를 확인하세요.',
      children: [
        ResponsiveGrid(
          minItemWidth: 210,
          children: [
            MetricCard(
              label: '보유 재화',
              value: formatNumber(crystals),
              detail: '10회 소환 가능 재화',
              icon: Icons.diamond_outlined,
              accent: AppColors.secondary,
            ),
            MetricCard(
              label: '누적 추첨',
              value: formatNumber(totalDraws),
              detail: '전체 활동 상위 18%',
              icon: Icons.auto_awesome,
              accent: AppColors.primary,
            ),
            MetricCard(
              label: '천장 진행도',
              value: '$pity / 80',
              detail: '확정 획득까지 ${80 - pity}회',
              icon: Icons.bolt,
              accent: AppColors.warning,
            ),
            const MetricCard(
              label: '신화 획득률',
              value: '1.21%',
              detail: '공식 확률 1.20%',
              icon: Icons.insights,
              accent: AppColors.success,
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final chart = const ActivityChartCard();
            final banner = FeaturedBanner(onTap: onDraw);
            if (constraints.maxWidth < 800) {
              return Column(
                children: [banner, const SizedBox(height: 16), chart],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(flex: 5, child: ActivityChartCard()),
                const SizedBox(width: 16),
                Expanded(flex: 4, child: banner),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        const RecentHistoryCard(),
      ],
    );
  }
}

class FeaturedBanner extends StatelessWidget {
  const FeaturedBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B176B), Color(0xFF102742)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: .5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StatusBadge('기간 한정 배너', AppColors.secondary),
          const Spacer(),
          const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 44),
          const SizedBox(height: 12),
          const Text(
            '천상의 궤적',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text('신화 픽업 확률 증가', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.auto_awesome, size: 17),
            label: const Text('가챠 열기'),
          ),
        ],
      ),
    );
  }
}

class ActivityChartCard extends StatelessWidget {
  const ActivityChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: '최근 활동',
      child: SizedBox(
        height: 242,
        child: CustomPaint(
          painter: LineChartPainter(
            values: const [.22, .39, .31, .58, .48, .78, .67],
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  LineChartPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final point = Offset(
        size.width * i / (values.length - 1),
        size.height * (1 - values[i]),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.secondary
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) => false;
}

class RecentHistoryCard extends StatelessWidget {
  const RecentHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      title: '최근 획득 기록',
      child: Column(
        children: [
          ListTile(title: Text('아스트라 왕관'), subtitle: Text('신화 아이템 · 2분 전')),
          Divider(color: AppColors.border),
          ListTile(title: Text('정령의 반지'), subtitle: Text('희귀 아이템 · 18분 전')),
        ],
      ),
    );
  }
}
