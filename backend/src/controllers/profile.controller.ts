import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// GET /profile/:id
export const getProfile = async ({ params }: any) => {
  const id = String(params.id);
  const user = await prisma.user.findUnique({
    where: { id },
    select: { id: true, email: true }
  });

  return user || { error: 'User not found' };
};

// PUT /profile/:id
export const updateProfile = async ({ params, body }: any) => {
  const id = String(params.id);
  const { email, password } = body;

  const updated = await prisma.user.update({
    where: { id },
    data: { email, password }
  });

  return { message: 'Profile updated', user: updated };
};

// DELETE /profile/:id
export const deleteProfile = async ({ params }: any) => {
  const id = String(params.id);

  await prisma.todo.deleteMany({ where: { userId: id } }); // delete todos
  await prisma.user.delete({ where: { id } });              // delete user

  return { message: 'User and todos deleted' };
};