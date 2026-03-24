# Mobile Workspace

This workspace contains the Flutter client for the shared auth demo.

Structure:

- `lib/screens/`: register, login, and authenticated home screens
- `lib/components/`: reusable mobile form building blocks
- `lib/services/`: bearer-token auth client and local persistence
- `lib/types/`: shared mobile contracts

The mobile app uses the same backend session model as the web app, but carries it through
`Authorization: Bearer <token>`.
