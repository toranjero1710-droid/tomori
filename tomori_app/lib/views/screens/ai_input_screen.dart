import 'package:flutter/material.dart';

import '../../ui/tomori_theme.dart';
import '../../viewmodels/tomori_view_model.dart';
import '../widgets/tomori_widgets.dart';

class AiInputScreen extends StatelessWidget {
  const AiInputScreen({super.key, required this.viewModel});

  final TomoriViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ScreenPadding(
      child: Column(
        children: [
          Text('音声で入力する', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('今日の様子を話してください', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 44),
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: viewModel.isRecording ? const Color(0xFFDDE9CF) : TomoriColors.lightGreen,
              boxShadow: [
                BoxShadow(color: TomoriColors.green.withValues(alpha: 0.18), blurRadius: viewModel.isRecording ? 36 : 20, spreadRadius: viewModel.isRecording ? 18 : 8),
              ],
            ),
            child: Center(
              child: Container(
                width: 94,
                height: 94,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD4E3C3)),
                child: const Icon(Icons.mic, size: 54, color: TomoriColors.deepGreen),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(viewModel.recordingTime, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: TomoriColors.text)),
          const SizedBox(height: 4),
          Text(viewModel.isRecording ? '録音中です' : 'タップして開始', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 36),
          TomoriButton(
            label: 'AIが内容を作成する',
            icon: Icons.auto_awesome,
            onPressed: viewModel.createAiDraft,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: viewModel.toggleRecording,
            icon: Icon(viewModel.isRecording ? Icons.stop_circle_outlined : Icons.mic_none),
            label: Text(viewModel.isRecording ? '録音停止' : '録音開始'),
          ),
        ],
      ),
    );
  }
}
