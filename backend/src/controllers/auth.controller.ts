import { PrismaClient } from '@prisma/client';
import { signJwt } from '../utils/jwt';

const prisma = new PrismaClient();

export const register = async ({ body }: any) => {
  const { email, password } = body;
  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) return { error: 'User already exists' };

  const user = await prisma.user.create({ data: { email, password } });
  return { message: 'Registered', user: { id: user.id, email: user.email } };
};

export const login = async ({ body }: any) => {
  const { email, password } = body;
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user || user.password !== password)
    return { error: 'Invalid credentials' };

  // Generate JWT token
  const token = signJwt({ id: user.id, email: user.email }, '7d');
  return { token, user: { id: user.id, email: user.email } };
};