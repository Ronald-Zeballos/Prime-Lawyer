import { createHash, randomUUID } from 'node:crypto';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { extname, join, resolve, sep } from 'node:path';
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  DocumentFileStorage,
  ReadStoredDocumentFileQuery,
  ReadStoredDocumentFileResult,
  StoreDocumentFileCommand,
  StoredDocumentFile,
} from '../../application/use-cases/register-document/document-file-storage.port';

@Injectable()
export class LocalDocumentFileStorageAdapter implements DocumentFileStorage {
  constructor(private readonly configService: ConfigService) {}

  async store(command: StoreDocumentFileCommand): Promise<StoredDocumentFile> {
    const sanitizedOriginalName = this.sanitizeFileName(command.originalName);
    const extension = extname(sanitizedOriginalName);
    const baseName = sanitizedOriginalName.slice(
      0,
      sanitizedOriginalName.length - extension.length,
    );
    const storedFileName = `${randomUUID()}-${baseName || 'document'}${extension}`;
    const relativeDirectory = join(this.uploadsRoot, 'documents', command.caseFileId);
    const absoluteDirectory = this.resolveStoragePath(relativeDirectory);
    const absolutePath = resolve(absoluteDirectory, storedFileName);

    await mkdir(absoluteDirectory, { recursive: true });
    await writeFile(absolutePath, command.buffer);

    return {
      storagePath: join(relativeDirectory, storedFileName).replace(/\\/g, '/'),
      hash: createHash('sha256').update(command.buffer).digest('hex'),
    };
  }

  async read(
    query: ReadStoredDocumentFileQuery,
  ): Promise<ReadStoredDocumentFileResult> {
    const absolutePath = this.resolveStoragePath(query.storagePath);

    return {
      buffer: await readFile(absolutePath),
    };
  }

  private get uploadsRoot(): string {
    return this.configService.getOrThrow<string>('storage.uploadsPath');
  }

  private resolveStoragePath(storagePath: string): string {
    const absoluteUploadsRoot = resolve(process.cwd(), this.uploadsRoot);
    const absolutePath = resolve(process.cwd(), storagePath);

    if (
      absolutePath !== absoluteUploadsRoot &&
      !absolutePath.startsWith(`${absoluteUploadsRoot}${sep}`)
    ) {
      throw new Error('Resolved storage path is outside uploads root.');
    }

    return absolutePath;
  }

  private sanitizeFileName(fileName: string): string {
    return fileName.replace(/[^a-zA-Z0-9._-]/g, '_');
  }
}
