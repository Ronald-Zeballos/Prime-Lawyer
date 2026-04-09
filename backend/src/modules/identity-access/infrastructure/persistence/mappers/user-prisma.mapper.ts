import { Role, User, UserRole } from '@prisma/client';
import { RoleCode, RoleEntity } from '../../../domain/entities/role.entity';
import { UserEntity } from '../../../domain/entities/user.entity';

type PrismaUserWithRole = User & {
  role: Role;
};

export class UserPrismaMapper {
  static toDomain(user: PrismaUserWithRole): UserEntity {
    return UserEntity.create({
      id: user.id,
      email: user.email,
      passwordHash: user.passwordHash,
      firstName: user.firstName,
      lastName: user.lastName,
      role: new RoleEntity(
        user.role.id,
        this.toRoleCode(user.role.code),
        user.role.name,
      ),
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    });
  }

  private static toRoleCode(role: UserRole): RoleCode {
    switch (role) {
      case UserRole.ADMIN:
        return RoleCode.ADMIN;
      case UserRole.LAWYER:
        return RoleCode.LAWYER;
      default:
        throw new Error(`Unsupported role code: ${role}`);
    }
  }
}
