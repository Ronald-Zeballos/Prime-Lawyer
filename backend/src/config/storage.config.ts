import { registerAs } from '@nestjs/config';

export default registerAs('storage', () => ({
  driver: process.env.STORAGE_DRIVER ?? 'local',
  bucket: process.env.STORAGE_BUCKET ?? '',
  region: process.env.STORAGE_REGION ?? '',
}));
