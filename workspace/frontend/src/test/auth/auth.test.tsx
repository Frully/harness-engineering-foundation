import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { App } from '../../App';
import {
  webDesktopViewport,
  webMobileViewport,
  withViewport,
} from '../viewports';

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
      expect(
        screen.getByRole('button', {
          name: /create account/i,
        }),
      ).toBeVisible(),
    );

    await userEvent.type(
      screen.getByLabelText('Email'),
      'register@example.com',
    );
    await userEvent.type(screen.getByLabelText('Password'), 'Harness1!');
    await userEvent.type(
      screen.getByLabelText('Confirm password'),
      'Harness1!',
    );
    await userEvent.click(
      screen.getByRole('button', { name: /^create account$/i }),
    );

    expect(authMocks.register).toHaveBeenCalledWith({
      email: 'register@example.com',
      password: 'Harness1!',
      confirmPassword: 'Harness1!',
    });
    expect(
      await screen.findByRole('heading', { name: /session restored/i }),
    ).toBeVisible();
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
      expect(screen.getByRole('button', { name: /^sign in$/i })).toBeVisible(),
    );

    await userEvent.type(screen.getByLabelText('Email'), 'login@example.com');
    await userEvent.type(screen.getByLabelText('Password'), 'Harness1!');
    await userEvent.click(screen.getByRole('button', { name: /^sign in$/i }));

    expect(authMocks.login).toHaveBeenCalled();
    expect(
      await screen.findByRole('heading', { name: /session restored/i }),
    ).toBeVisible();
  });

  it('auth register blocks mismatched password confirmation before submit', async () => {
    authMocks.getCurrentUser.mockRejectedValue(new Error('no session'));

    render(
      <MemoryRouter initialEntries={['/register']}>
        <App />
      </MemoryRouter>,
    );

    await waitFor(() =>
      expect(
        screen.getByRole('button', {
          name: /create account/i,
        }),
      ).toBeVisible(),
    );

    await userEvent.type(
      screen.getByLabelText('Email'),
      'mismatch@example.com',
    );
    await userEvent.type(screen.getByLabelText('Password'), 'Harness1!');
    await userEvent.type(
      screen.getByLabelText('Confirm password'),
      'Harness2!',
    );
    await userEvent.click(
      screen.getByRole('button', { name: /^create account$/i }),
    );

    expect(authMocks.register).not.toHaveBeenCalled();
    expect(await screen.findByRole('alert')).toHaveTextContent(
      /passwords do not match/i,
    );
  });

  it('auth register blocks weak passwords before submit', async () => {
    authMocks.getCurrentUser.mockRejectedValue(new Error('no session'));

    render(
      <MemoryRouter initialEntries={['/register']}>
        <App />
      </MemoryRouter>,
    );

    await waitFor(() =>
      expect(
        screen.getByRole('button', {
          name: /create account/i,
        }),
      ).toBeVisible(),
    );

    await userEvent.type(screen.getByLabelText('Email'), 'weak@example.com');
    await userEvent.type(screen.getByLabelText('Password'), 'weakpass');
    await userEvent.type(screen.getByLabelText('Confirm password'), 'weakpass');
    await userEvent.click(
      screen.getByRole('button', { name: /^create account$/i }),
    );

    expect(authMocks.register).not.toHaveBeenCalled();
    expect(await screen.findByRole('alert')).toHaveTextContent(
      /password must be at least 8 characters and include uppercase, lowercase, number, and symbol/i,
    );
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

    expect(
      await screen.findByRole('heading', { name: /session restored/i }),
    ).toBeVisible();
    await userEvent.click(
      screen.getByRole('button', {
        name: /log out/i,
      }),
    );

    expect(authMocks.logout).toHaveBeenCalledWith('csrf-logout');
    expect(
      await screen.findByRole('heading', {
        name: /^sign in\.$/i,
      }),
    ).toBeVisible();
  });

  for (const viewport of [webMobileViewport, webDesktopViewport]) {
    it(`auth register stays operable across viewport ${viewport.name}`, async () => {
      authMocks.getCurrentUser.mockRejectedValue(new Error('no session'));
      authMocks.register.mockResolvedValue({
        user: {
          id: 4,
          email: `${viewport.name}@example.com`,
          createdAt: '2026-03-24T00:00:00Z',
        },
        csrfToken: `csrf-${viewport.name}`,
      });

      await withViewport(viewport, async () => {
        render(
          <MemoryRouter initialEntries={['/register']}>
            <App />
          </MemoryRouter>,
        );

        await waitFor(() =>
          expect(
            screen.getByRole('button', {
              name: /create account/i,
            }),
          ).toBeVisible(),
        );

        await userEvent.type(
          screen.getByLabelText('Email'),
          `${viewport.name}@example.com`,
        );
        await userEvent.type(screen.getByLabelText('Password'), 'Harness1!');
        await userEvent.type(
          screen.getByLabelText('Confirm password'),
          'Harness1!',
        );
        await userEvent.click(
          screen.getByRole('button', { name: /^create account$/i }),
        );

        expect(
          await screen.findByRole('heading', { name: /session restored/i }),
        ).toBeVisible();
        expect(screen.getByText(`${viewport.name}@example.com`)).toBeVisible();
      });
    });
  }
});
