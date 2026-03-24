# Backend Workspace

Place server runtime code, backend business logic, and data access code here.

Recommended lightweight structure, added only when needed:

- `types/`
- `config/`
- `repo/`
- `service/`
- `composition/`
- `runtime/`

Keep database access in `repo/`. Keep core business rules in `service/`. Put backend dependency wiring and runtime assembly in `composition/`, not in `runtime/`, handlers, controllers, or lower layers.
