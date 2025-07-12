import jwt, { Secret, SignOptions } from 'jsonwebtoken';

const JWT_SECRET: Secret = process.env.JWT_SECRET || 'your-secret-key';

export function signJwt(payload: string | object | Buffer, expiresIn?: string | number) {
  const options: SignOptions = {};
  if (expiresIn) (options as any).expiresIn = expiresIn;
  return jwt.sign(payload, JWT_SECRET, options);
}

export function verifyJwt(token: string) {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch {
    return null;
  }
}