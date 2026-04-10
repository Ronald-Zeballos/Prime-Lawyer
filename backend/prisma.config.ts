import { existsSync } from 'node:fs';
import { resolve } from 'node:path';
import { defineConfig, env } from 'prisma/config';

const envFilePath = resolve(process.cwd(), '.env');

if (typeof process.loadEnvFile === 'function' && existsSync(envFilePath)) {
  process.loadEnvFile(envFilePath);
}

export default defineConfig({
  engine: 'classic',
  schema: 'prisma/schema.prisma',
  datasource: {
    url: env('DATABASE_URL'),
  },
  migrations: {
    path: 'prisma/migrations',
    seed: 'ts-node prisma/seed.ts',
  },
});
