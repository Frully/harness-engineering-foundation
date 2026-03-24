export type User = {
  id: number;
  email: string;
  createdAt: string;
};

export type Credentials = {
  email: string;
  password: string;
  confirmPassword?: string;
};

export const passwordPolicyMessage =
  'Password must be at least 8 characters and include uppercase, lowercase, number, and symbol.';

export const passwordPolicyHint =
  'Use at least 8 characters with uppercase, lowercase, number, and symbol.';

const symbolPattern = /[!@#$%^&*()_+\-=[\]{}|;:,.<>/?~`]/;

export function validateRegisterCredentials(credentials: Credentials): string | null {
  if (!credentials.email.trim() || !credentials.password.trim() || !credentials.confirmPassword?.trim()) {
    return 'Email, password, and password confirmation are all required.';
  }

  if (credentials.password !== credentials.confirmPassword) {
    return 'Passwords do not match.';
  }

  if (!isStrongPassword(credentials.password)) {
    return passwordPolicyMessage;
  }

  return null;
}

function isStrongPassword(password: string): boolean {
  return (
    password.length >= 8 &&
    /[A-Z]/.test(password) &&
    /[a-z]/.test(password) &&
    /\d/.test(password) &&
    symbolPattern.test(password)
  );
}

export type WebAuthResponse = {
  user: User;
  csrfToken: string;
};

export type MeResponse = {
  user: User;
};
