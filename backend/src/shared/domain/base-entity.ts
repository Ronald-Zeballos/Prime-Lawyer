export abstract class BaseEntity<TId> {
  protected constructor(public readonly id: TId) {}

  equals(other?: BaseEntity<TId>): boolean {
    if (!other) {
      return false;
    }

    if (this === other) {
      return true;
    }

    return this.id === other.id;
  }
}
