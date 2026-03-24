# Auth Model

This document describes the authentication model used by the runnable harness demo.

## Summary

The demo uses one shared server-side session model for both web and mobile:

- sessions are created and validated by the Go backend
- session credentials are opaque random tokens, not JWTs
- the database stores token hashes, not raw tokens
- web and mobile share the same session table and the same logout semantics

The transport differs by runtime:

- web uses an `HttpOnly` cookie plus a readable CSRF token
- mobile uses `Authorization: Bearer <token>`

## Session model

Each successful register or login creates a new session record with:

- `user_id`
- `token_hash`
- `csrf_token`
- `client_type`
- `expires_at`
- `revoked_at`
- `created_at`
- `last_used_at`

Important behavior:

- sessions are server-revocable
- multiple devices or clients can hold separate sessions at the same time
- logging out revokes only the current session
- expired or revoked sessions are treated as unauthorized

## Runtime behavior

### Web

Web uses an `HttpOnly` cookie transport with CSRF protection:

- the backend sets an `HttpOnly` session cookie
- the cookie is issued with `SameSite=Lax`
- the cookie `Secure` attribute depends on environment configuration
- the browser sends that cookie automatically on protected requests
- the frontend never reads the raw session token
- the backend also returns a readable `csrfToken`
- the frontend stores that CSRF token locally and sends it on protected write operations

The web shell restores auth state by calling `GET /api/me` instead of reading any session token directly.

### Mobile

Mobile uses the same session model through a bearer token transport:

- register and login return `token`
- the Flutter client stores that token locally
- protected requests send `Authorization: Bearer <token>`
- logout revokes the current bearer-backed session

The mobile client restores auth state by reading the stored token and then calling `GET /api/me`.

## Transport parity rule

The backend enforces transport parity:

- web-created sessions must be used through the cookie transport
- mobile-created sessions must be used through the bearer transport

This keeps the demo honest about runtime-specific auth constraints while still sharing one session model.

## CSRF behavior

CSRF protection applies only to cookie-backed web sessions:

- protected write requests from web must include `X-CSRF-Token`
- missing or invalid CSRF tokens fail with `403`
- bearer requests do not use CSRF protection

## Public auth endpoints

### `POST /api/auth/register`

Input:

- `email`
- `password`
- `confirmPassword`
- register passwords must be at least 8 characters and include uppercase, lowercase, number, and symbol
- mobile clients should send `X-Client-Type: mobile`

Response:

- web: `user`, `csrfToken`, and a session cookie
- mobile: `user`, `token`

### `POST /api/auth/login`

Input:

- `email`
- `password`
- mobile clients should send `X-Client-Type: mobile`

Response:

- web: `user`, `csrfToken`, and a session cookie
- mobile: `user`, `token`

### `POST /api/auth/logout`

Auth requirements:

- web: valid session cookie plus `X-CSRF-Token`
- mobile: valid `Authorization: Bearer <token>`

Response:

- `204 No Content` on success

### `GET /api/me`

Auth requirements:

- valid session cookie or valid bearer token

Response:

- `user`

### `GET /healthz`

Response:

- service health status

## Error behavior

Current user-facing auth errors include:

- `email already registered`
- `email, password, and password confirmation are required`
- `invalid email or password`
- `password confirmation does not match`
- `password must be at least 8 characters and include uppercase, lowercase, number, and symbol`
- `invalid csrf token`
- `unauthorized`

These messages are intended to be directly observable in tests and smoke logs.

## Non-goals for this demo baseline

The current auth model does not include:

- refresh tokens
- MFA
- email verification
- password reset
- role-based access control
- social login

Those can be added later, but they are intentionally outside the current baseline.
