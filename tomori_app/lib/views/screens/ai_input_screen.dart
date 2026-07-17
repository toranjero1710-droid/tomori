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
          const SizedBox(height: 30),
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: viewModel.isRecording ? const Color(0xFFDDE9CF) : TomoriColors.lightGreen,
              boxShadow: [
                BoxShadow(
                  color: TomoriColors.green.withValues(alpha: 0.18),
                  blurRadius: viewModel.isRecording ? 36 : 20,
                  spreadRadius: viewModel.isRecording ? 18 : 8,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.mic, size: 58, color: TomoriColors.deepGreen),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            viewModel.recordingTime,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: TomoriColors.text,
            ),
          ),
          Text(
            viewModel.isRecording ? '録音中です' : '音声メモ保存済み',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          SoftCard(
            padding: const EdgeInsets.all(14),
            child: Text(viewModel.voiceMemo, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(height: 18),
          TomoriButton(
            label: viewModel.isGeneratingAi ? 'AI生成中' : 'AIが内容を作成する',
            icon: Icons.auto_awesome,
            onPressed: viewModel.isGeneratingAi ? () {} : viewModel.createAiDraft,
          ),
          if (viewModel.aiMessage.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              viewModel.aiMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: TomoriColors.green, fontWeight: FontWeight.w700),
            ),
          ],
          if (viewModel.aiError.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              viewModel.aiError,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 10),
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
