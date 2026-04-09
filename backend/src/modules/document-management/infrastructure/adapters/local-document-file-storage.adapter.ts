import { createHash, randomUUID } from 'node:crypto';
import { mkdir, writeFile } from 'node:fs/promises';
import { extname, join, resolve } from 'node:path';
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  DocumentFileStorage,
  StoreDocumentFileCommand,
  StoredDocumentFile,
} from '../../application/use-cases/register-document/document-file-storage.port';

@Injectable()
export class LocalDocumentFileStorageAdapter implements DocumentFileStorage {
  constructor(private readonly configService: ConfigService) {}

  async store(command: StoreDocumentFileCommand): Promise<StoredDocumentFile> {
    const uploadsRoot = this.configService.getOrThrow<string>(
      'storage.uploadsPath',
    );
    const sanitizedOriginalName = this.sanitizeFileName(command.originalName);
    const extension = extname(sanitizedOriginalName);
    const baseName = sanitizedOriginalName.slice(
      0,
      sanitizedOriginalName.length - extension.length,
    );
    const storedFileName = `${randomUUID()}-${baseName || 'document'}${extension}`;
    const relativeDirectory = join(
      uploadsRoot,
      'documents',
      command.caseFileId,
    );
    const absoluteDirectory = resolve(process.cwd(), relativeDirectory);
    const absolutePath = resolve(absoluteDirectory, storedFileName);

    await mkdir(absoluteDirectory, { recursive: true });
    await writeFile(absolutePath, command.buffer);

    return {
      storagePath: join(relativeDirectory, storedFileName).replace(/\\/g, '/'),
      hash: createHash('sha256').update(command.buffer).digest('hex'),
    };
  }

  private sanitizeFileName(fileName: string): string {
    return fileName.replace(/[^a-zA-Z0-9._-]/g, '_');
  }
}
