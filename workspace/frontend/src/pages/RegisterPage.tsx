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
      eyebrow="Session mint"
      title="Provision a new operator."
      subtitle="Registration immediately creates the shared backend session, sets the secure cookie, and returns the readable CSRF token."
      footer={
        <p>
          Already provisioned? <Link to="/login">Return to the sign in console.</Link>
        </p>
      }
    >
      <AuthForm actionLabel="Create account and issue cookie" onSubmit={onSubmit} />
    </AuthCard>
  );
}
