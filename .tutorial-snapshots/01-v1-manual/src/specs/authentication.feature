@architect
@architect-pattern:Authentication
@architect-status:roadmap
@architect-api
@architect-phase:2
@architect-release:vNEXT
@architect-uses:UserService
@architect-implements:AuthHandler
@architect-depends-on:UserRegistration
@architect-quarter:Q1-2026
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
