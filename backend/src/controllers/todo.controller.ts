import { PrismaClient } from '@prisma/client';
import jwt from 'jsonwebtoken';

const prisma = new PrismaClient();

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

export function signJwt(payload: object, expiresIn = '7d') {
  const options: any = { expiresIn };
  return jwt.sign(payload, JWT_SECRET, options);
}

export function verifyJwt(token: string) {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch {
    return null;
  }
}

export const getTodos = async ({ params }: any) => {
  const userId = params.userId;
  return await prisma.todo.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' }
  });
};

export const createTodo = async ({ body }: any) => {
  const { title, description, completed, userId, date, time, remind } = body;
  return await prisma.todo.create({
    data: {
      title,
      description,
      completed: completed ?? false,
      userId,
      date,
      time,
      ...(remind !== undefined && { remind }),
    },
  });
};

// Get a single todo by id
export const getTodoById = async ({ params }: any) => {
  const id = params.id;
  return await prisma.todo.findUnique({ where: { id } });
};

// Update a todo by id
export const updateTodo = async ({ params, body }: any) => {
  const id = params.id;
  const { title, description, completed, date, time, remind } = body;
  const updated = await prisma.todo.update({
    where: { id },
    data: {
      ...(title !== undefined && { title }),
      ...(description !== undefined && { description }),
      ...(completed !== undefined && { completed }),
      ...(date !== undefined && { date }),
      ...(time !== undefined && { time }),
      remind, // always include remind, even if null
    },
  });
  return updated;
};

// Delete a todo by id
export const deleteTodo = async ({ params }: any) => {
  const id = params.id;
  await prisma.todo.delete({ where: { id } });
  return { message: 'Todo deleted' };
};

export function jwtMiddleware({ request, set }: any) {
  const auth = request.headers.get('authorization');
  if (!auth || !auth.startsWith('Bearer ')) {
    set.status = 401;
    return { error: 'Unauthorized' };
  }
  const token = auth.split(' ')[1];
  const payload = verifyJwt(token);
  if (!payload) {
    set.status = 401;
    return { error: 'Invalid token' };
  }
  // Attach user info to context if needed
  return payload;
}