import { Elysia } from 'elysia';
import {
  getProfile,
  updateProfile,
  deleteProfile
} from '../controllers/profile.controller';
import { deleteTodo, createTodo, getTodoById, getTodos, jwtMiddleware, updateTodo } from '../controllers/todo.controller';

export const profileRoutes = new Elysia({ prefix: '/profile' })
  .get('/:id', getProfile)
  .put('/:id', updateProfile)
  .delete('/:id', deleteProfile);

export const todoRoutes = new Elysia({ prefix: '/todo' })
  .get('/:userId', jwtMiddleware, getTodos)
  .get('/item/:id', jwtMiddleware, getTodoById)
  .post('/', jwtMiddleware, createTodo)
  .put('/:id', jwtMiddleware, updateTodo)
  .delete('/:id', jwtMiddleware, deleteTodo);