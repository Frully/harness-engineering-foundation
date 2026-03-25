import type { PropsWithChildren, ReactNode } from 'react';

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
        <p className="eyebrow">{eyebrow}</p>
        <h1>{title}</h1>
        <p className="hero-copy auth-copy">{subtitle}</p>
        {children}
        <div className="card-footer">{footer}</div>
      </section>
    </main>
  );
}
