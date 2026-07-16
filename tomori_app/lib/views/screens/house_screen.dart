import 'package:flutter/material.dart';

import '../../ui/tomori_theme.dart';
import '../../viewmodels/tomori_view_model.dart';
import '../widgets/tomori_widgets.dart';

class HouseScreen extends StatelessWidget {
  const HouseScreen({super.key, required this.viewModel});

  final TomoriViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final customer = viewModel.customers.first;
    final actions = [
      _HouseAction(Icons.photo_camera_outlined, '写真', () => viewModel.setScreen(2)),
      _HouseAction(Icons.mail_outline, 'ともり便り', () => viewModel.setScreen(4)),
      _HouseAction(Icons.menu_book_outlined, '一年の便り', () => viewModel.setScreen(5)),
      _HouseAction(Icons.note_alt_outlined, 'お家ノート', () {}),
      _HouseAction(Icons.phone, '電話', () {}),
      _HouseAction(Icons.chat_bubble_outline, 'LINE', () {}),
    ];

    return ScreenPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(onPressed: () => viewModel.setScreen(0), icon: const Icon(Icons.chevron_left)),
              Expanded(child: Text(customer.name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: TomoriColors.lightGreen, borderRadius: BorderRadius.circular(999)),
                child: const Text('基本プラン', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: TomoriColors.deepGreen)),
              ),
            ],
          ),
          Center(child: Text('次回訪問：${customer.nextVisit}', style: Theme.of(context).textTheme.bodySmall)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(customer.imagePath, width: double.infinity, height: 190, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.06,
            children: actions.map((item) => SoftCard(
              onTap: item.onTap,
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: TomoriColors.deepGreen, size: 30),
                  const SizedBox(height: 8),
                  Text(item.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 14),
          SoftCard(
            color: TomoriColors.lightGreen,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('今日のひとことメモ', style: TextStyle(fontWeight: FontWeight.w700, color: TomoriColors.deepGreen)),
                      SizedBox(height: 6),
                      Text('玄関の紫陽花がきれいに咲いていました。'),
                    ],
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit, color: TomoriColors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HouseAction {
  const _HouseAction(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}
