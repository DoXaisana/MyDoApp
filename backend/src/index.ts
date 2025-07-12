import { Elysia } from 'elysia';
import { cors } from '@elysiajs/cors';
import { authRoutes } from './routes/auth.routes';
import { todoRoutes } from './routes/todo.routes';
import { profileRoutes } from './routes/profile.routes'; // ✅ NEW

const app = new Elysia()
  .use(cors())
  .use(authRoutes)
  .use(todoRoutes)
  .use(profileRoutes)
  .get('/health', () => ({ status: 'ok' }))
  .listen({
    hostname: '0.0.0.0',
    port: 3000
  });

console.log('🚀 Server running at http://localhost:3000');