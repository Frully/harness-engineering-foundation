import 'package:flutter/material.dart';

import '../components/interface_theme.dart';
import '../types/auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user, required this.onLogout});

  final User user;
  final Future<void> Function() onLogout;

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
                    items: [
                      'AUTHENTICATED SIGNAL',
                      'BEARER SESSION LIVE',
                      'OPERATOR ONLINE',
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Session restored.',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your account is active in this app.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 18),
                  const SignalRail(
                    items: [
                      'Shared session table',
                      'Bearer restore',
                      'Handheld command surface',
                    ],
                  ),
                  const SizedBox(height: 16),
                  LedgerTile(
                    label: 'Operator',
                    title: user.email,
                    description:
                        'This runtime translates the same product identity as the web shell into a stacked mobile command surface.',
                  ),
                ],
              ),
            );

            final controlPanel = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CommandPanel(
                  commandSurface: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CommandStrip(
                        inverse: true,
                        items: [
                          'CONTROL TELEMETRY',
                          'TOKEN RESTORE',
                          'LIVE MODE',
                        ],
                      ),
                      SizedBox(height: 14),
                      _TelemetryRail(),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  key: const Key('logoutButton'),
                  onPressed: () => onLogout(),
                  child: const Text('Log out'),
                ),
              ],
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
                          Expanded(flex: 9, child: controlPanel),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          heroPanel,
                          const SizedBox(height: 14),
                          controlPanel,
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

class _TelemetryRail extends StatelessWidget {
  const _TelemetryRail();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        _TelemetryChip(label: 'Transport', value: 'Bearer'),
        _TelemetryChip(label: 'Session', value: 'Opaque server state'),
        _TelemetryChip(label: 'Rule', value: 'Web-aligned shell'),
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
        color: const Color.fromRGBO(255, 255, 255, 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(247, 238, 221, 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: InterfacePalette.commandText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
