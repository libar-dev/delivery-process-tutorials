@libar-docs
@libar-docs-pattern:Authentication
@libar-docs-status:roadmap
@libar-docs-api
@libar-docs-phase:2
@libar-docs-release:vNEXT
@libar-docs-uses:UserService
@libar-docs-implements:AuthHandler
@libar-docs-depends-on:UserRegistration
@libar-docs-quarter:Q1-2026
Feature: Authentication
  As a registered user
  I want to log in to my account
  So that I can access protected resources

  Background: Deliverables
    Given the following deliverables:
      | Deliverable            | Status  | Location                           |
      | Login endpoint         | Pending | src/sample-sources/auth-handler.ts |
      | Session token creation | Pending | src/sample-sources/auth-handler.ts |

  Rule: Valid credentials grant access

    **Invariant:** A session token is only issued for valid credential pairs.
    **Rationale:** Prevents unauthorized access to the system.

    @happy-path
    Scenario: Successful login with valid credentials
      Given a registered user with email "alice@example.com"
      When the user submits valid login credentials
      Then a session token should be returned
      And the session should be marked as active

  Rule: Invalid credentials are rejected securely

    **Invariant:** Error messages never reveal whether the email or password was wrong.
    **Rationale:** Prevents credential enumeration attacks.

    @business-rule @validation
    Scenario: Login fails with wrong password
      Given a registered user with email "alice@example.com"
      When the user logs in with an incorrect password
      Then authentication should fail
      And the error should say "Invalid credentials"
