export class Result<TValue, TError = Error> {
  private constructor(
    private readonly _isSuccess: boolean,
    private readonly _value?: TValue,
    private readonly _error?: TError,
  ) {}

  get isSuccess(): boolean {
    return this._isSuccess;
  }

  get isFailure(): boolean {
    return !this._isSuccess;
  }

  get value(): TValue {
    if (this.isFailure) {
      throw new Error('Cannot access the value of a failed result.');
    }

    return this._value as TValue;
  }

  get error(): TError {
    if (this.isSuccess) {
      throw new Error('Cannot access the error of a successful result.');
    }

    return this._error as TError;
  }

  static ok<TValue>(value: TValue): Result<TValue, never> {
    return new Result<TValue, never>(true, value);
  }

  static void(): Result<void, never> {
    return new Result<void, never>(true, undefined);
  }

  static fail<TError>(error: TError): Result<never, TError> {
    return new Result<never, TError>(false, undefined, error);
  }
}
