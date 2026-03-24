import type { PropsWithChildren, ReactNode } from 'react';
import { Link } from 'react-router-dom';

export function AuthCard({
  eyebrow,
  title,
  subtitle,
  footer,
  children,
}: PropsWithChildren<{
  eyebrow: string;
  title: string;
  subtitle: string;
  footer: ReactNode;
}>) {
  return (
    <main className="command-shell auth-shell">
      <section className="panel panel-hero">
        <div className="hero-topline">
          <div className="command-strip">
            <span>WEB NODE</span>
            <span>COOKIE AUTH</span>
            <span>LIVE CONTROL</span>
          </div>
          <span className="command-badge">REF / PRIMARY RUNTIME</span>
        </div>

        <div className="hero-layout">
          <div className="hero-copy-block">
            <p className="eyebrow">{eyebrow}</p>
            <h1>{title}</h1>
            <p className="hero-copy">{subtitle}</p>
            <div className="signal-rail">
              <span>Shared sessions</span>
              <span>HttpOnly cookie</span>
              <span>Readable CSRF token</span>
            </div>
          </div>

          <aside className="monitor-panel" aria-label="Session monitor">
            <div className="monitor-strip">Operator matrix</div>
            <dl className="monitor-grid">
              <div>
                <dt>Transport</dt>
                <dd>Secure cookie + CSRF</dd>
              </div>
              <div>
                <dt>State source</dt>
                <dd>Server session ledger</dd>
              </div>
              <div>
                <dt>Observation</dt>
                <dd>Smoke-visible workflow</dd>
              </div>
              <div>
                <dt>Client posture</dt>
                <dd>No cookie access in JS</dd>
              </div>
            </dl>
            <ul className="terminal-list" aria-label="Operator checks">
              <li>Cookie stays outside JavaScript reach.</li>
              <li>Writable mutations require a readable CSRF token.</li>
              <li>Smoke traces the same flow the operator sees.</li>
            </ul>
          </aside>
        </div>

        <section
          className="hero-ledger"
          aria-label="Reference interface ledger"
        >
          <article className="ledger-card">
            <span className="label">Visual stance</span>
            <strong>Tactile terminal command chamber</strong>
            <p className="muted small">
              Paper atmosphere, amber pressure, and command plates instead of
              neutral product chrome.
            </p>
          </article>
          <article className="ledger-card">
            <span className="label">Control grammar</span>
            <strong>Strips, rails, telemetry, and operator notes</strong>
            <p className="muted small">
              TUI influence shows up in orientation and state clarity, not fake
              terminal nostalgia.
            </p>
          </article>
          <article className="ledger-card">
            <span className="label">Cross-runtime role</span>
            <strong>Web is the canonical reference shell</strong>
            <p className="muted small">
              Mobile should translate this hierarchy and material system into a
              handheld command surface.
            </p>
          </article>
        </section>
      </section>

      <section className="panel panel-form">
        <div className="command-strip command-strip-inset">
          <span>AUTH FLOW</span>
          <span>WRITE-PROTECTED SESSION</span>
          <span>OPERATOR ENTRY</span>
        </div>
        {children}
        <div className="card-footer">{footer}</div>
        <section className="command-note" aria-label="Client constraints">
          <span className="label">Client boundary</span>
          <p className="muted small">
            The web shell never touches the HttpOnly session cookie. It only
            keeps the readable CSRF token needed for protected writes.
          </p>
        </section>
        <div className="return-row">
          <Link className="ghost-link" to="/">
            Return to the signal deck
          </Link>
        </div>
      </section>
    </main>
  );
}
