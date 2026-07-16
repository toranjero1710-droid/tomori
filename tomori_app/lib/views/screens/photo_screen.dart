import 'package:flutter/material.dart';

import '../../ui/tomori_theme.dart';
import '../../viewmodels/tomori_view_model.dart';
import '../widgets/tomori_widgets.dart';

class PhotoScreen extends StatelessWidget {
  const PhotoScreen({super.key, required this.viewModel});

  final TomoriViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ScreenPadding(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(onPressed: () => viewModel.setScreen(1), icon: const Icon(Icons.chevron_left)),
              Expanded(child: Text('写真を撮影する（7枚）', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline)),
            ],
          ),
          Text('撮影ガイドに沿って撮ってください', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          for (var i = 0; i < viewModel.photoGuides.length; i++) ...[
            _PhotoGuideRow(number: i + 1, guide: viewModel.photoGuides[i]),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 10),
          TomoriButton(label: '撮影を開始', icon: Icons.photo_camera_outlined, onPressed: () {}),
        ],
      ),
    );
  }
}

class _PhotoGuideRow extends StatelessWidget {
  const _PhotoGuideRow({required this.number, required this.guide});

  final int number;
  final dynamic guide;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFF0E9DB), shape: BoxShape.circle),
            child: Text('$number', style: const TextStyle(fontWeight: FontWeight.w700, color: TomoriColors.deepGreen)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(guide.name, style: Theme.of(context).textTheme.titleMedium)),
          Icon(guide.done ? Icons.check_circle : Icons.circle_outlined, color: guide.done ? TomoriColors.green : const Color(0xFF9B9B90)),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(guide.imagePath, width: 48, height: 42, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }
}
