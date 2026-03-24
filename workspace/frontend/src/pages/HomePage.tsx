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
            <h1>Session restored.</h1>
            <p className="hero-copy">Your account is active in this browser.</p>

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
                <dd>Web session</dd>
              </div>
              <div>
                <dt>Session model</dt>
                <dd>Shared backend session</dd>
              </div>
              <div>
                <dt>Protection</dt>
                <dd>Cookie kept outside JS</dd>
              </div>
            </dl>
            <ul className="terminal-list" aria-label="Session checks">
              <li>Session restored from the shared backend record.</li>
              <li>Protected writes still require the CSRF token.</li>
              <li>The cookie stays outside client-side code.</li>
            </ul>
          </aside>
        </div>

        <section className="hero-ledger" aria-label="Runtime ledger">
          <article className="ledger-card">
            <span className="label">Recovery loop</span>
            <strong>Boot → cookie → GET /api/me → shell</strong>
            <p className="muted small">
              The browser restores state from the backend session.
            </p>
          </article>
          <article className="ledger-card">
            <span className="label">Mutation policy</span>
            <strong>Readable CSRF + secure cookie</strong>
            <p className="muted small">Writes require the CSRF token.</p>
          </article>
          <article className="ledger-card">
            <span className="label">Observation mode</span>
            <strong>Smoke feedback stays visible</strong>
            <p className="muted small">
              Register, restore, login, and logout stay observable.
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
                The browser restores state through the shared backend record.
              </p>
            </article>
            <article className="telemetry-card">
              <span className="label">Mutation discipline</span>
              <strong>CSRF required for writes</strong>
              <p className="muted small">
                Protected writes only complete with the CSRF token.
              </p>
            </article>
            <article className="telemetry-card">
              <span className="label">Observation mode</span>
              <strong>AI-observable smoke coverage</strong>
              <p className="muted small">
                Register, restore, login, and logout stay in the feedback loop.
              </p>
            </article>
          </div>
        </article>

        <aside className="panel panel-command">
          <div className="monitor-strip">Current command</div>
          <p className="command-summary">End the current browser session.</p>
          <button
            className="primary-button"
            onClick={() => void onLogout()}
            type="button"
          >
            Log out
          </button>
        </aside>
      </section>
    </main>
  );
}
