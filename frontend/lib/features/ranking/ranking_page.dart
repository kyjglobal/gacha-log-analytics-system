import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/page_canvas.dart';

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    const players = [
      ('LunaArchive', '82', '4.93%'),
      ('AstraKim', '61', '3.72%'),
      ('DataWizard', '49', '2.91%'),
      ('KTraveler', '38', '2.47%'),
    ];
    return PageCanvas(
      title: 'Ranking',
      subtitle: 'Seasonal public acquisition records.',
      children: [
        AppCard(
          child: Column(
            children: [
              for (var i = 0; i < players.length; i++)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: i < 3
                        ? AppColors.primary
                        : AppColors.surfaceHigh,
                    child: Text('${i + 1}'),
                  ),
                  title: Text(
                    players[i].$1,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('Mythic items ${players[i].$2}'),
                  trailing: Text(
                    players[i].$3,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
