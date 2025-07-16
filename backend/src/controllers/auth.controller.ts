import { PrismaClient } from '@prisma/client';
import { signJwt } from '../utils/jwt';

const prisma = new PrismaClient();

export const register = async ({ body }: any) => {
  const { username, email, password } = body;
  if (!username || !email || !password) {
    return { error: 'Username, email, and password are required' };
  }
  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) return { error: 'User already exists' };

  const user = await prisma.user.create({ data: { username, email, password } });
  return { message: 'Registered', user: { id: user.id, email: user.email, username: user.username } };
};

export const login = async ({ body }: any) => {
  const { email, password } = body;
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user || user.password !== password)
    return { error: 'Invalid credentials' };

  // Generate JWT token
  const token = signJwt({ id: user.id, email: user.email, username: user.username }, '7d');
  return { token, user: { id: user.id, email: user.email, username: user.username } };
};