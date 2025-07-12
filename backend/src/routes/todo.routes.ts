import { Elysia } from 'elysia';
import { getTodos, createTodo, getTodoById, updateTodo, deleteTodo } from '../controllers/todo.controller';

export const todoRoutes = new Elysia({ prefix: '/todo' })
  .get('/:userId', getTodos)
  .get('/item/:id', getTodoById)
  .post('/', createTodo)
  .put('/:id', updateTodo)
  .delete('/:id', deleteTodo);