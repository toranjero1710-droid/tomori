import 'package:flutter/material.dart';

import '../ui/tomori_theme.dart';
import '../viewmodels/tomori_view_model.dart';
import 'screens/ai_input_screen.dart';
import 'screens/annual_letter_screen.dart';
import 'screens/home_screen.dart';
import 'screens/house_screen.dart';
import 'screens/photo_screen.dart';
import 'screens/tomori_letter_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.viewModel});

  final TomoriViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final child = _PhoneSurface(
                child: _ScreenSwitcher(viewModel: viewModel),
              );
              if (constraints.maxWidth < 620) return child;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430, maxHeight: 920),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(34),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: TomoriColors.cream,
                        border: Border.all(color: const Color(0xFF1C1C1C), width: 3),
                        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 26, offset: Offset(0, 12))],
                      ),
                      child: child,
                    ),
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: _BottomNav(viewModel: viewModel),
        );
      },
    );
  }
}

class _PhoneSurface extends StatelessWidget {
  const _PhoneSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TomoriColors.cream,
      child: SafeArea(
        bottom: false,
        child: child,
      ),
    );
  }
}

class _ScreenSwitcher extends StatelessWidget {
  const _ScreenSwitcher({required this.viewModel});

  final TomoriViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(viewModel: viewModel),
      HouseScreen(viewModel: viewModel),
      PhotoScreen(viewModel: viewModel),
      AiInputScreen(viewModel: viewModel),
      TomoriLetterScreen(viewModel: viewModel),
      AnnualLetterScreen(viewModel: viewModel),
    ];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.02, 0.02), end: Offset.zero).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(viewModel.currentIndex),
        child: screens[viewModel.currentIndex],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.viewModel});

  final TomoriViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final navIndex = switch (viewModel.currentIndex) {
      0 => 0,
      1 || 2 => 1,
      3 => 2,
      4 => 3,
      _ => 4,
    };
    return NavigationBar(
      height: 72,
      backgroundColor: TomoriColors.paper,
      indicatorColor: TomoriColors.lightGreen,
      selectedIndex: navIndex,
      onDestinationSelected: (index) {
        final target = switch (index) {
          0 => 0,
          1 => 1,
          2 => 3,
          3 => 4,
          _ => 5,
        };
        viewModel.setScreen(target);
      },
      destinations: [
        const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'ホーム'),
        const NavigationDestination(icon: Icon(Icons.house_outlined), selectedIcon: Icon(Icons.house), label: 'お家'),
        NavigationDestination(
          icon: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: TomoriColors.green),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
          label: '',
        ),
        const NavigationDestination(icon: Icon(Icons.article_outlined), selectedIcon: Icon(Icons.article), label: '便り'),
        const NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.auto_stories), label: '設定'),
      ],
    );
  }
}
