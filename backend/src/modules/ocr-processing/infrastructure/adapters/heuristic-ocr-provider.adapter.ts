import { Injectable } from '@nestjs/common';
import {
  ExtractOcrTextCommand,
  ExtractOcrTextResult,
  OcrProvider,
} from './ocr-provider.adapter';

@Injectable()
export class HeuristicOcrProviderAdapter implements OcrProvider {
  async extractText(
    command: ExtractOcrTextCommand,
  ): Promise<ExtractOcrTextResult> {
    const embeddedText = this.tryExtractEmbeddedText(command.buffer);

    if (embeddedText != null) {
      return {
        text: embeddedText,
        provider: 'local-heuristic-ocr',
        mode: 'embedded_text',
        confidence: 0.82,
      };
    }

    return {
      text: this.buildSimulatedText(command),
      provider: 'local-heuristic-ocr',
      mode: 'simulated',
      confidence: 0.41,
    };
  }

  private tryExtractEmbeddedText(buffer: Buffer): string | null {
    const printableText = buffer
      .toString('latin1')
      .replace(/\r/g, '\n')
      .replace(/[^\x20-\x7E\n]+/g, ' ');
    const lines = printableText
      .split('\n')
      .map((line) => line.trim())
      .filter((line) => line.length >= 6)
      .filter((line) => !this.isIgnoredLine(line))
      .slice(0, 40);
    const normalizedText = lines
      .join('\n')
      .replace(/[ \t]+/g, ' ')
      .replace(/\n{3,}/g, '\n\n')
      .trim();

    if (normalizedText.length < 80) {
      return null;
    }

    return normalizedText.slice(0, 6000);
  }

  private isIgnoredLine(line: string): boolean {
    const normalizedLine = line.toLowerCase();

    if (
      normalizedLine.startsWith('%pdf') ||
      normalizedLine.startsWith('obj') ||
      normalizedLine.startsWith('endobj') ||
      normalizedLine.startsWith('stream') ||
      normalizedLine.startsWith('endstream') ||
      normalizedLine.startsWith('xref') ||
      normalizedLine.startsWith('trailer') ||
      normalizedLine.startsWith('startxref')
    ) {
      return true;
    }

    const lettersOnly = normalizedLine.replace(/[^a-z]/g, '');

    return lettersOnly.length > 0 && /^(?:[a-z]{1,3})$/.test(lettersOnly);
  }

  private buildSimulatedText(command: ExtractOcrTextCommand): string {
    const fileNameKeywords = command.originalName
      .replace(/\.[^.]+$/, '')
      .split(/[^a-zA-Z0-9]+/)
      .map((token) => token.trim().toLowerCase())
      .filter((token) => token.length >= 3)
      .slice(0, 8);
    const keywordSummary = fileNameKeywords.length > 0
      ? fileNameKeywords.join(', ')
      : 'document, legal, evidence';
    const hashFingerprint = command.hash.slice(0, 12);

    return [
      `OCR MVP local result for "${command.originalName}".`,
      `The file is stored at ${command.storagePath} and was processed with the local heuristic OCR adapter.`,
      `File type detected: ${command.fileType}. Upload source: ${command.uploadSource}.`,
      `Reference terms inferred from the document name: ${keywordSummary}.`,
      `Fingerprint: ${hashFingerprint}.`,
      'No embedded readable text was found, so this OCR output is a consistent simulated extraction for the MVP.',
    ].join('\n');
  }
}
