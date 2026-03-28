---
cwd: .
runme:
  id: 01KHZNPKYJVQ5V3CZD17MBHP9N
  version: v3
shell: bash
---

# Libar Architect: Interactive Tutorial

> Annotate your TypeScript, generate living documentation, and give AI agents the structured context they need -- all from code as the single source of truth.

**How to use this notebook:**

- **VS Code**: Install the [Runme extension](https://marketplace.visualstudio.com/items?itemName=stateful.runme), then open this file. Each code cell becomes executable.
- **CLI**: Run individual cells with `runme run <cell-name>` or all cells with `runme run --all`.
- **Read-only**: This is also a standard Markdown file you can read on GitHub or any Markdown viewer.

---

## Prerequisites

Verify your environment before starting:

```bash {"closeTerminalOnSuccess":"false","name":"check-prereqs"}
echo "Node.js: $(node --version)"
echo "npm:     $(npm --version)"
echo "OS:      $(uname -s) $(uname -r)"
echo ""
if [[ $(node --version | cut -d. -f1 | tr -d 'v') -ge 18 ]]; then
  echo "Node.js >= 18 requirement met"
else
  echo "ERROR: Node.js >= 18 required"
  exit 1
fi
```

## Reset Workspace

Start from a clean state. This removes all files created by the tutorial so you can follow along from scratch.

```bash {"excludeFromRunAll":"true","name":"reset-workspace"}
# Remove tutorial-created files
rm -rf src/ docs-generated/ tsconfig.json architect.config.ts

# Restore minimal package.json (deps only, no scripts)
cat > package.json << 'JSON'
{
  "name": "architect-mini-demo",
  "version": "1.0.0",
  "type": "module",
  "private": true,
  "dependencies": {
    "@libar-dev/architect": "1.0.0-pre.3"
  },
  "devDependencies": {
    "typescript": "^5.7.0",
    "tsx": "^4.19.0"
  }
}
JSON

echo "Workspace reset. Ready for tutorial."
```

---

## Part 1: Project Setup

> **What you learn:** Initialize a project with all dependencies.

### 1.1 Verify dependencies

The project has `package.json` with dependencies pre-declared. Let's verify they're installed:

```bash {"closeTerminalOnSuccess":"false","name":"verify-deps"}
echo "=== package.json ==="
node -e "const p=JSON.parse(require('fs').readFileSync('package.json','utf8')); console.log('name:', p.name); console.log('type:', p.type); console.log('private:', p.private)"
echo ""
echo "=== Dependencies ==="
npm ls @libar-dev/architect --depth=0 2>/dev/null || echo "Not installed yet"
echo ""
echo "=== Dev Dependencies ==="
npm ls typescript tsx --depth=0 2>/dev/null || echo "Not installed yet"
```

### 1.2 Install dependencies (if needed)

If the previous cell showed "Not installed yet", run this:

```bash {"excludeFromRunAll":"true","name":"install-deps"}
npm install
```

### 1.3 Create tsconfig.json

```bash {"name":"create-tsconfig"}
cat > tsconfig.json << 'JSON'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "outDir": "dist"
  },
  "include": ["src/**/*.ts", "architect.config.ts"]
}
JSON
echo "Created tsconfig.json"
```

### 1.4 Create folder structure

```bash {"name":"create-folders"}
mkdir -p src/sample-sources src/specs src/stubs
echo "Created:"
ls -d src/sample-sources src/specs src/stubs
```

### Checkpoint: Part 1

```bash {"closeTerminalOnSuccess":"false","name":"checkpoint-1"}
echo "=== Part 1 Checkpoint ==="
node -e "const p=JSON.parse(require('fs').readFileSync('package.json','utf8')); \
  console.log('type: module?', p.type === 'module' ? 'PASS' : 'FAIL'); \
  console.log('architect?', p.dependencies?.['@libar-dev/architect'] ? 'PASS' : 'FAIL'); \
  console.log('typescript?', p.devDependencies?.typescript ? 'PASS' : 'FAIL'); \
  console.log('tsx?', p.devDependencies?.tsx ? 'PASS' : 'FAIL')"
echo ""
for dir in src/sample-sources src/specs src/stubs; do
  [ -d "$dir" ] && echo "$dir exists: PASS" || echo "$dir exists: FAIL"
done
[ -f "tsconfig.json" ] && echo "tsconfig.json: PASS" || echo "tsconfig.json: FAIL"
```

---

## Part 2: Configuration

> **What you learn:** Configure sources, output, and presets.

### 2.1 Create `architect.config.ts`

This tells the system where to find your sources and where to write generated docs:

```bash {"name":"create-config"}
cat > architect.config.ts << 'TYPESCRIPT'
import { defineConfig } from "@libar-dev/architect/config";

export default defineConfig({
  preset: "libar-generic",
  sources: {
    typescript: ["src/sample-sources/**/*.ts"],
    features: ["src/specs/**/*.feature"],
    stubs: ["src/stubs/**/*.ts"],
  },
  output: {
    directory: "docs-generated",
    overwrite: true,
  },
});
TYPESCRIPT
echo "Created architect.config.ts"
```

Key fields:

| Field | Purpose |
|---|---|
| `preset` | Tag taxonomy preset -- determines the tag prefix and available categories |
| `sources.typescript` | Glob patterns for implementation TypeScript files |
| `sources.features` | Glob patterns for Gherkin `.feature` files |
| `sources.stubs` | Glob patterns for design-level stub TypeScript files |
| `output.directory` | Where generated docs are written |
| `output.overwrite` | Whether to overwrite existing files |

### 2.2 Available presets

| Preset | Tag Prefix | File Opt-In | Categories |
|---|---|---|---|
| `generic` | `@docs-` | `@docs` | 3: core, api, infra |
| `libar-generic` | `@architect-` | `@architect` | 3: core, api, infra |
| `ddd-es-cqrs` | `@architect-` | `@architect` | 21: full DDD taxonomy |

This tutorial uses `libar-generic` throughout.

### 2.3 Add npm scripts

Add the Architect Data API, doc generator, and linting scripts to `package.json`:

```bash {"name":"add-npm-scripts"}
node -e "
const pkg = JSON.parse(require('fs').readFileSync('package.json', 'utf8'));
pkg.scripts = {
  'architect:query':    'tsx ./node_modules/@libar-dev/architect/dist/cli/process-api.js',
  'architect:overview': 'tsx ./node_modules/@libar-dev/architect/dist/cli/process-api.js overview',
  'architect:status':   'tsx ./node_modules/@libar-dev/architect/dist/cli/process-api.js status',
  'architect:list':     'tsx ./node_modules/@libar-dev/architect/dist/cli/process-api.js list',
  'architect:tags':     'tsx ./node_modules/@libar-dev/architect/dist/cli/process-api.js tags',
  'architect:sources':  'tsx ./node_modules/@libar-dev/architect/dist/cli/process-api.js sources',
  'architect:rules':    'tsx ./node_modules/@libar-dev/architect/dist/cli/process-api.js rules',
  'architect:stubs':    'tsx ./node_modules/@libar-dev/architect/dist/cli/process-api.js stubs',

  'docs:patterns':       'tsx ./node_modules/@libar-dev/architect/dist/cli/generate-docs.js -g patterns -f',
  'docs:roadmap':        'tsx ./node_modules/@libar-dev/architect/dist/cli/generate-docs.js -g roadmap -f',
  'docs:reference':      'tsx ./node_modules/@libar-dev/architect/dist/cli/generate-docs.js -g reference-docs -f',
  'docs:overview':       'tsx ./node_modules/@libar-dev/architect/dist/cli/generate-docs.js -g overview-rdm -f',
  'docs:architecture':   'tsx ./node_modules/@libar-dev/architect/dist/cli/generate-docs.js -g architecture -f',
  'docs:business-rules': 'tsx ./node_modules/@libar-dev/architect/dist/cli/generate-docs.js -g business-rules -f',
  'docs:taxonomy':       'tsx ./node_modules/@libar-dev/architect/dist/cli/generate-docs.js -g taxonomy -f',
  'docs:adrs':           'tsx ./node_modules/@libar-dev/architect/dist/cli/generate-docs.js -g adrs -f',
  'docs:design-review':  'tsx ./node_modules/@libar-dev/architect/dist/cli/generate-docs.js -g design-review -f',
  'docs:all':            'tsx ./node_modules/@libar-dev/architect/dist/cli/generate-docs.js -g patterns,roadmap,reference-docs,overview-rdm,architecture,business-rules,taxonomy,adrs,design-review -f',
  'docs:list':           'tsx ./node_modules/@libar-dev/architect/dist/cli/generate-docs.js --list-generators',

  'lint:patterns': 'tsx ./node_modules/@libar-dev/architect/dist/cli/lint-patterns.js -i \"src/sample-sources/**/*.ts\"',
  'lint:validate': 'tsx ./node_modules/@libar-dev/architect/dist/cli/validate-patterns.js -i \"src/sample-sources/**/*.ts\" --features \"src/specs/**/*.feature\"'
};
require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
console.log('Added ' + Object.keys(pkg.scripts).length + ' npm scripts to package.json');
"
```

Two categories of scripts:

- **`architect:*`** -- Query the Architect Data API. Scan sources and return structured data (JSON or formatted text). Never write files.
- **`docs:*`** -- Run doc generators. Scan sources and write markdown files to `docs-generated/`.

### 2.4 Your first Architect Data API call

Even with no source files yet, the system runs:

```bash {"closeTerminalOnSuccess":"false","name":"first-overview"}
npm run architect:overview 2>&1
```

The Data API is your window into project state. We will use it after every change to see what the system detects.

### Checkpoint: Part 2

```bash {"closeTerminalOnSuccess":"false","name":"checkpoint-2"}
echo "=== Part 2 Checkpoint ==="
[ -f "architect.config.ts" ] && echo "architect.config.ts: PASS" || echo "architect.config.ts: FAIL"
node -e "const p=JSON.parse(require('fs').readFileSync('package.json','utf8')); console.log('npm scripts?', Object.keys(p.scripts || {}).length > 0 ? 'PASS (' + Object.keys(p.scripts).length + ' scripts)' : 'FAIL')"
npm run architect:overview 2>&1 | head -3
```

---

## Part 3: Your First Annotation

> **What you learn:** Annotate one TypeScript file and see it detected.

### 3.1 File opt-in

Every file needs a **file opt-in marker**: `/** @architect */` as a standalone JSDoc comment. Without it, the scanner ignores the file.

### 3.2 Create your first annotated source

This creates `src/sample-sources/user-service.ts` with the essential tags:

```bash {"name":"create-user-service-v1"}
cat > src/sample-sources/user-service.ts << 'TYPESCRIPT'
/** @architect */

/**
 * @architect-pattern UserService
 * @architect-status active
 * @architect-core
 * @architect-brief Core user lifecycle management service
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

export class UserService {
  private users = new Map<string, { id: string; email: string; active: boolean }>();

  register(email: string): string {
    const id = crypto.randomUUID();
    this.users.set(id, { id, email, active: true });
    return id;
  }

  findById(id: string): { id: string; email: string; active: boolean } | null {
    return this.users.get(id) ?? null;
  }

  deactivate(id: string): boolean {
    const user = this.users.get(id);
    if (!user) return false;
    user.active = false;
    return true;
  }
}
TYPESCRIPT
echo "Created src/sample-sources/user-service.ts"
```

Four tags is all you need to get started:

- `@architect-pattern UserService` -- names this pattern (required)
- `@architect-status active` -- FSM status: `roadmap` -> `active` -> `completed`, or `deferred`
- `@architect-core` -- category assignment (flag tag -- no value needed)
- `@architect-brief` -- short description for summary tables

### 3.3 See it detected

```bash {"closeTerminalOnSuccess":"false","name":"overview-after-first"}
npm run architect:overview 2>&1
```

> **Expected:** `1 patterns (0 completed, 1 active, 0 planned) = 0%`

Verify which files the scanner found:

```bash {"closeTerminalOnSuccess":"false","name":"sources-after-first"}
npm run architect:sources 2>&1
```

### Recap: Part 3

Minimum viable annotation: `@architect` (opt-in), `@architect-pattern` (name), `@architect-status` (lifecycle), and a category flag (`-core`, `-api`, or `-infra`).

---

## Part 4: Adding Richness Layer by Layer

> **What you learn:** Layer in architecture, enrichment, and shape extraction tags.

### 4.1-4.3 Add all richness tags

Now we replace `user-service.ts` with the full version including architecture tags, enrichment tags, and shape extraction:

```bash {"name":"create-user-service-v2"}
cat > src/sample-sources/user-service.ts << 'TYPESCRIPT'
/** @architect */

/**
 * @architect-pattern UserService
 * @architect-status active
 * @architect-core
 * @architect-arch-role service
 * @architect-arch-context identity
 * @architect-arch-layer application
 * @architect-extract-shapes UserRecord
 * @architect-phase 1
 * @architect-release v0.1.0
 * @architect-brief Core user lifecycle management service
 * @architect-usecase "Register a new user account via the signup form"
 * @architect-usecase "Look up a user by ID for profile display"
 * @architect-usecase "Deactivate a compromised user account"
 * @architect-quarter Q1-2026
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
TYPESCRIPT
echo "Updated src/sample-sources/user-service.ts with richness tags"
```

### Tag groups added

**Architecture tags** -- place your pattern in a structured topology:

| Tag | Example | Purpose |
|---|---|---|
| `@architect-arch-role` | `service` | Component type |
| `@architect-arch-context` | `identity` | Bounded context (creates diagram subgraphs) |
| `@architect-arch-layer` | `application` | Architecture layer |

**Enrichment tags** -- drive roadmaps and detail pages:

| Tag | Example | Purpose |
|---|---|---|
| `@architect-usecase` | `"Register a new user..."` | Use cases (quoted, repeatable) |
| `@architect-quarter` | `Q1-2026` | Timeline tracking |
| `@architect-phase` | `1` | Roadmap phase number |
| `@architect-release` | `v0.1.0` | Target release version |

**Shape extraction** -- pulls TypeScript interfaces into docs:

| Tag | Example | Purpose |
|---|---|---|
| `@architect-extract-shapes` | `UserRecord` | Extract named types into docs |
| `@architect-shape` | `reference-sample` | Mark an interface for shape discovery |

### Verify the enriched tags

```bash {"closeTerminalOnSuccess":"false","name":"tags-after-richness"}
npm run architect:tags 2>&1
```

### Check overview with phases

```bash {"closeTerminalOnSuccess":"false","name":"overview-after-richness"}
npm run architect:overview 2>&1
```

> **Expected:** 2 patterns (UserService + UserRecord shape), Phase 1: Inception visible.

---

## Part 5: Relationships & Multiple Sources

> **What you learn:** Connect multiple files into a dependency graph.

### 5.1 Add relationships to user-service.ts

Update `user-service.ts` with relationship tags (`used-by`, `uses`, `depends-on`, `see-also`):

```bash {"name":"create-user-service-final"}
cat > src/sample-sources/user-service.ts << 'TYPESCRIPT'
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
TYPESCRIPT
echo "Updated src/sample-sources/user-service.ts with relationship tags"
```

**Relationship tags:**

| Tag | Example | Purpose |
|---|---|---|
| `@architect-uses` | `EventStore` | Direct dependency (solid arrow in diagrams) |
| `@architect-used-by` | `AuthHandler` | Reverse dependency |
| `@architect-depends-on` | `EventStore` | Roadmap sequencing (dashed arrow) |
| `@architect-enables` | `UserService` | Reverse sequencing |
| `@architect-see-also` | `AuthHandler, EventStore` | Cross-reference |

### 5.2 Create AuthHandler

```bash {"name":"create-auth-handler"}
cat > src/sample-sources/auth-handler.ts << 'TYPESCRIPT'
/** @architect */

/**
 * @architect-pattern AuthHandler
 * @architect-status roadmap
 * @architect-api
 * @architect-arch-role service
 * @architect-arch-context identity
 * @architect-arch-layer application
 * @architect-uses UserService
 * @architect-extract-shapes AuthResult
 * @architect-phase 2
 * @architect-release vNEXT
 * @architect-brief Authentication and session management handler
 * @architect-usecase "Authenticate a user with email and password"
 * @architect-usecase "Validate an active session token"
 * @architect-depends-on UserService
 * @architect-quarter Q1-2026
 * @architect-see-also UserService
 *
 * ## AuthHandler - Authentication & Sessions
 *
 * Handles authentication and session management.
 *
 * ### When to Use
 *
 * - When authenticating user credentials
 * - When creating or validating sessions
 */

/** @architect-shape reference-sample */
export interface AuthResult {
  success: boolean;
  sessionId?: string;
  error?: string;
}

export class AuthHandler {
  authenticate(email: string, password: string): AuthResult {
    if (email.length === 0 || password.length < 8) {
      return { success: false, error: "Invalid credentials" };
    }
    return { success: true, sessionId: `session-${Date.now()}` };
  }

  createSession(userId: string): string {
    return `session-${userId}-${Date.now()}`;
  }
}
TYPESCRIPT
echo "Created src/sample-sources/auth-handler.ts"
```

### 5.3 Create EventStore

```bash {"name":"create-event-store"}
cat > src/sample-sources/event-store.ts << 'TYPESCRIPT'
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
TYPESCRIPT
echo "Created src/sample-sources/event-store.ts"
```

### 5.4 See the dependency graph

```bash {"closeTerminalOnSuccess":"false","name":"overview-with-deps"}
npm run architect:overview 2>&1
```

> **Expected:** 6 patterns, blocking chain: AuthHandler -> UserService -> EventStore.

### 5.5 Explore the dependency tree

```bash {"closeTerminalOnSuccess":"false","name":"dep-tree-auth"}
npm run architect:query -- dep-tree AuthHandler 2>&1
```

### 5.6 Bounded contexts

```bash {"closeTerminalOnSuccess":"false","name":"arch-contexts"}
npm run architect:query -- arch context 2>&1
```

### 5.7 Filter by status

```bash {"closeTerminalOnSuccess":"false","name":"list-roadmap"}
npm run architect:query -- list --status roadmap 2>&1
```

### Checkpoint: Part 5

```bash {"closeTerminalOnSuccess":"false","name":"checkpoint-5"}
echo "=== Part 5 Checkpoint ==="
echo ""
echo "--- Sources (expect 3 TypeScript files) ---"
npm run architect:sources 2>&1 | grep -E '"count"|"file"'
echo ""
echo "--- Overview (expect 6 patterns) ---"
npm run architect:overview 2>&1 | head -8
echo ""
echo "--- Contexts (expect identity + persistence) ---"
npm run architect:query -- arch context 2>&1 | grep '"context"'
```

---

## Part 6: Generate Documentation

> **What you learn:** Generate pattern registry and roadmap from annotations.

### 6.1 Generate the Pattern Registry

```bash {"closeTerminalOnSuccess":"false","name":"gen-patterns"}
npm run docs:patterns 2>&1
```

`PATTERNS.md` is the index of all patterns. `patterns/*.md` are per-pattern detail pages.

### 6.2 Generate the Roadmap

```bash {"closeTerminalOnSuccess":"false","name":"gen-roadmap"}
npm run docs:roadmap 2>&1
```

`ROADMAP.md` organizes patterns by phase. Phase names come from the 6-phase-standard workflow.

### 6.3 Inspect generated files

```bash {"closeTerminalOnSuccess":"false","name":"list-generated"}
echo "=== Generated Files ==="
find docs-generated -name "*.md" -type f | sort
echo ""
echo "Total files: $(find docs-generated -name "*.md" -type f | wc -l | tr -d ' ')"
```

### Checkpoint: Part 6

```bash {"closeTerminalOnSuccess":"false","name":"checkpoint-6"}
echo "=== Part 6 Checkpoint ==="
for f in docs-generated/PATTERNS.md docs-generated/ROADMAP.md; do
  [ -f "$f" ] && echo "$f: PASS" || echo "$f: FAIL"
done
[ -d "docs-generated/patterns" ] && echo "patterns/ dir: PASS ($(ls docs-generated/patterns/*.md 2>/dev/null | wc -l | tr -d ' ') files)" || echo "patterns/ dir: FAIL"
[ -d "docs-generated/phases" ] && echo "phases/ dir: PASS ($(ls docs-generated/phases/*.md 2>/dev/null | wc -l | tr -d ' ') files)" || echo "phases/ dir: FAIL"
```

---

## Part 7: Plan-Level Specs (Gherkin Features)

> **What you learn:** Write plan-level specs with business rules.

TypeScript annotations describe what exists. Gherkin features describe what needs to be built -- acceptance criteria, deliverables, and business rules.

### 7.1 Gherkin primer

Tags before `Feature:` are metadata. `Rule:` blocks define business constraints (extracted as invariants). `Scenario:` blocks are test cases.

**Important:** Gherkin tags use **colon syntax**, not spaces: `@architect-pattern:UserRegistration` (vs TypeScript's `@architect-pattern UserService`).

### 7.2 Create user-registration.feature

```bash {"name":"create-user-reg-feature"}
cat > src/specs/user-registration.feature << 'GHERKIN'
@architect
@architect-pattern:UserRegistration
@architect-status:roadmap
@architect-core
@architect-phase:1
@architect-release:v0.1.0
@architect-uses:UserService
@architect-implements:UserService
@architect-quarter:Q1-2026
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
GHERKIN
echo "Created src/specs/user-registration.feature"
```

### 7.3 Create authentication.feature

```bash {"name":"create-auth-feature"}
cat > src/specs/authentication.feature << 'GHERKIN'
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
GHERKIN
echo "Created src/specs/authentication.feature"
```

### 7.4 Query business rules

```bash {"closeTerminalOnSuccess":"false","name":"query-rules"}
npm run architect:rules 2>&1
```

> **Expected:** 5 business rules from 2 Gherkin features.

### 7.5 Generate business rules docs

```bash {"closeTerminalOnSuccess":"false","name":"gen-business-rules"}
npm run docs:business-rules 2>&1
```

### 7.6 Check enriched overview

```bash {"closeTerminalOnSuccess":"false","name":"overview-after-gherkin"}
npm run architect:overview 2>&1
```

> **Expected:** 8 patterns (3 TS + 3 shapes + 2 Gherkin), blocking includes Authentication -> UserRegistration.

### 7.7 Verify all sources

```bash {"closeTerminalOnSuccess":"false","name":"sources-after-gherkin"}
npm run architect:sources 2>&1
```

### Checkpoint: Part 7

```bash {"closeTerminalOnSuccess":"false","name":"checkpoint-7"}
echo "=== Part 7 Checkpoint ==="
echo ""
echo "--- Sources ---"
npm run architect:sources 2>&1 | grep -E '"type"|"count"'
echo ""
echo "--- Rules ---"
npm run architect:rules 2>&1 | grep '"totalRules"'
echo ""
echo "--- Business Rules Doc ---"
[ -f "docs-generated/BUSINESS-RULES.md" ] && echo "BUSINESS-RULES.md: PASS" || echo "BUSINESS-RULES.md: FAIL"
```

---

## Part 8: Design Stubs

> **What you learn:** Describe future implementations.

Design stubs describe a pattern's design before the implementation exists -- making "not yet built" parts visible.

### 8.1 Create notification-service.stub.ts

```bash {"name":"create-notification-stub"}
cat > src/stubs/notification-service.stub.ts << 'TYPESCRIPT'
/** @architect */

/**
 * @architect-pattern NotificationService
 * @architect-status roadmap
 * @architect-infra
 * @architect-arch-role service
 * @architect-arch-context identity
 * @architect-arch-layer infrastructure
 * @architect-target src/sample-sources/notification-service.ts
 * @architect-since design-session-1
 * @architect-uses AuthHandler
 * @architect-phase 2
 * @architect-release vNEXT
 * @architect-brief Notification service for auth lifecycle events
 * @architect-usecase "Send welcome email after user registration"
 * @architect-usecase "Send login alert for new device"
 * @architect-quarter Q2-2026
 * @architect-extract-shapes NotificationConfig, NotificationResult
 *
 * ## NotificationService - Auth Event Notifications
 *
 * Sends notifications (email, SMS) when authentication lifecycle
 * events occur. Stub — target implementation does not exist yet.
 *
 * ### Design Decisions
 *
 * AD-1: Use event-driven notifications (not inline calls)
 * AD-2: Support multiple channels via strategy pattern
 *
 * ### When to Use
 *
 * - When sending post-registration welcome emails
 * - When alerting users about new device logins
 */

/** @architect-shape reference-sample */
export interface NotificationConfig {
  channel: "email" | "sms";
  template: string;
  recipientId: string;
}

/** @architect-shape reference-sample */
export interface NotificationResult {
  sent: boolean;
  channel: string;
  timestamp: Date;
}
TYPESCRIPT
echo "Created src/stubs/notification-service.stub.ts"
```

Stub-specific tags:

| Tag | Example | Purpose |
|---|---|---|
| `@architect-target` | `src/sample-sources/notification-service.ts` | Path where the real implementation will live |
| `@architect-since` | `design-session-1` | Which design session created the stub |

### 8.2 Query stubs

```bash {"closeTerminalOnSuccess":"false","name":"query-stubs"}
npm run architect:stubs 2>&1
```

> **Expected:** 3 stub entries (NotificationService + 2 shapes), all with `targetExists: false`.

### Checkpoint: Part 8

```bash {"closeTerminalOnSuccess":"false","name":"checkpoint-8"}
echo "=== Part 8 Checkpoint ==="
[ -f "src/stubs/notification-service.stub.ts" ] && echo "stub file: PASS" || echo "stub file: FAIL"
npm run architect:stubs 2>&1 | grep '"unresolvedCount"'
npm run architect:sources 2>&1 | grep -A2 '"Stub'
```

---

## Part 9: Decision Records

> **What you learn:** Capture architecture decisions as Gherkin specs with ADR tags.

Architecture decisions are often discussed, agreed upon, then lost. ADR (Architecture Decision Record) specs capture them as structured Gherkin features that the system can extract, index, and include in generated documentation.

### 9.1 Create decisions directory

```bash {"name":"create-decisions-dir"}
mkdir -p src/decisions
echo "Created src/decisions/"
```

### 9.2 Create an ADR spec

This ADR captures a testing policy decision -- the kind of foundational decision that shapes how a team works:

```bash {"name":"create-adr-001"}
cat > src/decisions/adr-001-gherkin-testing.feature << 'GHERKIN'
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
GHERKIN
echo "Created src/decisions/adr-001-gherkin-testing.feature"
```

ADR-specific tags:

| Tag | Example | Purpose |
|---|---|---|
| `@architect-adr` | `001` | ADR number |
| `@architect-adr-status` | `accepted` | Decision status: proposed, accepted, deprecated, superseded |
| `@architect-adr-category` | `testing` | Decision category for grouping |

The feature description follows **Context / Decision / Consequences** structure, which the ADR generator parses into structured output.

### 9.3 Update configuration

Add the decisions directory to the features source and scope the `adrs` generator to only decision files:

```bash {"name":"update-config-decisions"}
cat > architect.config.ts << 'TYPESCRIPT'
import { defineConfig } from "@libar-dev/architect/config";

export default defineConfig({
  preset: "libar-generic",
  sources: {
    typescript: ["src/sample-sources/**/*.ts"],
    features: ["src/specs/**/*.feature", "src/decisions/**/*.feature"],
    stubs: ["src/stubs/**/*.ts"],
  },
  output: {
    directory: "docs-generated",
    overwrite: true,
  },
  generatorOverrides: {
    adrs: {
      replaceFeatures: ["src/decisions/**/*.feature"],
    },
  },
});
TYPESCRIPT
echo "Updated architect.config.ts with decisions source and generator override"
```

The `generatorOverrides.adrs.replaceFeatures` tells the ADR generator to use *only* decision files, not the full features glob. Without this, every Gherkin spec would appear in the decisions output.

### 9.4 Generate ADR documentation

```bash {"closeTerminalOnSuccess":"false","name":"gen-adrs"}
npm run docs:adrs 2>&1
```

### 9.5 Verify the decision is queryable

```bash {"closeTerminalOnSuccess":"false","name":"overview-after-adr"}
npm run architect:overview 2>&1
```

> **Expected:** Pattern count increases (ADR added as a completed pattern), completion percentage rises above 0%.

### Checkpoint: Part 9

```bash {"closeTerminalOnSuccess":"false","name":"checkpoint-9-decisions"}
echo "=== Part 9 Checkpoint ==="
[ -f "src/decisions/adr-001-gherkin-testing.feature" ] && echo "ADR file: PASS" || echo "ADR file: FAIL"
[ -f "docs-generated/DECISIONS.md" ] && echo "DECISIONS.md: PASS" || echo "DECISIONS.md: FAIL"
[ -d "docs-generated/decisions" ] && echo "decisions/ dir: PASS" || echo "decisions/ dir: FAIL"
```

---

## Part 10: Design Reviews

> **What you learn:** Generate sequence and component diagrams from annotated Gherkin specs.

Design reviews visualize runtime interaction flows. By adding `@architect-sequence-*` tags to a Gherkin spec, you get auto-generated Mermaid diagrams that show how components interact, what data flows between them, and where errors are handled.

### 10.1 Create a sequence-annotated spec

This spec models the authentication flow across three components. Each `Rule:` block maps to a step in the sequence diagram:

```bash {"name":"create-design-review-spec"}
cat > src/specs/user-auth-flow.feature << 'GHERKIN'
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
GHERKIN
echo "Created src/specs/user-auth-flow.feature"
```

Sequence annotation tags (applied to Rule blocks):

| Tag | Level | Purpose |
|---|---|---|
| `@architect-sequence-orchestrator` | Feature | Names the coordinator module |
| `@architect-sequence-step` | Rule | Execution order (1, 2, 3...) |
| `@architect-sequence-module` | Rule | Maps this step to a source module |
| `@architect-sequence-error` | Scenario | Marks error/alternative paths |

Data flow markers in Rule descriptions:
- `**Input:**` defines the data type flowing into the step
- `**Output:**` defines the data type returned from the step

### 10.2 Generate the design review

```bash {"closeTerminalOnSuccess":"false","name":"gen-design-review"}
npm run docs:design-review 2>&1
```

### 10.3 Inspect the generated review

```bash {"closeTerminalOnSuccess":"false","name":"show-design-review"}
cat docs-generated/design-reviews/user-auth-flow.md
```

The design review contains:
- **Sequence diagram** -- Mermaid `sequenceDiagram` showing runtime interaction flow, with error paths as `alt` blocks
- **Component diagram** -- Mermaid `graph LR` showing data types flowing between modules
- **Key type definitions** -- Table of types with fields, producers, and consumers
- **Design questions** -- Verification checklist generated from the diagram properties

All of this is derived from the `@architect-sequence-*` annotations and `**Input:**`/`**Output:**` markers in your Gherkin spec. Change the spec, regenerate, and the diagrams update.

### Checkpoint: Part 10

```bash {"closeTerminalOnSuccess":"false","name":"checkpoint-10-design-review"}
echo "=== Part 10 Checkpoint ==="
[ -f "src/specs/user-auth-flow.feature" ] && echo "flow spec: PASS" || echo "flow spec: FAIL"
[ -f "docs-generated/design-reviews/user-auth-flow.md" ] && echo "design review: PASS" || echo "design review: FAIL"
npm run architect:sources 2>&1 | grep '"count"'
```

---

## Part 11: Full Generation & Linting

> **What you learn:** Generate all docs, add reference docs, and lint annotations.

### 11.1 Generate everything

```bash {"closeTerminalOnSuccess":"false","name":"gen-all"}
npm run docs:all 2>&1
```

> **Expected:** 9 generators, 30 files written.

### 11.2 List all generated files

```bash {"closeTerminalOnSuccess":"false","name":"list-all-generated"}
echo "=== All Generated Files ==="
find docs-generated -name "*.md" -type f | sort
echo ""
echo "Total: $(find docs-generated -name "*.md" -type f | wc -l | tr -d ' ') files"
```

### 11.3 Add referenceDocConfigs to configuration

Add a `referenceDocConfigs` entry to `architect.config.ts` for a custom composite document scoped to specific bounded contexts:

```bash {"name":"add-reference-config"}
cat > architect.config.ts << 'TYPESCRIPT'
import { defineConfig } from "@libar-dev/architect/config";

export default defineConfig({
  preset: "libar-generic",
  sources: {
    typescript: ["src/sample-sources/**/*.ts"],
    features: ["src/specs/**/*.feature", "src/decisions/**/*.feature"],
    stubs: ["src/stubs/**/*.ts"],
  },
  output: {
    directory: "docs-generated",
    overwrite: true,
  },
  generatorOverrides: {
    adrs: {
      replaceFeatures: ["src/decisions/**/*.feature"],
    },
  },
  referenceDocConfigs: [
    {
      title: "Identity & Persistence Reference",
      conventionTags: [],
      behaviorCategories: ["core", "api", "infra"],
      diagramScopes: [
        {
          archContext: ["identity", "persistence"],
          direction: "LR",
          title: "System Architecture",
          diagramType: "graph",
          showEdgeLabels: true,
        },
      ],
      claudeMdSection: "reference",
      docsFilename: "IDENTITY-PERSISTENCE-REFERENCE.md",
      claudeMdFilename: "identity-persistence-reference.md",
    },
  ],
});
TYPESCRIPT
echo "Updated architect.config.ts with referenceDocConfigs"
```

### 11.4 Generate the reference doc

```bash {"closeTerminalOnSuccess":"false","name":"gen-reference"}
npm run docs:reference 2>&1
```

### 11.5 List available generators

```bash {"closeTerminalOnSuccess":"false","name":"list-generators"}
npm run docs:list 2>&1
```

### 11.6 Lint patterns

```bash {"closeTerminalOnSuccess":"false","name":"lint-patterns"}
npm run lint:patterns 2>&1 || true
```

> **Note:** 3 errors are expected -- from `@architect-shape` annotations on interfaces that lack their own `@architect-pattern` names. This is normal.

### Checkpoint: Part 11

```bash {"closeTerminalOnSuccess":"false","name":"checkpoint-11"}
echo "=== Part 11 Checkpoint ==="
echo ""
total=$(find docs-generated -name "*.md" -type f | wc -l | tr -d ' ')
echo "Generated files: $total (expected: 30+)"
echo ""
for f in docs-generated/PATTERNS.md docs-generated/ROADMAP.md docs-generated/ARCHITECTURE.md docs-generated/OVERVIEW.md docs-generated/BUSINESS-RULES.md docs-generated/TAXONOMY.md; do
  basename="$(basename $f)"
  [ -f "$f" ] && echo "$basename: PASS" || echo "$basename: FAIL"
done
```

---

## Part 12: Advanced Architect Data API

> **What you learn:** Query project state with advanced CLI commands.

### 12.1 Architecture neighborhood

See everything UserService touches -- uses, used-by, same-context peers:

```bash {"closeTerminalOnSuccess":"false","name":"arch-neighborhood"}
npm run architect:query -- arch neighborhood UserService 2>&1
```

### 12.2 Blocking analysis

Find patterns stuck on incomplete dependencies:

```bash {"closeTerminalOnSuccess":"false","name":"arch-blocking"}
npm run architect:query -- arch blocking 2>&1
```

### 12.3 Dangling references

Find broken references to nonexistent pattern names:

```bash {"closeTerminalOnSuccess":"false","name":"arch-dangling"}
npm run architect:query -- arch dangling 2>&1
```

> **Expected:** Empty array -- all references resolve correctly.

### 12.4 Full pattern detail

Get complete metadata for a single pattern:

```bash {"closeTerminalOnSuccess":"false","name":"pattern-detail"}
npm run architect:query -- pattern UserService 2>&1
```

### 12.5 Output modifiers

```bash {"closeTerminalOnSuccess":"false","name":"count-roadmap"}
echo "--- How many roadmap patterns? ---"
npm run architect:query -- list --status roadmap --count 2>&1
echo ""
echo "--- All pattern names ---"
npm run architect:query -- list --names-only 2>&1
```

### 12.6 Final overview

```bash {"closeTerminalOnSuccess":"false","name":"final-overview"}
npm run architect:overview 2>&1
```

> **Expected:** 13 patterns, 4 blocking chains, completion > 0% (ADR is completed).

---

## Results Summary

### Final verification

```bash {"closeTerminalOnSuccess":"false","name":"final-verification"}
echo "========================================"
echo "  TUTORIAL RESULTS SUMMARY"
echo "========================================"
echo ""

echo "--- Source Files ---"
echo "TypeScript: $(ls src/sample-sources/*.ts 2>/dev/null | wc -l | tr -d ' ')"
echo "Gherkin:    $(ls src/specs/*.feature 2>/dev/null | wc -l | tr -d ' ')"
echo "Stubs:      $(ls src/stubs/*.ts 2>/dev/null | wc -l | tr -d ' ')"
echo "Total:      $(find src -name '*.ts' -o -name '*.feature' | wc -l | tr -d ' ')"
echo ""

echo "--- Generated Docs ---"
echo "Total files: $(find docs-generated -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')"
echo ""

echo "--- Patterns ---"
npm run architect:query -- list --count 2>&1 | grep '"data"'
echo ""

echo "--- Business Rules ---"
npm run architect:rules 2>&1 | grep '"totalRules"'
echo ""

echo "--- Blocking Chains ---"
npm run architect:query -- arch blocking 2>&1 | grep '"pattern"'
echo ""

echo "--- Bounded Contexts ---"
npm run architect:query -- arch context 2>&1 | grep '"context"'
echo ""

echo "========================================"
echo "  All 12 parts complete!"
echo "========================================"
```

---

## Appendix: Tag Quick Reference

### Required Tags

| Tag | Format | Example |
|---|---|---|
| `@architect` | file opt-in | `/** @architect */` |
| `@architect-pattern` | `Name` | `@architect-pattern UserService` |

### Status FSM

```text {"ignore":"true"}
roadmap -> active -> completed
  |         |
  v         v
deferred  roadmap (blocked)
```

### Relationship Arrows in Diagrams

| Tag | Arrow Style | Meaning |
|---|---|---|
| `uses` / `used-by` | `-->` solid | Direct dependency |
| `depends-on` / `enables` | `-.->` dashed | Roadmap sequencing |
| `implements` | `..->` dotted | Spec realizes code |

### All Tag Groups

- **Identity & Status:** `pattern`, `status`, `core`/`api`/`infra`
- **Architecture:** `arch-role`, `arch-context`, `arch-layer`
- **Enrichment:** `brief`, `usecase`, `quarter`, `phase`, `release`
- **Shapes:** `extract-shapes`, `shape`
- **Relationships:** `uses`, `used-by`, `depends-on`, `enables`, `see-also`, `implements`
- **Stubs:** `target`, `since`
- **Decisions:** `adr`, `adr-status`, `adr-category`
- **Sequence:** `sequence-orchestrator`, `sequence-step`, `sequence-module`, `sequence-error`
