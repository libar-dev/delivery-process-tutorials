@architect
@architect-pattern:UserAuthFlow
@architect-status:roadmap
@architect-api
@architect-phase:2
@architect-release:vNEXT
@architect-quarter:Q1-2026
@architect-implements:AuthHandler
@architect-uses:UserService
@architect-depends-on:UserRegistration
@architect-sequence-orchestrator:auth-handler
Feature: User Authentication Flow

  A sequence-annotated spec that models the runtime interaction between
  authentication components. Generates design review documents with
  sequence and component diagrams.

  Background: Deliverables
    Given the following deliverables:
      | Deliverable | Status | Location |
      | Credential validation | Pending | src/sample-sources/auth-handler.ts |
      | Session token creation | Pending | src/sample-sources/auth-handler.ts |
      | User lookup | Pending | src/sample-sources/user-service.ts |

  @architect-sequence-step:1
  @architect-sequence-module:user-service
  Rule: User lookup validates that the account exists and is active

    **Invariant:** Authentication always begins with a user lookup.
    No session is created for unknown or inactive users.
    **Rationale:** Prevents wasted work on credential validation
    for accounts that cannot authenticate.

    **Input:** email: string
    **Output:** UserRecord -- id, email, active

    **Verified by:** Lookup returns active user, Lookup rejects inactive user

    @acceptance-criteria @happy-path
    Scenario: Lookup returns active user
      Given a registered user with email "alice@example.com"
      And the user account is active
      When the authentication flow starts
      Then UserService.findByEmail returns the UserRecord

    @acceptance-criteria @architect-sequence-error
    Scenario: Lookup rejects inactive user
      Given a registered user with email "alice@example.com"
      And the user account has been deactivated
      When the authentication flow starts
      Then authentication fails with "Account deactivated"

  @architect-sequence-step:2
  @architect-sequence-module:auth-handler
  Rule: Credential validation checks the password against stored hash

    **Invariant:** Password comparison uses constant-time comparison
    to prevent timing attacks.
    **Rationale:** Variable-time string comparison leaks password
    length information through response timing.

    **Input:** UserRecord, password: string
    **Output:** AuthResult -- success, sessionId, error

    **Verified by:** Valid credentials pass, Invalid credentials fail securely

    @acceptance-criteria @happy-path
    Scenario: Valid credentials pass
      Given a valid UserRecord for "alice@example.com"
      When the password matches the stored hash
      Then AuthResult.success is true
      And a sessionId is generated

    @acceptance-criteria @architect-sequence-error
    Scenario: Invalid credentials fail securely
      Given a valid UserRecord for "alice@example.com"
      When the password does not match
      Then AuthResult.success is false
      And the error message is "Invalid credentials"
      And the error does not reveal whether email or password was wrong

  @architect-sequence-step:3
  @architect-sequence-module:event-store
  Rule: Successful authentication emits a domain event

    **Invariant:** Every successful login produces an auditable event.
    Failed logins also emit events for security monitoring.
    **Rationale:** Append-only event log provides complete audit trail
    for compliance and security incident investigation.

    **Input:** AuthResult, userId: string
    **Output:** DomainEvent -- type, payload, timestamp

    **Verified by:** Login success emits event, Login failure emits event

    @acceptance-criteria @happy-path
    Scenario: Login success emits event
      Given authentication succeeded for user "alice@example.com"
      When the event is recorded
      Then a DomainEvent with type "auth.login.success" is appended
      And the payload includes the userId and timestamp

    @acceptance-criteria
    Scenario: Login failure emits event
      Given authentication failed for user "alice@example.com"
      When the event is recorded
      Then a DomainEvent with type "auth.login.failure" is appended
      And the payload includes the attempted email and failure reason
