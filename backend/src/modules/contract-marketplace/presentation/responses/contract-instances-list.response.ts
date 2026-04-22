import { ContractInstanceDto } from '../../application/dto/contract-instance.dto';
import { ContractInstanceResponse } from './contract-instance.response';

export class ContractInstancesListResponse {
  items!: ContractInstanceResponse[];

  static fromDto(items: ContractInstanceDto[]): ContractInstancesListResponse {
    return {
      items: items.map((item) => ContractInstanceResponse.fromDto(item)),
    };
  }
}
