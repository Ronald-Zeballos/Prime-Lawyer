import { createHash, randomUUID } from 'node:crypto';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { extname, join, resolve, sep } from 'node:path';
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  ObjectStorage,
  ReadStoredObjectQuery,
  ReadStoredObjectResult,
  StoreObjectCommand,
  StoredObject,
} from './object-storage.adapter';

@Injectable()
export class LocalObjectStorageAdapter implements ObjectStorage {
  constructor(private readonly configService: ConfigService) {}

  async store(command: StoreObjectCommand): Promise<StoredObject> {
    const sanitizedOriginalName = this.sanitizeFileName(command.originalName);
    const extension = extname(sanitizedOriginalName);
    const baseName = sanitizedOriginalName.slice(
      0,
      sanitizedOriginalName.length - extension.length,
    );
    const storedFileName = `${randomUUID()}-${baseName || 'file'}${extension}`;
    const relativeDirectory = join(
      this.uploadsRoot,
      this.normalizeDirectoryPath(command.directoryPath),
    );
    const absoluteDirectory = this.resolveStoragePath(relativeDirectory);
    const absolutePath = resolve(absoluteDirectory, storedFileName);

    await mkdir(absoluteDirectory, { recursive: true });
    await writeFile(absolutePath, command.buffer);

    return {
      storagePath: join(relativeDirectory, storedFileName).replace(/\\/g, '/'),
      hash: createHash('sha256').update(command.buffer).digest('hex'),
      size: command.buffer.byteLength,
    };
  }

  async read(query: ReadStoredObjectQuery): Promise<ReadStoredObjectResult> {
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

  private normalizeDirectoryPath(value: string): string {
    const segments = value
      .split(/[\\/]+/)
      .map((segment) => this.sanitizePathSegment(segment))
      .filter((segment) => segment.length > 0);

    if (segments.length === 0) {
      return 'misc';
    }

    return join(...segments);
  }

  private sanitizePathSegment(value: string): string {
    return value.trim().replace(/[^a-zA-Z0-9._-]/g, '_');
  }

  private sanitizeFileName(fileName: string): string {
    return fileName.replace(/[^a-zA-Z0-9._-]/g, '_');
  }
}
