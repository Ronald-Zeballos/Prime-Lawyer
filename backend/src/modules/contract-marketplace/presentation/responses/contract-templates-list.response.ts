import { ContractTemplateDto } from '../../application/dto/contract-template.dto';
import { ContractTemplateResponse } from './contract-template.response';

export class ContractTemplatesListResponse {
  items!: ContractTemplateResponse[];

  static fromDto(items: ContractTemplateDto[]): ContractTemplatesListResponse {
    return {
      items: items.map((item) => ContractTemplateResponse.fromDto(item)),
    };
  }
}
