import { randomUUID, scryptSync } from 'node:crypto';
import { PrismaClient, UserRole } from '@prisma/client';

const prisma = new PrismaClient();

function hashPassword(password: string): string {
  const salt = 'prime-lawyer-demo-salt';
  const derivedKey = scryptSync(password, salt, 64).toString('hex');

  return `scrypt:${salt}:${derivedKey}`;
}

async function seedRoles(): Promise<void> {
  await prisma.role.upsert({
    where: { code: UserRole.ADMIN },
    update: { name: 'Administrator' },
    create: {
      id: randomUUID(),
      code: UserRole.ADMIN,
      name: 'Administrator',
    },
  });

  await prisma.role.upsert({
    where: { code: UserRole.LAWYER },
    update: { name: 'Lawyer' },
    create: {
      id: randomUUID(),
      code: UserRole.LAWYER,
      name: 'Lawyer',
    },
  });
}

async function seedAdminUser(): Promise<void> {
  const adminRole = await prisma.role.findUniqueOrThrow({
    where: { code: UserRole.ADMIN },
  });

  await prisma.user.upsert({
    where: { email: 'admin@demo.com' },
    update: {
      firstName: 'Demo',
      lastName: 'Admin',
      roleId: adminRole.id,
      isActive: true,
      passwordHash: hashPassword('Admin123*'),
    },
    create: {
      id: randomUUID(),
      email: 'admin@demo.com',
      firstName: 'Demo',
      lastName: 'Admin',
      roleId: adminRole.id,
      isActive: true,
      passwordHash: hashPassword('Admin123*'),
    },
  });
}

async function main(): Promise<void> {
  await seedRoles();
  await seedAdminUser();

  console.log('Seed completed');
}

main()
  .catch((error) => {
    console.error('Seed failed', error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
