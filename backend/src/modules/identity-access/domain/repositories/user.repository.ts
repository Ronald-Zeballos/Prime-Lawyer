import { Email } from '../value-objects/email.vo';
import { UserEntity } from '../entities/user.entity';
import { UserId } from '../value-objects/user-id.vo';

export const USER_REPOSITORY = Symbol('USER_REPOSITORY');

export interface UserRepository {
  findByEmail(email: Email): Promise<UserEntity | null>;
  findById(id: UserId): Promise<UserEntity | null>;
  create(user: UserEntity): Promise<UserEntity>;
  updateProfile(user: UserEntity): Promise<UserEntity>;
}
