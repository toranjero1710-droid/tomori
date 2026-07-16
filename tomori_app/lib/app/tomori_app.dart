import 'package:flutter/material.dart';

import '../ui/tomori_theme.dart';
import '../viewmodels/tomori_view_model.dart';
import '../views/main_shell.dart';

class TomoriApp extends StatefulWidget {
  const TomoriApp({super.key});

  @override
  State<TomoriApp> createState() => _TomoriAppState();
}

class _TomoriAppState extends State<TomoriApp> {
  late final TomoriViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = TomoriViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ともりアプリ',
      debugShowCheckedModeBanner: false,
      theme: TomoriTheme.light(),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: const TextScaler.linear(1)),
          child: child!,
        );
      },
      home: MainShell(viewModel: viewModel),
    );
  }
}
