import { PrismaClient } from '@prisma/client';
import formidable from 'formidable';
import sharp from 'sharp';
import path from 'path';
import fs from 'fs';
import type * as formidableTypes from 'formidable';

const prisma = new PrismaClient();

// GET /profile/:id
export const getProfile = async ({ params }: any) => {
  const id = String(params.id);
  const user = await prisma.user.findUnique({
    where: { id },
    select: { id: true, email: true, username: true, image: true }
  });
  return user || { error: 'User not found' };
};

// PUT /profile/:id
export const updateProfile = async ({ params, body }: any) => {
  const id = String(params.id);
  const { email, username, image } = body;
  const data: any = {};
  if (email !== undefined) data.email = email;
  if (username !== undefined) data.username = username;
  if (image !== undefined) data.image = image;
  const updated = await prisma.user.update({
    where: { id },
    data
  });
  return { message: 'Profile updated', user: { id: updated.id, email: updated.email, username: updated.username, image: updated.image } };
};

// DELETE /profile/:id
export const deleteProfile = async ({ params }: any) => {
  const id = String(params.id);

  await prisma.todo.deleteMany({ where: { userId: id } }); // delete todos
  await prisma.user.delete({ where: { id } });              // delete user

  return { message: 'User and todos deleted' };
};

export const uploadProfileImage = async ({ params, request, set }: any) => {
  const id = String(params.id);
  // Parse multipart form
  const form = formidable({ multiples: false });
  const [fields, files] = await new Promise<any[]>((resolve, reject) => {
    form.parse(request, (err: any, fields: formidableTypes.Fields, files: formidableTypes.Files) => {
      if (err) reject(err);
      else resolve([fields, files]);
    });
  });
  const file = (files.image as formidableTypes.File | formidableTypes.File[]);
  if (!file) {
    set.status = 400;
    return { error: 'No image uploaded' };
  }
  const singleFile = Array.isArray(file) ? file[0] : file;
  // Ensure uploads directory exists
  const uploadDir = path.join(process.cwd(), 'uploads');
  if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir);
  // Resize and save image
  const ext = path.extname(singleFile.originalFilename || '.png');
  const filename = `profile_${id}_${Date.now()}${ext}`;
  const filepath = path.join(uploadDir, filename);
  await sharp(singleFile.filepath)
    .resize(256, 256)
    .toFile(filepath);
  // Save relative path to DB
  const imagePath = `/uploads/${filename}`;
  const updated = await prisma.user.update({
    where: { id },
    data: { image: imagePath }
  });
  return { message: 'Image uploaded', image: imagePath, user: { id: updated.id, image: updated.image } };
};

// Change password for user
export const changePassword = async ({ params, body, set }: any) => {
  const id = String(params.id);
  const { oldPassword, newPassword } = body;
  if (!oldPassword || !newPassword) {
    set.status = 400;
    return { error: 'Old and new password required' };
  }
  const user = await prisma.user.findUnique({ where: { id } });
  if (!user) {
    set.status = 404;
    return { error: 'User not found' };
  }
  if (user.password !== oldPassword) {
    set.status = 400;
    return { error: 'Old password is incorrect' };
  }
  await prisma.user.update({
    where: { id },
    data: { password: newPassword },
  });
  return { message: 'Password changed successfully' };
};