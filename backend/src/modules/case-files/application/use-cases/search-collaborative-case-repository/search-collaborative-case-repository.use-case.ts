import { Inject, Injectable } from '@nestjs/common';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  CaseVisibility,
  KnowledgeStatus,
} from '../../../domain/entities/case-file.entity';
import {
  CASE_FILE_REPOSITORY,
  CaseFileRepository,
} from '../../../domain/repositories/case-file.repository';
import { CaseFileDto, toCaseFileDto } from '../../dto/case-file.dto';

export type SearchCollaborativeCaseRepositoryQuery = {
  term?: string;
  processType?: string;
};

@Injectable()
export class SearchCollaborativeCaseRepositoryUseCase
  implements UseCase<SearchCollaborativeCaseRepositoryQuery, CaseFileDto[]>
{
  constructor(
    @Inject(CASE_FILE_REPOSITORY)
    private readonly caseFileRepository: CaseFileRepository,
  ) {}

  async execute(
    query: SearchCollaborativeCaseRepositoryQuery,
  ): Promise<CaseFileDto[]> {
    const caseFiles = await this.caseFileRepository.search({
      term: query.term,
      processType: query.processType,
      visibility: CaseVisibility.COMMUNITY,
      knowledgeStatus: KnowledgeStatus.PUBLISHED,
      limit: 50,
    });

    return caseFiles.map(toCaseFileDto);
  }
}
