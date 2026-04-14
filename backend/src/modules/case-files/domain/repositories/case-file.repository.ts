import { CaseFileEntity } from '../entities/case-file.entity';
import { CaseFileId } from '../value-objects/case-file-id.vo';

export const CASE_FILE_REPOSITORY = Symbol('CASE_FILE_REPOSITORY');

export type SearchCaseFilesFilters = {
  term?: string;
  status?: string;
  ownerUserId?: string;
  responsibleUserId?: string;
};

export interface CaseFileRepository {
  findById(id: CaseFileId): Promise<CaseFileEntity | null>;
  findByInternalCode(internalCode: string): Promise<CaseFileEntity | null>;
  search(filters?: SearchCaseFilesFilters): Promise<CaseFileEntity[]>;
  create(caseFile: CaseFileEntity): Promise<CaseFileEntity>;
  update(caseFile: CaseFileEntity): Promise<CaseFileEntity>;
}
