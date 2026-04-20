import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  OBJECT_STORAGE,
  ObjectStorage,
} from './infrastructure/adapters/object-storage.adapter';
import { LocalObjectStorageAdapter } from './infrastructure/adapters/local-object-storage.adapter';

@Module({
  providers: [
    LocalObjectStorageAdapter,
    {
      provide: OBJECT_STORAGE,
      inject: [ConfigService, LocalObjectStorageAdapter],
      useFactory: (
        configService: ConfigService,
        localObjectStorageAdapter: LocalObjectStorageAdapter,
      ): ObjectStorage => {
        const storageDriver = (
          configService.get<string>('storage.driver') ?? 'local'
        )
          .trim()
          .toLowerCase();

        switch (storageDriver) {
          case 'local':
            return localObjectStorageAdapter;
          case 's3':
          case 'minio':
            throw new Error(
              `Storage driver "${storageDriver}" is not implemented yet. Keep STORAGE_DRIVER=local for the MVP.`,
            );
          default:
            throw new Error(`Unsupported storage driver: ${storageDriver}`);
        }
      },
    },
  ],
  exports: [OBJECT_STORAGE],
})
export class StorageManagementModule {}
