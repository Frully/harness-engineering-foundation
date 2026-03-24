import { Link } from 'react-router-dom';
import { AuthCard } from '../components/AuthCard';
import { AuthForm } from '../components/AuthForm';
import type { Credentials } from '../types/auth';

export function LoginPage({ onSubmit }: { onSubmit: (credentials: Credentials) => Promise<void> }) {
  return (
    <AuthCard
      eyebrow="Web shell"
      title="Re-enter the operations room."
      subtitle="The browser relies on a secure, HttpOnly session cookie and a separate CSRF token for protected mutations."
      footer={
        <p>
          Need an account? <Link to="/register">Open a fresh operator session.</Link>
        </p>
      }
    >
      <AuthForm actionLabel="Sign in with cookie auth" mode="login" onSubmit={onSubmit} />
    </AuthCard>
  );
}
