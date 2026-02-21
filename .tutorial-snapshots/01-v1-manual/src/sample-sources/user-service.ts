/** @libar-docs */

/**
 * @libar-docs-pattern UserService
 * @libar-docs-status active
 * @libar-docs-core
 * @libar-docs-arch-role service
 * @libar-docs-arch-context identity
 * @libar-docs-arch-layer application
 * @libar-docs-used-by AuthHandler
 * @libar-docs-uses EventStore
 * @libar-docs-extract-shapes UserRecord
 * @libar-docs-phase 1
 * @libar-docs-release v0.1.0
 * @libar-docs-brief Core user lifecycle management service
 * @libar-docs-usecase "Register a new user account via the signup form"
 * @libar-docs-usecase "Look up a user by ID for profile display"
 * @libar-docs-usecase "Deactivate a compromised user account"
 * @libar-docs-quarter Q1-2026
 * @libar-docs-depends-on EventStore
 * @libar-docs-see-also AuthHandler, EventStore
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

/** @libar-docs-shape reference-sample */
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
