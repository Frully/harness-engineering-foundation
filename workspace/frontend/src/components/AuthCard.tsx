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
      <section className="panel panel-auth">
        <div className="command-strip">
          <span>WEB NODE</span>
          <span>COOKIE AUTH</span>
          <span>SESSION ENTRY</span>
        </div>
        <p className="eyebrow">{eyebrow}</p>
        <h1>{title}</h1>
        <p className="hero-copy auth-copy">{subtitle}</p>
        <div className="signal-rail auth-rail">
          <span>Shared session</span>
          <span>Protected writes</span>
          <span>Smoke visible</span>
        </div>
        <div className="command-strip command-strip-inset">
          <span>AUTH FLOW</span>
          <span>ACCOUNT ACCESS</span>
        </div>
        {children}
        <div className="card-footer">{footer}</div>
        <Link className="ghost-link return-row" to="/">
          Back to the shell
        </Link>
      </section>
    </main>
  );
}
