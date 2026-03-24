import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { App } from '../../App';

const authMocks = vi.hoisted(() => ({
  getCurrentUser: vi.fn(),
  login: vi.fn(),
  logout: vi.fn(),
  register: vi.fn(),
  getStoredCSRFToken: vi.fn(),
  clearStoredCSRFToken: vi.fn(),
}));

vi.mock('../../services/auth', () => authMocks);

describe('auth feature', () => {
  beforeEach(() => {
    authMocks.getCurrentUser.mockReset();
    authMocks.login.mockReset();
    authMocks.logout.mockReset();
    authMocks.register.mockReset();
    authMocks.getStoredCSRFToken.mockReset();
    authMocks.clearStoredCSRFToken.mockReset();
    authMocks.getStoredCSRFToken.mockReturnValue(null);
  });

  it('auth register transitions into the dashboard', async () => {
    authMocks.getCurrentUser.mockRejectedValue(new Error('no session'));
    authMocks.register.mockResolvedValue({
      user: {
        id: 1,
        email: 'register@example.com',
        createdAt: '2026-03-24T00:00:00Z',
      },
      csrfToken: 'csrf-register',
    });

    render(
      <MemoryRouter initialEntries={['/register']}>
        <App />
      </MemoryRouter>,
    );

    await waitFor(() =>
      expect(screen.getByRole('button', { name: /create account and issue cookie/i })).toBeVisible(),
    );

    await userEvent.type(screen.getByLabelText('Email'), 'register@example.com');
    await userEvent.type(screen.getByLabelText('Password'), 'hunter2');
    await userEvent.click(screen.getByRole('button', { name: /create account and issue cookie/i }));

    expect(authMocks.register).toHaveBeenCalled();
    expect(await screen.findByRole('heading', { name: /cookie session restored/i })).toBeVisible();
  });

  it('auth login transitions into the dashboard', async () => {
    authMocks.getCurrentUser.mockRejectedValue(new Error('no session'));
    authMocks.login.mockResolvedValue({
      user: {
        id: 2,
        email: 'login@example.com',
        createdAt: '2026-03-24T00:00:00Z',
      },
      csrfToken: 'csrf-login',
    });

    render(
      <MemoryRouter initialEntries={['/login']}>
        <App />
      </MemoryRouter>,
    );

    await waitFor(() =>
      expect(screen.getByRole('button', { name: /sign in with cookie auth/i })).toBeVisible(),
    );

    await userEvent.type(screen.getByLabelText('Email'), 'login@example.com');
    await userEvent.type(screen.getByLabelText('Password'), 'hunter2');
    await userEvent.click(screen.getByRole('button', { name: /sign in with cookie auth/i }));

    expect(authMocks.login).toHaveBeenCalled();
    expect(await screen.findByRole('heading', { name: /cookie session restored/i })).toBeVisible();
  });

  it('auth logout returns to the login shell', async () => {
    authMocks.getCurrentUser.mockResolvedValue({
      id: 3,
      email: 'logout@example.com',
      createdAt: '2026-03-24T00:00:00Z',
    });
    authMocks.getStoredCSRFToken.mockReturnValue('csrf-logout');
    authMocks.logout.mockResolvedValue(undefined);

    render(
      <MemoryRouter initialEntries={['/']}>
        <App />
      </MemoryRouter>,
    );

    expect(await screen.findByRole('heading', { name: /cookie session restored/i })).toBeVisible();
    await userEvent.click(screen.getByRole('button', { name: /logout and revoke current session/i }));

    expect(authMocks.logout).toHaveBeenCalledWith('csrf-logout');
    expect(await screen.findByRole('heading', { name: /re-enter the operations room/i })).toBeVisible();
  });
});
