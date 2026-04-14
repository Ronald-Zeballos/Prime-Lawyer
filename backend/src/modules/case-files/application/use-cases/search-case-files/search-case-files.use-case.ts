import { Inject, Injectable } from '@nestjs/common';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  CASE_FILE_REPOSITORY,
  CaseFileRepository,
} from '../../../domain/repositories/case-file.repository';
import { CaseFileDto, toCaseFileDto } from '../../dto/case-file.dto';

export type SearchCaseFilesQuery = {
  term?: string;
  status?: string;
  ownerUserId: string;
};

@Injectable()
export class SearchCaseFilesUseCase
  implements UseCase<SearchCaseFilesQuery, CaseFileDto[]>
{
  constructor(
    @Inject(CASE_FILE_REPOSITORY)
    private readonly caseFileRepository: CaseFileRepository,
  ) {}

  async execute(query: SearchCaseFilesQuery): Promise<CaseFileDto[]> {
    const caseFiles = await this.caseFileRepository.search({
      term: query.term,
      status: query.status,
      ownerUserId: query.ownerUserId,
    });

    return caseFiles.map(toCaseFileDto);
  }
}
