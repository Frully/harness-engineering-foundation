import type { User } from '../types/auth';

export function HomePage({
  user,
  onLogout,
}: {
  user: User;
  onLogout: () => Promise<void>;
}) {
  return (
    <main className="dashboard-shell">
      <section className="dashboard-panel">
        <p className="eyebrow">Authenticated signal</p>
        <h1>Cookie session restored.</h1>
        <p className="hero-copy">
          This shell recovered the current operator via <code>GET /api/me</code> while keeping the
          session token inaccessible to JavaScript.
        </p>

        <div className="stats-grid">
          <article>
            <span className="label">Operator</span>
            <strong>{user.email}</strong>
          </article>
          <article>
            <span className="label">Mode</span>
            <strong>Web cookie + CSRF</strong>
          </article>
          <article>
            <span className="label">Session boundary</span>
            <strong>Shared backend session table</strong>
          </article>
        </div>

        <button className="primary-button" onClick={() => void onLogout()} type="button">
          Logout and revoke current session
        </button>
      </section>
    </main>
  );
}
