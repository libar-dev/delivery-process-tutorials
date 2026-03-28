/** @architect */

/**
 * @architect-pattern UserService
 * @architect-status active
 * @architect-core
 * @architect-arch-role service
 * @architect-arch-context identity
 * @architect-arch-layer application
 * @architect-used-by AuthHandler
 * @architect-uses EventStore
 * @architect-extract-shapes UserRecord
 * @architect-phase 1
 * @architect-release v0.1.0
 * @architect-brief Core user lifecycle management service
 * @architect-usecase "Register a new user account via the signup form"
 * @architect-usecase "Look up a user by ID for profile display"
 * @architect-usecase "Deactivate a compromised user account"
 * @architect-quarter Q1-2026
 * @architect-depends-on EventStore
 * @architect-see-also AuthHandler, EventStore
 *
 * ## UserService - User Lifecycle Management
 *
 * Manages user lifecycle — registration, lookup, and deactivation.
 *
 * ### When to Use
 *
 * - When registering new users
 * - When looking up user information
 * - When deactivating user accounts
 */

/** @architect-shape reference-sample */
export interface UserRecord {
  id: string;
  email: string;
  active: boolean;
}

export class UserService {
  private users = new Map<string, UserRecord>();

  register(email: string): string {
    const id = crypto.randomUUID();
    this.users.set(id, { id, email, active: true });
    return id;
  }

  findById(id: string): UserRecord | null {
    return this.users.get(id) ?? null;
  }

  deactivate(id: string): boolean {
    const user = this.users.get(id);
    if (!user) return false;
    user.active = false;
    return true;
  }
}
