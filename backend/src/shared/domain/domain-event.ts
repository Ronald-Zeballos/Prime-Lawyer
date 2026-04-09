export abstract class DomainEvent {
  readonly occurredOn: Date;

  protected constructor(occurredOn?: Date) {
    this.occurredOn = occurredOn ?? new Date();
  }
}
