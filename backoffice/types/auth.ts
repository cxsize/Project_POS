export type UserRole = 'admin' | 'manager' | 'cashier';

export type AuthUser = {
  id: string;
  username: string;
  full_name: string;
  role: UserRole;
  branch_id: string | null;
};

export type LoginResponse = {
  access_token: string;
  refresh_token: string;
  user: AuthUser;
};

export type Session = {
  accessToken: string;
  refreshToken: string;
  username: string;
  fullName: string | null;
  role: UserRole;
  branchId: string | null;
};

