# Frontend Workspace

This workspace contains the React + TypeScript web shell for the shared auth demo.

Structure:

- `src/components/`: reusable UI building blocks
- `src/pages/`: login, register, and authenticated home views
- `src/services/`: cookie-aware API calls and CSRF token persistence
- `src/types/`: shared frontend contracts

The web app uses real browser constraints:

- the session token stays in an HttpOnly cookie
- the frontend restores auth state through `GET /api/me`
- the only readable client-side credential is the CSRF token
