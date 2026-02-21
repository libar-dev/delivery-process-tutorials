/** @libar-docs */

/**
 * @libar-docs-pattern EventStore
 * @libar-docs-status deferred
 * @libar-docs-infra
 * @libar-docs-arch-role infrastructure
 * @libar-docs-arch-context persistence
 * @libar-docs-arch-layer infrastructure
 * @libar-docs-used-by UserService
 * @libar-docs-extract-shapes DomainEvent
 * @libar-docs-phase 3
 * @libar-docs-release vNEXT
 * @libar-docs-brief Append-only event store for domain event persistence
 * @libar-docs-usecase "Persist a domain event after a user action"
 * @libar-docs-usecase "Replay events for audit trail or debugging"
 * @libar-docs-quarter Q2-2026
 * @libar-docs-enables UserService
 * @libar-docs-see-also UserService
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

/** @libar-docs-shape reference-sample */
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
