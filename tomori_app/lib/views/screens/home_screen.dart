import 'package:flutter/material.dart';

import '../../ui/tomori_theme.dart';
import '../../viewmodels/tomori_view_model.dart';
import '../widgets/tomori_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});

  final TomoriViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final count = viewModel.customers.length;
    return ScreenPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('☀', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 10),
              Text('おはようございます！', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 18),
          Text('今日は\n$count件のお家へ会いに行く予定です。', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 18),
          if (viewModel.dataLoaded && viewModel.customers.isEmpty)
            const SoftCard(
              child: Text('保存済みのお家データはありません。'),
            ),
          for (final customer in viewModel.customers) ...[
            SoftCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.asset(customer.imagePath, width: 94, height: 94, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customer.displayName, style: Theme.of(context).textTheme.titleMedium),
                        Text(customer.time, style: Theme.of(context).textTheme.headlineMedium),
                        Text(customer.address, style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TomoriButton(
                            label: 'お家へ会いに行く',
                            icon: Icons.chevron_right,
                            onPressed: () => viewModel.setScreen(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _CountCard(label: '今週', value: '$count件')),
              SizedBox(width: 12),
              Expanded(child: _CountCard(label: '今月', value: '$count件')),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: TomoriColors.deepGreen)),
        ],
      ),
    );
  }
}
