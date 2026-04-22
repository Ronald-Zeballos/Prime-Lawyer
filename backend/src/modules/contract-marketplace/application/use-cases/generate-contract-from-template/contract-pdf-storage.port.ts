export const CONTRACT_PDF_STORAGE = Symbol('CONTRACT_PDF_STORAGE');

export type StoreContractPdfCommand = {
  userId: string;
  contractInstanceId: string;
  fileName: string;
  buffer: Buffer;
};

export type StoredContractPdf = {
  storagePath: string;
};

export type ReadContractPdfQuery = {
  storagePath: string;
};

export type ReadContractPdfResult = {
  buffer: Buffer;
};

export interface ContractPdfStorage {
  store(command: StoreContractPdfCommand): Promise<StoredContractPdf>;
  read(query: ReadContractPdfQuery): Promise<ReadContractPdfResult>;
}
