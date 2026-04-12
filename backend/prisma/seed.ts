import { randomUUID, scryptSync } from 'node:crypto';
import { PlanType, PrismaClient, UserRole, UserType } from '@prisma/client';

const prisma = new PrismaClient();

function hashPassword(password: string): string {
  const salt = 'prime-lawyer-demo-salt';
  const derivedKey = scryptSync(password, salt, 64).toString('hex');

  return `scrypt:${salt}:${derivedKey}`;
}

async function seedRoles(): Promise<void> {
  await prisma.role.upsert({
    where: { code: UserRole.NATURAL },
    update: { name: 'Natural User' },
    create: {
      id: randomUUID(),
      code: UserRole.NATURAL,
      name: 'Natural User',
    },
  });

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
      displayName: 'Prime Lawyer Admin',
      firstName: 'Demo',
      lastName: 'Admin',
      roleId: adminRole.id,
      type: UserType.ADMIN,
      plan: PlanType.ADMIN,
      tokensAvailable: 1000,
      isActive: true,
      passwordHash: hashPassword('Admin123*'),
    },
    create: {
      id: randomUUID(),
      email: 'admin@demo.com',
      displayName: 'Prime Lawyer Admin',
      firstName: 'Demo',
      lastName: 'Admin',
      roleId: adminRole.id,
      type: UserType.ADMIN,
      plan: PlanType.ADMIN,
      tokensAvailable: 1000,
      isActive: true,
      passwordHash: hashPassword('Admin123*'),
    },
  });
}

async function seedDemoLawyerUser(): Promise<void> {
  const lawyerRole = await prisma.role.findUniqueOrThrow({
    where: { code: UserRole.LAWYER },
  });

  await prisma.user.upsert({
    where: { email: 'lawyer@demo.com' },
    update: {
      displayName: 'Demo Lawyer',
      firstName: 'Demo',
      lastName: 'Lawyer',
      roleId: lawyerRole.id,
      type: UserType.LAWYER,
      plan: PlanType.LAWYER_PRO,
      tokensAvailable: 250,
      isActive: true,
      passwordHash: hashPassword('Lawyer123*'),
    },
    create: {
      id: randomUUID(),
      email: 'lawyer@demo.com',
      displayName: 'Demo Lawyer',
      firstName: 'Demo',
      lastName: 'Lawyer',
      roleId: lawyerRole.id,
      type: UserType.LAWYER,
      plan: PlanType.LAWYER_PRO,
      tokensAvailable: 250,
      isActive: true,
      passwordHash: hashPassword('Lawyer123*'),
    },
  });
}

async function seedDemoNaturalUser(): Promise<void> {
  const naturalRole = await prisma.role.findUniqueOrThrow({
    where: { code: UserRole.NATURAL },
  });

  await prisma.user.upsert({
    where: { email: 'user@demo.com' },
    update: {
      displayName: 'Demo User',
      firstName: 'Demo',
      lastName: 'User',
      roleId: naturalRole.id,
      type: UserType.NATURAL,
      plan: PlanType.FREE,
      tokensAvailable: 10,
      isActive: true,
      passwordHash: hashPassword('User123*'),
    },
    create: {
      id: randomUUID(),
      email: 'user@demo.com',
      displayName: 'Demo User',
      firstName: 'Demo',
      lastName: 'User',
      roleId: naturalRole.id,
      type: UserType.NATURAL,
      plan: PlanType.FREE,
      tokensAvailable: 10,
      isActive: true,
      passwordHash: hashPassword('User123*'),
    },
  });
}

async function seedContractTemplates(): Promise<void> {
  await prisma.contractTemplate.upsert({
    where: { slug: 'lease-agreement-basic' },
    update: {
      name: 'Lease Agreement',
      description: 'Basic residential lease agreement template for the MVP.',
      schemaJson: {
        fields: [
          { key: 'landlordName', type: 'text', label: 'Landlord name', required: true },
          { key: 'tenantName', type: 'text', label: 'Tenant name', required: true },
          { key: 'propertyAddress', type: 'text', label: 'Property address', required: true },
          { key: 'monthlyRent', type: 'number', label: 'Monthly rent', required: true },
          { key: 'startDate', type: 'date', label: 'Start date', required: true },
        ],
      },
      priceCents: 1999,
      currency: 'USD',
      isActive: true,
    },
    create: {
      id: randomUUID(),
      slug: 'lease-agreement-basic',
      name: 'Lease Agreement',
      description: 'Basic residential lease agreement template for the MVP.',
      schemaJson: {
        fields: [
          { key: 'landlordName', type: 'text', label: 'Landlord name', required: true },
          { key: 'tenantName', type: 'text', label: 'Tenant name', required: true },
          { key: 'propertyAddress', type: 'text', label: 'Property address', required: true },
          { key: 'monthlyRent', type: 'number', label: 'Monthly rent', required: true },
          { key: 'startDate', type: 'date', label: 'Start date', required: true },
        ],
      },
      priceCents: 1999,
      currency: 'USD',
      isActive: true,
    },
  });
}

async function main(): Promise<void> {
  await seedRoles();
  await seedAdminUser();
  await seedDemoLawyerUser();
  await seedDemoNaturalUser();
  await seedContractTemplates();

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
