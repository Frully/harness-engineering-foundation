import 'package:flutter/material.dart';

class InterfacePalette {
  static const paper = Color(0xFFF5EBDD);
  static const paperWash = Color(0xFFFFF9EF);
  static const paperDeep = Color(0xFFEADCC9);
  static const ink = Color(0xFF1A120F);
  static const inkSoft = Color.fromRGBO(26, 18, 15, 0.74);
  static const line = Color.fromRGBO(26, 18, 15, 0.16);
  static const lineStrong = Color.fromRGBO(26, 18, 15, 0.26);
  static const accent = Color(0xFFC3561B);
  static const accentDeep = Color(0xFF8F3810);
  static const accentLight = Color(0xFFE08F49);
  static const accentSoft = Color.fromRGBO(195, 86, 27, 0.12);
  static const coolSoft = Color.fromRGBO(36, 70, 118, 0.18);
  static const command = Color(0xFF181210);
  static const commandElevated = Color(0xFF211815);
  static const commandText = Color(0xFFF7EEDD);
  static const commandMuted = Color.fromRGBO(247, 238, 221, 0.68);
  static const error = Color(0xFF882D17);
}

ThemeData buildHarnessTheme() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: InterfacePalette.paper,
    colorScheme: base.colorScheme.copyWith(
      primary: InterfacePalette.accent,
      secondary: InterfacePalette.accentLight,
      surface: InterfacePalette.paperWash,
      error: InterfacePalette.error,
      onPrimary: InterfacePalette.paperWash,
      onSurface: InterfacePalette.ink,
    ),
    textTheme: base.textTheme.copyWith(
      displayMedium: const TextStyle(
        fontSize: 44,
        height: 0.92,
        fontWeight: FontWeight.w700,
        color: InterfacePalette.ink,
        letterSpacing: -1.2,
      ),
      headlineSmall: const TextStyle(
        fontSize: 24,
        height: 1.05,
        fontWeight: FontWeight.w700,
        color: InterfacePalette.ink,
      ),
      titleLarge: const TextStyle(
        fontSize: 18,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: InterfacePalette.ink,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        height: 1.65,
        fontWeight: FontWeight.w500,
        color: InterfacePalette.inkSoft,
      ),
      bodyMedium: const TextStyle(
        fontSize: 15,
        height: 1.6,
        color: InterfacePalette.inkSoft,
      ),
      bodySmall: const TextStyle(
        fontSize: 13,
        height: 1.55,
        color: InterfacePalette.inkSoft,
      ),
      labelMedium: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.8,
        color: InterfacePalette.inkSoft,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.8,
        color: InterfacePalette.commandMuted,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: InterfacePalette.accentDeep,
        foregroundColor: InterfacePalette.paperWash,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: InterfacePalette.accentDeep,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

class CommandShell extends StatelessWidget {
  const CommandShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [InterfacePalette.paperDeep, InterfacePalette.paperWash],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.82, -0.92),
                    radius: 1.1,
                    colors: [
                      Color.fromRGBO(195, 86, 27, 0.26),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.95, 0.12),
                    radius: 1,
                    colors: [InterfacePalette.coolSoft, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class CommandPanel extends StatelessWidget {
  const CommandPanel({
    super.key,
    required this.child,
    this.commandSurface = false,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final bool commandSurface;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: commandSurface
              ? InterfacePalette.lineStrong
              : InterfacePalette.line,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: commandSurface
              ? const [
                  InterfacePalette.commandElevated,
                  InterfacePalette.command,
                ]
              : const [
                  Color.fromRGBO(255, 255, 255, 0.76),
                  Color.fromRGBO(255, 250, 242, 0.92),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: commandSurface
                ? const Color.fromRGBO(18, 12, 10, 0.28)
                : const Color.fromRGBO(46, 27, 13, 0.14),
            blurRadius: commandSurface ? 46 : 38,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class CommandStrip extends StatelessWidget {
  const CommandStrip({super.key, required this.items, this.inverse = false});

  final List<String> items;
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: inverse
                    ? const Color.fromRGBO(255, 255, 255, 0.06)
                    : const Color.fromRGBO(255, 255, 255, 0.42),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: inverse
                      ? const Color.fromRGBO(247, 238, 221, 0.12)
                      : InterfacePalette.line,
                ),
              ),
              child: Text(
                item,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: inverse
                      ? InterfacePalette.commandMuted
                      : InterfacePalette.inkSoft,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class SignalRail extends StatelessWidget {
  const SignalRail({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.58),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: InterfacePalette.line),
              ),
              child: Text(
                item,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: InterfacePalette.ink,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class LedgerTile extends StatelessWidget {
  const LedgerTile({
    super.key,
    required this.label,
    required this.title,
    required this.description,
  });

  final String label;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.46),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: InterfacePalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
