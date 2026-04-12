import { Module } from '@nestjs/common';
import { IdentityAccessModule } from '../identity-access/identity-access.module';
import { GetProfileUseCase } from './application/use-cases/get-profile/get-profile.use-case';
import { UpdateProfileUseCase } from './application/use-cases/update-profile/update-profile.use-case';
import { ProfileController } from './presentation/controllers/profile.controller';

@Module({
  imports: [IdentityAccessModule],
  controllers: [ProfileController],
  providers: [GetProfileUseCase, UpdateProfileUseCase],
})
export class UserProfileModule {}
