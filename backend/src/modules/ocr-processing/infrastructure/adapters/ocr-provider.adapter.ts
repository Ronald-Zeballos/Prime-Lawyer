export const OCR_PROVIDER = Symbol('OCR_PROVIDER');

export type ExtractOcrTextCommand = {
  originalName: string;
  fileType: string;
  uploadSource: string;
  storagePath: string;
  hash: string;
  buffer: Buffer;
};

export type ExtractOcrTextResult = {
  text: string;
  provider: string;
  mode: 'embedded_text' | 'simulated';
  confidence: number;
};

export interface OcrProvider {
  extractText(command: ExtractOcrTextCommand): Promise<ExtractOcrTextResult>;
}
