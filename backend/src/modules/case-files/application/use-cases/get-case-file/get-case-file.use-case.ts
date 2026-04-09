import { Inject, Injectable } from '@nestjs/common';
import { NotFoundError } from '../../../../../shared/application/errors/not-found.error';
import { UseCase } from '../../../../../shared/application/use-case';
import {
  CASE_FILE_REPOSITORY,
  CaseFileRepository,
} from '../../../domain/repositories/case-file.repository';
import { CaseFileId } from '../../../domain/value-objects/case-file-id.vo';
import { CaseFileDto, toCaseFileDto } from '../../dto/case-file.dto';

export type GetCaseFileQuery = {
  id: string;
};

@Injectable()
export class GetCaseFileUseCase
  implements UseCase<GetCaseFileQuery, CaseFileDto>
{
  constructor(
    @Inject(CASE_FILE_REPOSITORY)
    private readonly caseFileRepository: CaseFileRepository,
  ) {}

  async execute(query: GetCaseFileQuery): Promise<CaseFileDto> {
    const caseFile = await this.caseFileRepository.findById(
      CaseFileId.create(query.id),
    );

    if (!caseFile) {
      throw new NotFoundError('Case file was not found.');
    }

    return toCaseFileDto(caseFile);
  }
}
