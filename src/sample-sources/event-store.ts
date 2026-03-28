/** @architect */

/**
 * @architect-pattern EventStore
 * @architect-status deferred
 * @architect-infra
 * @architect-arch-role infrastructure
 * @architect-arch-context persistence
 * @architect-arch-layer infrastructure
 * @architect-used-by UserService
 * @architect-extract-shapes DomainEvent
 * @architect-phase 3
 * @architect-release vNEXT
 * @architect-brief Append-only event store for domain event persistence
 * @architect-usecase "Persist a domain event after a user action"
 * @architect-usecase "Replay events for audit trail or debugging"
 * @architect-quarter Q2-2026
 * @architect-enables UserService
 * @architect-see-also UserService
 *
 * ## EventStore - Append-Only Event Storage
 *
 * Append-only event store for domain events.
 * Deferred pending infrastructure decisions.
 *
 * ### When to Use
 *
 * - When persisting domain events
 * - When replaying event history
 */

/** @architect-shape reference-sample */
export interface DomainEvent {
  type: string;
  payload: unknown;
  timestamp: number;
}

export class EventStore {
  private events: DomainEvent[] = [];

  append(type: string, payload: unknown): void {
    this.events.push({ type, payload, timestamp: Date.now() });
  }

  getAll(): DomainEvent[] {
    return [...this.events];
  }

  getByType(type: string): DomainEvent[] {
    return this.events.filter((e) => e.type === type);
  }
}
