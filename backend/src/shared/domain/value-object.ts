export abstract class ValueObject<TProps> {
  protected constructor(protected readonly props: TProps) {}

  get value(): TProps {
    return this.props;
  }

  equals(other?: ValueObject<TProps>): boolean {
    if (!other) {
      return false;
    }

    if (this === other) {
      return true;
    }

    return JSON.stringify(this.props) === JSON.stringify(other.props);
  }
}
