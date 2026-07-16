import 'package:flutter/material.dart';

import '../../ui/tomori_theme.dart';

class TomoriButton extends StatelessWidget {
  const TomoriButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: filled ? TomoriColors.green : TomoriColors.paper,
        foregroundColor: filled ? Colors.white : TomoriColors.deepGreen,
        elevation: filled ? 2 : 0,
        side: filled ? null : const BorderSide(color: TomoriColors.line),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = TomoriColors.paper,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TomoriColors.line),
        boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: card,
    );
  }
}

class ScreenPadding extends StatelessWidget {
  const ScreenPadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
      child: child,
    );
  }
}
