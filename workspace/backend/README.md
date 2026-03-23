# Backend Workspace

Place server runtime code, backend business logic, and data access code here.

Recommended lightweight structure, added only when needed:

- `types/`
- `config/`
- `repo/`
- `service/`
- `runtime/`

Keep database access in `repo/`. Keep core business rules in `service/`, not in runtime handlers or controllers.
