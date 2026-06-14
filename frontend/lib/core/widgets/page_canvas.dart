import 'package:flutter/material.dart';

class PageCanvas extends StatelessWidget {
  const PageCanvas({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width < 600 ? 16 : 28,
        vertical: 28,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 14,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (actions.isNotEmpty)
                    Row(mainAxisSize: MainAxisSize.min, children: actions),
                ],
              ),
              const SizedBox(height: 28),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
