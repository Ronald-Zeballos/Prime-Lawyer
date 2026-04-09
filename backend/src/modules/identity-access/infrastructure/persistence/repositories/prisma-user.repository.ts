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
}
