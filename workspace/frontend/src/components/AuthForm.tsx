import { useState, type FormEvent } from 'react';
import type { Credentials } from '../types/auth';

type Props = {
  actionLabel: string;
  onSubmit: (credentials: Credentials) => Promise<void>;
};

export function AuthForm({ actionLabel, onSubmit }: Props) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setError(null);

    if (!email.trim() || !password.trim()) {
      setError('Email and password are both required.');
      return;
    }

    setIsSubmitting(true);
    try {
      await onSubmit({ email, password });
    } catch (submissionError) {
      const message =
        submissionError instanceof Error ? submissionError.message : 'The request could not finish.';
      setError(message);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form className="auth-form" onSubmit={handleSubmit}>
      <label className="field">
        <span>Email</span>
        <input
          aria-label="Email"
          autoComplete="email"
          type="email"
          value={email}
          onChange={(event) => setEmail(event.target.value)}
          placeholder="operator@harness.demo"
        />
      </label>

      <label className="field">
        <span>Password</span>
        <input
          aria-label="Password"
          autoComplete="current-password"
          type="password"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          placeholder="••••••••"
        />
      </label>

      {error ? (
        <div className="error-banner" role="alert">
          {error}
        </div>
      ) : null}

      <button className="primary-button" disabled={isSubmitting} type="submit">
        {isSubmitting ? 'Transmitting signal...' : actionLabel}
      </button>
    </form>
  );
}
