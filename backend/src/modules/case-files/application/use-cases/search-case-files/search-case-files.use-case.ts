import { Inject, Injectable } from '@nestjs/common';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  CASE_FILE_REPOSITORY,
  CaseFileRepository,
} from '../../../domain/repositories/case-file.repository';
import { CaseFileDto, toCaseFileDto } from '../../dto/case-file.dto';

export type SearchCaseFilesQuery = {
  term?: string;
  clientId?: string;
  status?: string;
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
      clientId: query.clientId,
      status: query.status,
    });

    return caseFiles.map(toCaseFileDto);
  }
}
