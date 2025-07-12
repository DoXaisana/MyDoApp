import { Elysia } from 'elysia';
import { login, register } from '../controllers/auth.controller';

export const authRoutes = new Elysia({ prefix: '/auth' })
  .post('/register', register)
  .post('/login', login);