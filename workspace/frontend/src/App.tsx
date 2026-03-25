import { startTransition, useEffect, useState } from 'react';
import { Navigate, Route, Routes, useNavigate } from 'react-router-dom';
import { HomePage } from './pages/HomePage';
import { LoginPage } from './pages/LoginPage';
import { RegisterPage } from './pages/RegisterPage';
import {
  clearStoredCSRFToken,
  getCurrentUser,
  getStoredCSRFToken,
  login,
  logout,
  register,
} from './services/auth';
import type { Credentials, User } from './types/auth';

type SessionState =
  | { status: 'loading'; user: null; csrfToken: null }
  | { status: 'anonymous'; user: null; csrfToken: string | null }
  | { status: 'authenticated'; user: User; csrfToken: string | null };

const initialState: SessionState = {
  status: 'loading',
  user: null,
  csrfToken: null,
};

export function App() {
  const [session, setSession] = useState<SessionState>(initialState);

  useEffect(() => {
    let isMounted = true;

    void getCurrentUser()
      .then((user) => {
        if (!isMounted) {
          return;
        }
        startTransition(() => {
          setSession({
            status: 'authenticated',
            user,
            csrfToken: getStoredCSRFToken(),
          });
        });
      })
      .catch(() => {
        if (!isMounted) {
          return;
        }
        startTransition(() => {
          setSession({
            status: 'anonymous',
            user: null,
            csrfToken: getStoredCSRFToken(),
          });
        });
      });

    return () => {
      isMounted = false;
    };
  }, []);

  const handleLogin = async (credentials: Credentials) => {
    const result = await login(credentials);
    startTransition(() => {
      setSession({
        status: 'authenticated',
        user: result.user,
        csrfToken: result.csrfToken,
      });
    });
  };

  const handleRegister = async (credentials: Credentials) => {
    const result = await register(credentials);
    startTransition(() => {
      setSession({
        status: 'authenticated',
        user: result.user,
        csrfToken: result.csrfToken,
      });
    });
  };

  const handleLogout = async () => {
    if (!session.csrfToken) {
      throw new Error('missing csrf token');
    }

    await logout(session.csrfToken);
    startTransition(() => {
      clearStoredCSRFToken();
      setSession({
        status: 'anonymous',
        user: null,
        csrfToken: null,
      });
    });
  };

  if (session.status === 'loading') {
    return (
      <main className="command-shell loading-shell">
        <section className="panel panel-loading" aria-label="Loading">
          <p className="eyebrow">Session</p>
          <h1>Restoring session.</h1>
          <p className="hero-copy">Checking the current session.</p>
          <div className="loading-meter" aria-hidden="true">
            <span />
          </div>
        </section>
      </main>
    );
  }

  return (
    <Routes>
      <Route
        path="/"
        element={
          session.status === 'authenticated' ? (
            <HomePage user={session.user} onLogout={handleLogout} />
          ) : (
            <Navigate to="/login" replace />
          )
        }
      />
      <Route
        path="/login"
        element={
          session.status === 'authenticated' ? (
            <Navigate to="/" replace />
          ) : (
            <AuthRoute onSubmit={handleLogin} mode="login" />
          )
        }
      />
      <Route
        path="/register"
        element={
          session.status === 'authenticated' ? (
            <Navigate to="/" replace />
          ) : (
            <AuthRoute onSubmit={handleRegister} mode="register" />
          )
        }
      />
    </Routes>
  );
}

function AuthRoute({
  mode,
  onSubmit,
}: {
  mode: 'login' | 'register';
  onSubmit: (credentials: Credentials) => Promise<void>;
}) {
  const navigate = useNavigate();

  const handleSuccess = async (credentials: Credentials) => {
    await onSubmit(credentials);
    navigate('/', { replace: true });
  };

  if (mode === 'login') {
    return <LoginPage onSubmit={handleSuccess} />;
  }

  return <RegisterPage onSubmit={handleSuccess} />;
}
