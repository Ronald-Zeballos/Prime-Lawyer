import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { UserEntity } from '../../../domain/entities/user.entity';
import { UserRepository } from '../../../domain/repositories/user.repository';
import { Email } from '../../../domain/value-objects/email.vo';
import { UserId } from '../../../domain/value-objects/user-id.vo';
import { UserPrismaMapper } from '../mappers/user-prisma.mapper';

@Injectable()
export class PrismaUserRepository implements UserRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findByEmail(email: Email): Promise<UserEntity | null> {
    const user = await this.prisma.user.findUnique({
      where: { email: email.value },
      include: { role: true },
    });

    if (!user) {
      return null;
    }

    return UserPrismaMapper.toDomain(user);
  }

  async findById(id: UserId): Promise<UserEntity | null> {
    const user = await this.prisma.user.findUnique({
      where: { id: id.value },
      include: { role: true },
    });

    if (!user) {
      return null;
    }

    return UserPrismaMapper.toDomain(user);
  }

  async create(user: UserEntity): Promise<UserEntity> {
    const role = await this.prisma.role.findUniqueOrThrow({
      where: { code: user.role.code as never },
    });

    const createdUser = await this.prisma.user.create({
      data: {
        id: user.id.value,
        email: user.email.value,
        passwordHash: user.passwordHash.value,
        displayName: user.displayName,
        firstName: user.firstName,
        lastName: user.lastName,
        bio: user.bio,
        roleId: role.id,
        type: user.type as never,
        plan: user.plan as never,
        tokensAvailable: user.tokensAvailable,
        isActive: user.isActive,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      },
      include: { role: true },
    });

    return UserPrismaMapper.toDomain(createdUser);
  }

  async updateProfile(user: UserEntity): Promise<UserEntity> {
    const updatedUser = await this.prisma.user.update({
      where: { id: user.id.value },
      data: {
        displayName: user.displayName,
        firstName: user.firstName,
        lastName: user.lastName,
        bio: user.bio,
        updatedAt: user.updatedAt,
      },
      include: { role: true },
    });

    return UserPrismaMapper.toDomain(updatedUser);
  }
}
