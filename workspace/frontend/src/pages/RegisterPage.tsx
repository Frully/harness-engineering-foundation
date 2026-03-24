import { Link } from 'react-router-dom';
import { AuthCard } from '../components/AuthCard';
import { AuthForm } from '../components/AuthForm';
import type { Credentials } from '../types/auth';

export function RegisterPage({
  onSubmit,
}: {
  onSubmit: (credentials: Credentials) => Promise<void>;
}) {
  return (
    <AuthCard
      eyebrow="Create account"
      title="Create account."
      subtitle="Create your account to continue."
      footer={
        <p>
          Already have an account? <Link to="/login">Sign in.</Link>
        </p>
      }
    >
      <AuthForm
        actionLabel="Create account"
        mode="register"
        onSubmit={onSubmit}
      />
    </AuthCard>
  );
}
