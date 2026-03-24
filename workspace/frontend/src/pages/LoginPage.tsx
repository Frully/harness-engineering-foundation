import { Link } from 'react-router-dom';
import { AuthCard } from '../components/AuthCard';
import { AuthForm } from '../components/AuthForm';
import type { Credentials } from '../types/auth';

export function LoginPage({
  onSubmit,
}: {
  onSubmit: (credentials: Credentials) => Promise<void>;
}) {
  return (
    <AuthCard
      eyebrow="Sign in"
      title="Sign in."
      subtitle="Use your account to continue."
      footer={
        <p>
          Need an account? <Link to="/register">Create one.</Link>
        </p>
      }
    >
      <AuthForm actionLabel="Sign in" mode="login" onSubmit={onSubmit} />
    </AuthCard>
  );
}
