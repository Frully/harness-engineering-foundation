import type { Credentials, MeResponse, User, WebAuthResponse } from '../types/auth';
import { requestJSON } from './api';

const CSRF_STORAGE_KEY = 'hed_web_csrf_token';

export async function register(credentials: Credentials): Promise<WebAuthResponse> {
  const response = await requestJSON<WebAuthResponse>('/api/auth/register', {
    method: 'POST',
    body: JSON.stringify(credentials),
  });
  storeCSRFToken(response.csrfToken);
  return response;
}

export async function login(credentials: Credentials): Promise<WebAuthResponse> {
  const response = await requestJSON<WebAuthResponse>('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify(credentials),
  });
  storeCSRFToken(response.csrfToken);
  return response;
}

export async function logout(csrfToken: string): Promise<void> {
  await requestJSON('/api/auth/logout', {
    method: 'POST',
    headers: {
      'X-CSRF-Token': csrfToken,
    },
  });
  clearStoredCSRFToken();
}

export async function getCurrentUser(): Promise<User> {
  const response = await requestJSON<MeResponse>('/api/me');
  return response.user;
}

export function getStoredCSRFToken(): string | null {
  return window.localStorage.getItem(CSRF_STORAGE_KEY);
}

export function clearStoredCSRFToken() {
  window.localStorage.removeItem(CSRF_STORAGE_KEY);
}

function storeCSRFToken(token: string) {
  window.localStorage.setItem(CSRF_STORAGE_KEY, token);
}
