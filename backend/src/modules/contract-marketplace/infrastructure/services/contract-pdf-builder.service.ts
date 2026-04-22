import { Injectable } from '@nestjs/common';
import { PDFDocument, StandardFonts, rgb } from 'pdf-lib';
import { ContractInstanceDto } from '../../application/dto/contract-instance.dto';

const PAGE_MARGIN = 48;
const BODY_FONT_SIZE = 11;
const LINE_HEIGHT = 16;

@Injectable()
export class ContractPdfBuilderService {
  async build(contract: ContractInstanceDto): Promise<Buffer> {
    const pdfDocument = await PDFDocument.create();
    const regularFont = await pdfDocument.embedFont(StandardFonts.Helvetica);
    const boldFont = await pdfDocument.embedFont(StandardFonts.HelveticaBold);

    let page = pdfDocument.addPage();
    let currentY = page.getHeight() - PAGE_MARGIN;

    const ensureSpace = (requiredHeight: number): void => {
      if (currentY - requiredHeight > PAGE_MARGIN) {
        return;
      }

      page = pdfDocument.addPage();
      currentY = page.getHeight() - PAGE_MARGIN;
    };

    const drawWrappedText = (params: {
      text: string;
      fontSize: number;
      font: any;
      color?: ReturnType<typeof rgb>;
    }): void => {
      const sanitizedText = this.sanitizePdfText(params.text);
      const maxWidth = page.getWidth() - PAGE_MARGIN * 2;
      const lines = this.wrapText(
        sanitizedText,
        maxWidth,
        params.font,
        params.fontSize,
      );

      ensureSpace(lines.length * LINE_HEIGHT + 8);

      for (const line of lines) {
        page.drawText(line, {
          x: PAGE_MARGIN,
          y: currentY,
          size: params.fontSize,
          font: params.font,
          color: params.color ?? rgb(0.14, 0.16, 0.18),
        });
        currentY -= LINE_HEIGHT;
      }
    };

    page.drawText(this.sanitizePdfText(contract.documentTitle), {
      x: PAGE_MARGIN,
      y: currentY,
      size: 18,
      font: boldFont,
      color: rgb(0.08, 0.12, 0.26),
    });
    currentY -= 28;

    drawWrappedText({
      text: contract.summary,
      fontSize: BODY_FONT_SIZE,
      font: regularFont,
      color: rgb(0.32, 0.35, 0.42),
    });
    currentY -= 8;

    for (const section of contract.sections) {
      ensureSpace(40);
      page.drawText(section.heading, {
        x: PAGE_MARGIN,
        y: currentY,
        size: 13,
        font: boldFont,
        color: rgb(0.08, 0.12, 0.26),
      });
      currentY -= 20;
      drawWrappedText({
        text: section.body,
        fontSize: BODY_FONT_SIZE,
        font: regularFont,
      });
      currentY -= 6;
    }

    if (contract.signatureLines.length > 0) {
      ensureSpace(32 + contract.signatureLines.length * 36);
      page.drawText('Firmas', {
        x: PAGE_MARGIN,
        y: currentY,
        size: 13,
        font: boldFont,
        color: rgb(0.08, 0.12, 0.26),
      });
      currentY -= 24;

      for (const signatureLine of contract.signatureLines) {
        page.drawLine({
          start: { x: PAGE_MARGIN, y: currentY },
          end: { x: PAGE_MARGIN + 220, y: currentY },
          thickness: 1,
          color: rgb(0.45, 0.48, 0.53),
        });
        currentY -= 16;
        drawWrappedText({
          text: `${signatureLine.label}: ${signatureLine.signerName}`,
          fontSize: 10,
          font: regularFont,
          color: rgb(0.32, 0.35, 0.42),
        });
        currentY -= 10;
      }
    }

    if (contract.notes.length > 0) {
      ensureSpace(26 + contract.notes.length * 20);
      page.drawText('Notas', {
        x: PAGE_MARGIN,
        y: currentY,
        size: 12,
        font: boldFont,
        color: rgb(0.08, 0.12, 0.26),
      });
      currentY -= 20;

      for (const note of contract.notes) {
        drawWrappedText({
          text: `- ${note}`,
          fontSize: 10,
          font: regularFont,
          color: rgb(0.32, 0.35, 0.42),
        });
      }
    }

    return Buffer.from(await pdfDocument.save());
  }

  private sanitizePdfText(value: string): string {
    return value
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^\x20-\x7E]/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
  }

  private wrapText(
    text: string,
    maxWidth: number,
    font: any,
    fontSize: number,
  ): string[] {
    const normalizedText = text.replace(/\s+/g, ' ').trim();

    if (normalizedText.length === 0) {
      return [''];
    }

    const words = normalizedText.split(' ');
    const lines: string[] = [];
    let currentLine = '';

    for (const word of words) {
      const candidate = currentLine.length === 0 ? word : `${currentLine} ${word}`;

      if (font.widthOfTextAtSize(candidate, fontSize) <= maxWidth) {
        currentLine = candidate;
        continue;
      }

      if (currentLine.length > 0) {
        lines.push(currentLine);
      }

      currentLine = word;
    }

    if (currentLine.length > 0) {
      lines.push(currentLine);
    }

    return lines;
  }
}
