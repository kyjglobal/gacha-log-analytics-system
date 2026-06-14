import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/widgets/page_canvas.dart';
import '../../core/widgets/responsive_grid.dart';
import '../../shared/models/owned_item.dart';
import '../../shared/widgets/inventory_card.dart';

class GachaPage extends StatelessWidget {
  const GachaPage({
    super.key,
    required this.crystals,
    required this.pity,
    required this.onDraw,
  });

  final int crystals;
  final int pity;
  final ValueChanged<int> onDraw;

  @override
  Widget build(BuildContext context) {
    return PageCanvas(
      title: 'Celestial Trace',
      subtitle:
          'Every draw records base probability, applied probability, and pity state.',
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 440),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF251447), Color(0xFF101827), Color(0xFF083344)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withValues(alpha: .55)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 72,
                color: AppColors.secondary,
              ),
              const SizedBox(height: 22),
              const Text(
                'CELESTIAL TRACE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 10),
              const Text('Mythic base rate 1.2% · guaranteed within 80 pulls'),
              const SizedBox(height: 22),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pity progress'),
                        Text(
                          '$pity / 80',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: pity / 80,
                        minHeight: 10,
                        backgroundColor: AppColors.surface,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  DrawButton(
                    label: 'Draw 1',
                    cost: 160,
                    enabled: crystals >= 160,
                    onPressed: () => onDraw(1),
                  ),
                  DrawButton(
                    label: 'Draw 10',
                    cost: 1600,
                    emphasized: true,
                    enabled: crystals >= 1600,
                    onPressed: () => onDraw(10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DrawButton extends StatelessWidget {
  const DrawButton({
    super.key,
    required this.label,
    required this.cost,
    required this.enabled,
    required this.onPressed,
    this.emphasized = false,
  });

  final String label;
  final int cost;
  final bool enabled;
  final VoidCallback onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      style: FilledButton.styleFrom(
        backgroundColor: emphasized ? AppColors.primary : AppColors.surfaceHigh,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text('Cost $cost', style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class DrawResultDialog extends StatelessWidget {
  const DrawResultDialog({super.key, required this.results});

  final List<OwnedItem> results;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Draw Results',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 22),
              Flexible(
                child: SingleChildScrollView(
                  child: ResponsiveGrid(
                    minItemWidth: 130,
                    children: results
                        .map(
                          (item) => SizedBox(
                            height: 165,
                            child: InventoryCard(item: item),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
