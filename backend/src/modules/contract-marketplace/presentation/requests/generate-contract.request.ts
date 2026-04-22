import { IsObject } from 'class-validator';

export class GenerateContractRequest {
  @IsObject()
  values!: Record<string, unknown>;
}
