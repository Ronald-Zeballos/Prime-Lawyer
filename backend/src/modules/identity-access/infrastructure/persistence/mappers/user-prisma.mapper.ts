import { PlanType as PrismaPlanType, Role, User, UserRole, UserType as PrismaUserType } from '@prisma/client';
import { RoleCode, RoleEntity } from '../../../domain/entities/role.entity';
import { PlanType, UserEntity, UserType } from '../../../domain/entities/user.entity';

type PrismaUserWithRole = User & {
  role: Role;
};

export class UserPrismaMapper {
  static toDomain(user: PrismaUserWithRole): UserEntity {
    return UserEntity.create({
      id: user.id,
      email: user.email,
      passwordHash: user.passwordHash,
      displayName: user.displayName,
      firstName: user.firstName,
      lastName: user.lastName,
      bio: user.bio,
      role: new RoleEntity(
        user.role.id,
        UserPrismaMapper.toRoleCode(user.role.code),
        user.role.name,
      ),
      type: UserPrismaMapper.toUserType(user.type),
      plan: UserPrismaMapper.toPlanType(user.plan),
      tokensAvailable: user.tokensAvailable,
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    });
  }

  private static toRoleCode(role: UserRole): RoleCode {
    switch (role) {
      case UserRole.NATURAL:
        return RoleCode.NATURAL;
      case UserRole.ADMIN:
        return RoleCode.ADMIN;
      case UserRole.LAWYER:
        return RoleCode.LAWYER;
      default:
        throw new Error(`Unsupported role code: ${role}`);
    }
  }

  private static toUserType(userType: PrismaUserType): UserType {
    switch (userType) {
      case PrismaUserType.NATURAL:
        return UserType.NATURAL;
      case PrismaUserType.LAWYER:
        return UserType.LAWYER;
      case PrismaUserType.ADMIN:
        return UserType.ADMIN;
      default:
        throw new Error(`Unsupported user type: ${userType}`);
    }
  }

  private static toPlanType(planType: PrismaPlanType): PlanType {
    switch (planType) {
      case PrismaPlanType.FREE:
        return PlanType.FREE;
      case PrismaPlanType.LAWYER_PRO:
        return PlanType.LAWYER_PRO;
      case PrismaPlanType.ADMIN:
        return PlanType.ADMIN;
      default:
        throw new Error(`Unsupported plan type: ${planType}`);
    }
  }
}
