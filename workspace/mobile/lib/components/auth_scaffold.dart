import 'package:flutter/material.dart';

import 'interface_theme.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.eyebrow,
    required this.summary,
    required this.footerLabel,
    required this.footerAction,
    required this.onSwitch,
    required this.child,
  });

  final String title;
  final String eyebrow;
  final String summary;
  final String footerLabel;
  final String footerAction;
  final VoidCallback onSwitch;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommandShell(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useSplit = constraints.maxWidth >= 760;

            final heroPanel = CommandPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CommandStrip(
                    items: ['MOBILE NODE', 'BEARER AUTH', 'HANDHELD CONTROL'],
                  ),
                  const SizedBox(height: 18),
                  Text(eyebrow, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 12),
                  Text(title, style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 14),
                  Text(summary, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 18),
                  const SignalRail(
                    items: [
                      'Shared sessions',
                      'Bearer restore',
                      'Mobile smoke visible',
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _CompactTelemetryRail(),
                ],
              ),
            );

            final formPanel = CommandPanel(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CommandStrip(
                    items: ['AUTH FLOW', 'OPERATOR ENTRY', 'TOKEN ISSUE'],
                  ),
                  const SizedBox(height: 18),
                  child,
                  const SizedBox(height: 18),
                  TextButton(
                    key: const Key('switchModeButton'),
                    onPressed: onSwitch,
                    child: Text('$footerLabel $footerAction'),
                  ),
                ],
              ),
            );

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: useSplit
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 11, child: heroPanel),
                          const SizedBox(width: 14),
                          Expanded(flex: 9, child: formPanel),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          heroPanel,
                          const SizedBox(height: 14),
                          formPanel,
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CompactTelemetryRail extends StatelessWidget {
  const _CompactTelemetryRail();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        _TelemetryChip(label: 'Transport', value: 'Bearer'),
        _TelemetryChip(label: 'State', value: 'Shared session'),
        _TelemetryChip(label: 'Role', value: 'Web-aligned'),
      ],
    );
  }
}

class _TelemetryChip extends StatelessWidget {
  const _TelemetryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 148),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InterfacePalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: InterfacePalette.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
