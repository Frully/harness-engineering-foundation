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
    <main className="app-shell">
      <section className="hero-panel">
        <p className="eyebrow">{eyebrow}</p>
        <h1>{title}</h1>
        <p className="hero-copy">{subtitle}</p>
        <div className="rail">
          <span>Shared sessions</span>
          <span>Cookie + CSRF</span>
          <span>AI-observable smoke</span>
        </div>
      </section>

      <section className="card-panel">
        {children}
        <div className="card-footer">{footer}</div>
        <p className="muted small">
          The web shell never touches the HttpOnly session cookie. It only keeps the readable CSRF
          token needed for protected writes.
        </p>
        <Link className="ghost-link" to="/">
          Return to the signal deck
        </Link>
      </section>
    </main>
  );
}
