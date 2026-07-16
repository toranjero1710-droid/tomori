import 'package:flutter/material.dart';

import '../../viewmodels/tomori_view_model.dart';
import '../widgets/tomori_widgets.dart';

class AnnualLetterScreen extends StatelessWidget {
  const AnnualLetterScreen({super.key, required this.viewModel});

  final TomoriViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ScreenPadding(
      child: Column(
        children: [
          Text('一年の便り 2027⌄', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('今年の思い出をまとめます', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.92,
            children: viewModel.seasons.map((season) => SoftCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      child: Image.asset(season.imagePath, fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(season.name, style: Theme.of(context).textTheme.titleMedium),
                        Text(season.months, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 18),
          TomoriButton(label: 'PDFを作成する', icon: Icons.picture_as_pdf_outlined, onPressed: () {}),
        ],
      ),
    );
  }
}
