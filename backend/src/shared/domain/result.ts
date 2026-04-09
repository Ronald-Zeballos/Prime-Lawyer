export class Result<TValue> {
  private constructor(
    public readonly isSuccess: boolean,
    public readonly value?: TValue,
    public readonly error?: string,
  ) {}

  static ok<TValue>(value?: TValue): Result<TValue> {
    return new Result<TValue>(true, value);
  }

  static fail<TValue>(error: string): Result<TValue> {
    return new Result<TValue>(false, undefined, error);
  }
}
