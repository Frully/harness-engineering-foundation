# Backend Workspace

This workspace contains the Go + SQLite backend that powers the shared auth demo.

Structure:

- `types/`: request and response contracts plus auth context types
- `config/`: runtime configuration and environment loading
- `repo/`: SQLite persistence for users and sessions
- `service/`: auth rules, password hashing, session issuance, CSRF validation
- `composition/`: dependency wiring
- `runtime/`: HTTP transport, middleware, and route handlers

The backend supports two transports on the same server-side session model:

- Web uses an HttpOnly session cookie plus a readable CSRF token
- Mobile uses a Bearer token backed by the same session table
