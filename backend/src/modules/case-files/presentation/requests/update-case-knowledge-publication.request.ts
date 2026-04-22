import { IsBoolean } from 'class-validator';

export class UpdateCaseKnowledgePublicationRequest {
  @IsBoolean()
  publish!: boolean;
}
