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
      <section className="panel dashboard-panel">
        <p className="eyebrow">Account</p>
        <h1>Session restored.</h1>
        <p className="hero-copy">Your account is active in this browser.</p>
        <div className="account-block">
          <span className="account-label">Signed in as</span>
          <strong>{user.email}</strong>
        </div>
        <button
          className="primary-button"
          onClick={() => void onLogout()}
          type="button"
        >
          Log out
        </button>
      </section>
    </main>
  );
}
