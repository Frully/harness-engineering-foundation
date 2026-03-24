import type { User } from '../types/auth';

export function HomePage({
  user,
  onLogout,
}: {
  user: User;
  onLogout: () => Promise<void>;
}) {
  return (
    <main className="command-shell dashboard-shell">
      <section className="panel dashboard-hero-panel">
        <div className="hero-topline">
          <div className="command-strip">
            <span>AUTHENTICATED SIGNAL</span>
            <span>COOKIE SESSION LIVE</span>
            <span>OPERATOR ONLINE</span>
          </div>
          <span className="command-badge">SESSION / ACTIVE</span>
        </div>

        <div className="dashboard-grid">
          <div className="dashboard-copy">
            <p className="eyebrow">Authenticated signal</p>
            <h1>Cookie session restored.</h1>
            <p className="hero-copy">
              This shell recovered the current operator via{' '}
              <code>GET /api/me</code> while keeping the session token
              inaccessible to JavaScript.
            </p>

            <div className="signal-rail">
              <span>Server session ledger</span>
              <span>Protected writes</span>
              <span>Observable smoke path</span>
            </div>
          </div>

          <aside className="monitor-panel" aria-label="Session telemetry">
            <div className="monitor-strip">Control telemetry</div>
            <dl className="monitor-grid">
              <div>
                <dt>Operator</dt>
                <dd>{user.email}</dd>
              </div>
              <div>
                <dt>Mode</dt>
                <dd>Web cookie + CSRF</dd>
              </div>
              <div>
                <dt>Session boundary</dt>
                <dd>Shared backend session table</dd>
              </div>
              <div>
                <dt>Protection</dt>
                <dd>HttpOnly cookie inaccessible to JS</dd>
              </div>
            </dl>
            <ul className="terminal-list" aria-label="Session checks">
              <li>Session restored through a server-backed ledger.</li>
              <li>Protected writes stay gated by the readable CSRF token.</li>
              <li>Client-side shell never parses the session secret.</li>
            </ul>
          </aside>
        </div>

        <section className="hero-ledger" aria-label="Runtime ledger">
          <article className="ledger-card">
            <span className="label">Recovery loop</span>
            <strong>Boot → cookie → GET /api/me → shell</strong>
            <p className="muted small">
              The authenticated view is restored from the backend record, not
              reconstructed from local cookie access.
            </p>
          </article>
          <article className="ledger-card">
            <span className="label">Mutation policy</span>
            <strong>Readable CSRF + secure cookie</strong>
            <p className="muted small">
              Browser writes are accepted only when the CSRF token accompanies
              the protected session transport.
            </p>
          </article>
          <article className="ledger-card">
            <span className="label">Observation mode</span>
            <strong>Real smoke feedback closes the loop</strong>
            <p className="muted small">
              Register, restore, login, and logout remain visible to the same
              operator-facing surface.
            </p>
          </article>
        </section>
      </section>

      <section className="dashboard-lower-grid">
        <article className="panel panel-inset">
          <div className="monitor-strip">Operational panes</div>
          <div className="telemetry-grid">
            <article className="telemetry-card">
              <span className="label">Session restore path</span>
              <strong>Boot → cookie → me → shell</strong>
              <p className="muted small">
                The browser restores state through the shared backend record,
                not a locally parsed token.
              </p>
            </article>
            <article className="telemetry-card">
              <span className="label">Mutation discipline</span>
              <strong>CSRF required for writes</strong>
              <p className="muted small">
                Protected mutations only complete when the readable CSRF token
                accompanies the secure cookie.
              </p>
            </article>
            <article className="telemetry-card">
              <span className="label">Observation mode</span>
              <strong>AI-observable smoke coverage</strong>
              <p className="muted small">
                Register, restore, login, and logout are all visible in the
                operational feedback loop.
              </p>
            </article>
          </div>
        </article>

        <aside className="panel panel-command">
          <div className="monitor-strip">Current command</div>
          <p className="command-summary">
            Revoke the active cookie session and return the browser to the
            anonymous shell.
          </p>
          <button
            className="primary-button"
            onClick={() => void onLogout()}
            type="button"
          >
            Logout and revoke current session
          </button>
        </aside>
      </section>
    </main>
  );
}
