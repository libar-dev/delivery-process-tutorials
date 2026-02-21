@libar-docs
@libar-docs-pattern:UserRegistration
@libar-docs-status:roadmap
@libar-docs-core
@libar-docs-phase:1
@libar-docs-release:v0.1.0
@libar-docs-uses:UserService
@libar-docs-implements:UserService
@libar-docs-quarter:Q1-2026
Feature: User Registration
  As a new user
  I want to register an account
  So that I can access the system

  Background: Deliverables
    Given the following deliverables:
      | Deliverable             | Status  | Location                           |
      | Registration endpoint   | Pending | src/sample-sources/user-service.ts |
      | Email validation        | Pending | src/sample-sources/user-service.ts |
      | Duplicate check         | Pending | src/sample-sources/user-service.ts |

  Rule: Valid registrations create new accounts

    **Invariant:** Each email address maps to exactly one user account.
    **Rationale:** Prevents account confusion and ensures unique identity.

    @happy-path
    Scenario: Successful registration with valid email
      Given a valid email "alice@example.com"
      When the user submits the registration form
      Then a new account should be created
      And a confirmation email should be sent

    @happy-path
    Scenario: Registration assigns a unique user ID
      Given a valid email "bob@example.com"
      When the user submits the registration form
      Then the returned user ID should be a valid UUID
      And the user should be marked as active

  Rule: Invalid input is rejected before account creation

    **Invariant:** No user record is created for invalid input.
    **Rationale:** Prevents polluting the user store with bad data.

    @validation @business-rule
    Scenario: Registration fails with empty email
      Given an empty email ""
      When the user submits the registration form
      Then the registration should be rejected
      And an error message should indicate the email is invalid

  Rule: Duplicate emails are rejected

    **Invariant:** Registration with an existing email always fails.
    **Rationale:** Enforces unique identity constraint at the application boundary.

    @business-rule
    Scenario: Registration fails with duplicate email
      Given an existing user with email "alice@example.com"
      When another user tries to register with "alice@example.com"
      Then the registration should be rejected
      And an error message should indicate the email is taken
