import { Module } from '@nestjs/common';
import { IdentityAccessModule } from '../identity-access/identity-access.module';
import { SearchSemanticContentUseCase } from './application/use-cases/search-semantic-content/search-semantic-content.use-case';
import { SemanticSearchController } from './presentation/controllers/semantic-search.controller';

@Module({
  imports: [IdentityAccessModule],
  controllers: [SemanticSearchController],
  providers: [SearchSemanticContentUseCase],
  exports: [SearchSemanticContentUseCase],
})
export class SemanticSearchModule {}
