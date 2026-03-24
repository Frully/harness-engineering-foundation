export type User = {
  id: number;
  email: string;
  createdAt: string;
};

export type Credentials = {
  email: string;
  password: string;
};

export type WebAuthResponse = {
  user: User;
  csrfToken: string;
};

export type MeResponse = {
  user: User;
};
