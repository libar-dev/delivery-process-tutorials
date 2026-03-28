@architect
@architect-adr:001
@architect-adr-status:accepted
@architect-adr-category:testing
@architect-pattern:ADR001GherkinOnlyTesting
@architect-status:completed
@architect-completed:2026-03-28
@architect-core
Feature: ADR-001 - Gherkin-Only Testing Policy

  **Context:**
  Projects that adopt Libar Architect use `.feature` files as structured
  specifications that drive documentation generation. However, having both
  `.test.ts` files and `.feature` files creates a dual-testing approach
  where the Gherkin specs become stale decoration rather than living contracts.

  **Decision:**
  Enforce Gherkin-only testing for projects using Libar Architect:
  - All acceptance criteria must be `.feature` files
  - No parallel `.test.ts` files for behavior covered by specs
  - Edge cases use Scenario Outline with Examples tables

  **Consequences:**
  | Type | Impact |
  | Positive | Single source of truth for tests AND documentation |
  | Positive | Living documentation always matches test coverage |
  | Positive | Business rules extracted from Rule blocks are always current |
  | Negative | Scenario Outline syntax more verbose than parameterized tests |

  Background: Deliverables
    Given the following deliverables:
      | Deliverable | Status | Location |
      | Testing policy definition | complete | CLAUDE.md |

  Rule: Feature files serve as both specs and documentation source

    **Invariant:** Every `.feature` file is simultaneously an executable
    spec and a documentation source. This dual purpose is the primary
    benefit of Gherkin-only testing.
    **Rationale:** Parallel `.test.ts` files create a hidden test layer
    invisible to the documentation pipeline, undermining the single source
    of truth principle.
    **Verified by:** Gherkin-only policy enforced

    | Artifact | Without Gherkin-Only | With Gherkin-Only |
    | Tests | .test.ts (hidden from docs) | .feature (visible in docs) |
    | Business rules | Manually maintained | Extracted from Rule blocks |
    | Acceptance criteria | Implicit in test code | Explicit in scenarios |
    | Traceability | Manual cross-referencing | @architect-implements links |

  @acceptance-criteria
  Scenario: Gherkin-only policy enforced
    Given a project using Libar Architect
    When checking for test files
    Then only step definition files (.steps.ts) are allowed alongside .feature files
    And all behavioral tests are expressed as Gherkin scenarios
