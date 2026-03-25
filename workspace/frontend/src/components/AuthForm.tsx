import { type FormEvent, useState } from 'react';
import {
  type Credentials,
  passwordPolicyHint,
  validateRegisterCredentials,
} from '../types/auth';

type Props = {
  actionLabel: string;
  mode: 'login' | 'register';
  onSubmit: (credentials: Credentials) => Promise<void>;
};

export function AuthForm({ actionLabel, mode, onSubmit }: Props) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setError(null);

    if (!email.trim() || !password.trim()) {
      setError('Email and password are both required.');
      return;
    }

    if (mode === 'register') {
      const validationMessage = validateRegisterCredentials({
        email,
        password,
        confirmPassword,
      });
      if (validationMessage) {
        setError(validationMessage);
        return;
      }
    }

    setIsSubmitting(true);
    try {
      await onSubmit({
        email,
        password,
        confirmPassword: mode === 'register' ? confirmPassword : undefined,
      });
    } catch (submissionError) {
      const message =
        submissionError instanceof Error
          ? submissionError.message
          : 'The request could not finish.';
      setError(message);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form className="auth-form" onSubmit={handleSubmit}>
      <label className="field">
        <span className="field-label">Email</span>
        <input
          aria-label="Email"
          autoComplete="email"
          type="email"
          value={email}
          onChange={(event) => setEmail(event.target.value)}
          placeholder="name@example.com"
        />
      </label>

      <label className="field">
        <span className="field-label">Password</span>
        <input
          aria-label="Password"
          autoComplete={
            mode === 'register' ? 'new-password' : 'current-password'
          }
          type="password"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          placeholder="••••••••"
        />
      </label>

      {mode === 'register' ? (
        <>
          <label className="field">
            <span className="field-label">Confirm password</span>
            <input
              aria-label="Confirm password"
              autoComplete="new-password"
              type="password"
              value={confirmPassword}
              onChange={(event) => setConfirmPassword(event.target.value)}
              placeholder="••••••••"
            />
          </label>

          <div className="command-note command-note-soft">
            <span className="field-label">Password requirements</span>
            <p className="muted small">{passwordPolicyHint}</p>
          </div>
        </>
      ) : null}

      {error ? (
        <div className="error-banner" role="alert">
          {error}
        </div>
      ) : null}

      <button className="primary-button" disabled={isSubmitting} type="submit">
        {isSubmitting ? 'Working...' : actionLabel}
      </button>
    </form>
  );
}
