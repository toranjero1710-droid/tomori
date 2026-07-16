import 'package:flutter/material.dart';

import '../../ui/tomori_theme.dart';
import '../../viewmodels/tomori_view_model.dart';
import '../widgets/tomori_widgets.dart';

class TomoriLetterScreen extends StatelessWidget {
  const TomoriLetterScreen({super.key, required this.viewModel});

  final TomoriViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: viewModel.note);
    return ScreenPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('ともり便り（下書き）', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('AIが作成した下書きです', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 18),
          SoftCard(
            color: const Color(0xFFFFFAEF),
            padding: const EdgeInsets.all(20),
            child: Text(viewModel.aiDraft, style: const TextStyle(fontSize: 15, height: 1.78, color: TomoriColors.text)),
          ),
          const SizedBox(height: 16),
          Text('一言追加する（任意）', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 4,
            maxLength: 200,
            onChanged: viewModel.updateNote,
            decoration: InputDecoration(
              hintText: '自由にご入力ください',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: TomoriColors.line)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: TomoriColors.line)),
            ),
          ),
          const SizedBox(height: 8),
          TomoriButton(label: '送信する（確認画面へ）', icon: Icons.send_outlined, onPressed: viewModel.saveLetterNote),
          const SizedBox(height: 12),
          if (viewModel.letterSaved)
            const Text('巡回履歴へ保存済みです。', textAlign: TextAlign.center, style: TextStyle(color: TomoriColors.green, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
