import { z } from 'zod';

const envSchema = z.object({
  NEXT_PUBLIC_API_BASE_URL: z
    .string()
    .url()
    .default('http://localhost:3000/api/v1'),
  AUTH_COOKIE_NAME: z.string().default('project_pos_backoffice_token')
});

const parsedEnv = envSchema.safeParse({
  NEXT_PUBLIC_API_BASE_URL: process.env.NEXT_PUBLIC_API_BASE_URL,
  AUTH_COOKIE_NAME: process.env.AUTH_COOKIE_NAME
});

if (!parsedEnv.success) {
  throw new Error('Invalid backoffice environment variables');
}

export const env = parsedEnv.data;

