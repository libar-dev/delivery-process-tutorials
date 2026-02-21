---
cwd: .
runme:
  id: 01KHZNPKYJVQ5V3CZD17MBHP9N
  version: v3
shell: bash
---

# Context Engineering for AI-Assisted Codebases: Interactive Tutorial

> A hands-on Runme notebook for `@libar-dev/delivery-process` -- annotate your TypeScript, generate living docs, and give AI agents structured context instead of stale Markdown.

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
rm -rf src/ docs-generated/ tsconfig.json delivery-process.config.ts

# Restore minimal package.json (deps only, no scripts)
cat > package.json << 'JSON'
{
  "name": "dp-mini-demo",
  "version": "1.0.0",
  "type": "module",
  "private": true,
  "dependencies": {
    "@libar-dev/delivery-process": "1.0.0-pre.0"
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
npm ls @libar-dev/delivery-process --depth=0 2>/dev/null || echo "Not installed yet"
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
  "include": ["src/**/*.ts", "delivery-process.config.ts"]
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
  console.log('delivery-process?', p.dependencies?.['@libar-dev/delivery-process'] ? 'PASS' : 'FAIL'); \
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

### 2.1 Create `delivery-process.config.ts`

This tells the system where to find your sources and where to write generated docs:

```bash {"name":"create-config"}
cat > delivery-process.config.ts << 'TYPESCRIPT'
import { defineConfig } from "@libar-dev/delivery-process/config";

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
echo "Created delivery-process.config.ts"
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
| `libar-generic` | `@libar-docs-` | `@libar-docs` | 3: core, api, infra |
| `ddd-es-cqrs` | `@libar-docs-` | `@libar-docs` | 21: full DDD taxonomy |

This tutorial uses `libar-generic` throughout.

### 2.3 Add npm scripts

Add the Process Data API, doc generator, and linting scripts to `package.json`:

```bash {"name":"add-npm-scripts"}
node -e "
const pkg = JSON.parse(require('fs').readFileSync('package.json', 'utf8'));
pkg.scripts = {
  'process:query':    'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/process-api.js',
  'process:overview': 'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/process-api.js overview',
  'process:status':   'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/process-api.js status',
  'process:list':     'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/process-api.js list',
  'process:tags':     'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/process-api.js tags',
  'process:sources':  'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/process-api.js sources',
  'process:rules':    'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/process-api.js rules',
  'process:stubs':    'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/process-api.js stubs',

  'docs:patterns':       'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js -g patterns -f',
  'docs:roadmap':        'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js -g roadmap -f',
  'docs:reference':      'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js -g reference-docs -f',
  'docs:overview':       'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js -g overview-rdm -f',
  'docs:architecture':   'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js -g architecture -f',
  'docs:business-rules': 'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js -g business-rules -f',
  'docs:taxonomy':       'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js -g taxonomy -f',
  'docs:all':            'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js -g patterns,roadmap,reference-docs,overview-rdm,architecture,business-rules,taxonomy -f',
  'docs:list':           'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js --list-generators',

  'lint:patterns': 'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/lint-patterns.js -i \"src/sample-sources/**/*.ts\"',
  'lint:validate': 'tsx ./node_modules/@libar-dev/delivery-process/dist/cli/validate-patterns.js -i \"src/sample-sources/**/*.ts\" --features \"src/specs/**/*.feature\"'
};
require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
console.log('Added ' + Object.keys(pkg.scripts).length + ' npm scripts to package.json');
"
```

There are two categories of scripts:

- **`process:*`** -- Query the Process Data API. These scan your sources and return structured data (JSON or formatted text). They never write files.
- **`docs:*`** -- Run doc generators. These scan your sources and write markdown files to `docs-generated/`.

### 2.4 Your first Process Data API call

Even with no source files yet, you can query the system:

```bash {"closeTerminalOnSuccess":"false","name":"first-overview"}
npm run process:overview 2>&1
```

The Process Data API is your window into the delivery process state. We will use it after every change.

### Checkpoint: Part 2

```bash {"closeTerminalOnSuccess":"false","name":"checkpoint-2"}
echo "=== Part 2 Checkpoint ==="
[ -f "delivery-process.config.ts" ] && echo "delivery-process.config.ts: PASS" || echo "delivery-process.config.ts: FAIL"
node -e "const p=JSON.parse(require('fs').readFileSync('package.json','utf8')); console.log('npm scripts?', Object.keys(p.scripts || {}).length > 0 ? 'PASS (' + Object.keys(p.scripts).length + ' scripts)' : 'FAIL')"
npm run process:overview 2>&1 | head -3
```

---

## Part 3: Your First Annotation

> **What you learn:** Annotate one TypeScript file and see it detected.

### 3.1 File opt-in

Every file that the scanner should process needs a **file opt-in marker**. For the `libar-generic` preset, this is `/** @libar-docs */` as a standalone JSDoc comment at the top. Without it, the file is invisible to the scanner.

### 3.2 Create your first annotated source

This creates `src/sample-sources/user-service.ts` with the essential tags:

```bash {"name":"create-user-service-v1"}
cat > src/sample-sources/user-service.ts << 'TYPESCRIPT'
/** @libar-docs */

/**
 * @libar-docs-pattern UserService
 * @libar-docs-status active
 * @libar-docs-core
 * @libar-docs-brief Core user lifecycle management service
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

- `@libar-docs-pattern UserService` -- names this pattern (required)
- `@libar-docs-status active` -- FSM status: `roadmap` -> `active` -> `completed`, or `deferred`
- `@libar-docs-core` -- category assignment (flag tag -- no value needed)
- `@libar-docs-brief` -- short description for summary tables

### 3.3 See it detected

```bash {"closeTerminalOnSuccess":"false","name":"overview-after-first"}
npm run process:overview 2>&1
```

> **Expected:** `1 patterns (0 completed, 1 active, 0 planned) = 0%`

Verify which files the scanner found:

```bash {"closeTerminalOnSuccess":"false","name":"sources-after-first"}
npm run process:sources 2>&1
```

### Recap: Part 3

You created one annotated file and proved the scanner detects it. The minimum viable annotation is:

1. `@libar-docs` -- file opt-in marker
2. `@libar-docs-pattern Name` -- names the pattern
3. `@libar-docs-status` -- FSM status
4. A category flag (`@libar-docs-core`, `-api`, or `-infra`)

---

## Part 4: Adding Richness Layer by Layer

> **What you learn:** Layer in architecture, enrichment, and shape extraction tags.

### 4.1-4.3 Add all richness tags

Now we replace `user-service.ts` with the full version including architecture tags, enrichment tags, and shape extraction:

```bash {"name":"create-user-service-v2"}
cat > src/sample-sources/user-service.ts << 'TYPESCRIPT'
/** @libar-docs */

/**
 * @libar-docs-pattern UserService
 * @libar-docs-status active
 * @libar-docs-core
 * @libar-docs-arch-role service
 * @libar-docs-arch-context identity
 * @libar-docs-arch-layer application
 * @libar-docs-extract-shapes UserRecord
 * @libar-docs-phase 1
 * @libar-docs-release v0.1.0
 * @libar-docs-brief Core user lifecycle management service
 * @libar-docs-usecase "Register a new user account via the signup form"
 * @libar-docs-usecase "Look up a user by ID for profile display"
 * @libar-docs-usecase "Deactivate a compromised user account"
 * @libar-docs-quarter Q1-2026
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
TYPESCRIPT
echo "Updated src/sample-sources/user-service.ts with richness tags"
```

### Tag groups added

**Architecture tags** -- place your pattern in a structured topology:

| Tag | Example | Purpose |
|---|---|---|
| `@libar-docs-arch-role` | `service` | Component type |
| `@libar-docs-arch-context` | `identity` | Bounded context (creates diagram subgraphs) |
| `@libar-docs-arch-layer` | `application` | Architecture layer |

**Enrichment tags** -- drive roadmaps and detail pages:

| Tag | Example | Purpose |
|---|---|---|
| `@libar-docs-usecase` | `"Register a new user..."` | Use cases (quoted, repeatable) |
| `@libar-docs-quarter` | `Q1-2026` | Timeline tracking |
| `@libar-docs-phase` | `1` | Roadmap phase number |
| `@libar-docs-release` | `v0.1.0` | Target release version |

**Shape extraction** -- pulls TypeScript interfaces into docs:

| Tag | Example | Purpose |
|---|---|---|
| `@libar-docs-extract-shapes` | `UserRecord` | Extract named types into docs |
| `@libar-docs-shape` | `reference-sample` | Mark an interface for shape discovery |

### Verify the enriched tags

```bash {"closeTerminalOnSuccess":"false","name":"tags-after-richness"}
npm run process:tags 2>&1
```

### Check overview with phases

```bash {"closeTerminalOnSuccess":"false","name":"overview-after-richness"}
npm run process:overview 2>&1
```

> **Expected:** 2 patterns (UserService + UserRecord shape), Phase 1: Inception visible.

---

## Part 5: Relationships & Multiple Sources

> **What you learn:** Connect multiple files into a dependency graph.

### 5.1 Add relationships to user-service.ts

Update `user-service.ts` with relationship tags (`used-by`, `uses`, `depends-on`, `see-also`):

```bash {"name":"create-user-service-final"}
cat > src/sample-sources/user-service.ts << 'TYPESCRIPT'
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
TYPESCRIPT
echo "Updated src/sample-sources/user-service.ts with relationship tags"
```

**Relationship tags:**

| Tag | Example | Purpose |
|---|---|---|
| `@libar-docs-uses` | `EventStore` | Direct dependency (solid arrow in diagrams) |
| `@libar-docs-used-by` | `AuthHandler` | Reverse dependency |
| `@libar-docs-depends-on` | `EventStore` | Roadmap sequencing (dashed arrow) |
| `@libar-docs-enables` | `UserService` | Reverse sequencing |
| `@libar-docs-see-also` | `AuthHandler, EventStore` | Cross-reference |

### 5.2 Create AuthHandler

```bash {"name":"create-auth-handler"}
cat > src/sample-sources/auth-handler.ts << 'TYPESCRIPT'
/** @libar-docs */

/**
 * @libar-docs-pattern AuthHandler
 * @libar-docs-status roadmap
 * @libar-docs-api
 * @libar-docs-arch-role service
 * @libar-docs-arch-context identity
 * @libar-docs-arch-layer application
 * @libar-docs-uses UserService
 * @libar-docs-extract-shapes AuthResult
 * @libar-docs-phase 2
 * @libar-docs-release vNEXT
 * @libar-docs-brief Authentication and session management handler
 * @libar-docs-usecase "Authenticate a user with email and password"
 * @libar-docs-usecase "Validate an active session token"
 * @libar-docs-depends-on UserService
 * @libar-docs-quarter Q1-2026
 * @libar-docs-see-also UserService
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

/** @libar-docs-shape reference-sample */
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
TYPESCRIPT
echo "Created src/sample-sources/event-store.ts"
```

### 5.4 See the dependency graph

```bash {"closeTerminalOnSuccess":"false","name":"overview-with-deps"}
npm run process:overview 2>&1
```

> **Expected:** 6 patterns, blocking chain: AuthHandler -> UserService -> EventStore.

### 5.5 Explore the dependency tree

```bash {"closeTerminalOnSuccess":"false","name":"dep-tree-auth"}
npm run process:query -- dep-tree AuthHandler 2>&1
```

### 5.6 Bounded contexts

```bash {"closeTerminalOnSuccess":"false","name":"arch-contexts"}
npm run process:query -- arch context 2>&1
```

### 5.7 Filter by status

```bash {"closeTerminalOnSuccess":"false","name":"list-roadmap"}
npm run process:query -- list --status roadmap 2>&1
```

### Checkpoint: Part 5

```bash {"closeTerminalOnSuccess":"false","name":"checkpoint-5"}
echo "=== Part 5 Checkpoint ==="
echo ""
echo "--- Sources (expect 3 TypeScript files) ---"
npm run process:sources 2>&1 | grep -E '"count"|"file"'
echo ""
echo "--- Overview (expect 6 patterns) ---"
npm run process:overview 2>&1 | head -8
echo ""
echo "--- Contexts (expect identity + persistence) ---"
npm run process:query -- arch context 2>&1 | grep '"context"'
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

In Gherkin files: tags before `Feature:` are metadata (like JSDoc tags). `Background:` sets up shared context. `Rule:` blocks define business constraints. `Scenario:` blocks are test cases with Given/When/Then.

**Important:** Gherkin features must include the `@libar-docs` opt-in tag. Tags use **colon syntax** (not spaces like TypeScript).

| Syntax | Context | Example |
|---|---|---|
| Space-separated | TypeScript JSDoc | `@libar-docs-pattern UserService` |
| Colon-separated | Gherkin tags | `@libar-docs-pattern:UserRegistration` |

### 7.2 Create user-registration.feature

```bash {"name":"create-user-reg-feature"}
cat > src/specs/user-registration.feature << 'GHERKIN'
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
GHERKIN
echo "Created src/specs/user-registration.feature"
```

### 7.3 Create authentication.feature

```bash {"name":"create-auth-feature"}
cat > src/specs/authentication.feature << 'GHERKIN'
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
GHERKIN
echo "Created src/specs/authentication.feature"
```

### 7.4 Query business rules

```bash {"closeTerminalOnSuccess":"false","name":"query-rules"}
npm run process:rules 2>&1
```

> **Expected:** 5 business rules from 2 Gherkin features.

### 7.5 Generate business rules docs

```bash {"closeTerminalOnSuccess":"false","name":"gen-business-rules"}
npm run docs:business-rules 2>&1
```

### 7.6 Check enriched overview

```bash {"closeTerminalOnSuccess":"false","name":"overview-after-gherkin"}
npm run process:overview 2>&1
```

> **Expected:** 8 patterns (3 TS + 3 shapes + 2 Gherkin), blocking includes Authentication -> UserRegistration.

### 7.7 Verify all sources

```bash {"closeTerminalOnSuccess":"false","name":"sources-after-gherkin"}
npm run process:sources 2>&1
```

### Checkpoint: Part 7

```bash {"closeTerminalOnSuccess":"false","name":"checkpoint-7"}
echo "=== Part 7 Checkpoint ==="
echo ""
echo "--- Sources ---"
npm run process:sources 2>&1 | grep -E '"type"|"count"'
echo ""
echo "--- Rules ---"
npm run process:rules 2>&1 | grep '"totalRules"'
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
/** @libar-docs */

/**
 * @libar-docs-pattern NotificationService
 * @libar-docs-status roadmap
 * @libar-docs-infra
 * @libar-docs-arch-role service
 * @libar-docs-arch-context identity
 * @libar-docs-arch-layer infrastructure
 * @libar-docs-target src/sample-sources/notification-service.ts
 * @libar-docs-since design-session-1
 * @libar-docs-uses AuthHandler
 * @libar-docs-phase 2
 * @libar-docs-release vNEXT
 * @libar-docs-brief Notification service for auth lifecycle events
 * @libar-docs-usecase "Send welcome email after user registration"
 * @libar-docs-usecase "Send login alert for new device"
 * @libar-docs-quarter Q2-2026
 * @libar-docs-extract-shapes NotificationConfig, NotificationResult
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

/** @libar-docs-shape reference-sample */
export interface NotificationConfig {
  channel: "email" | "sms";
  template: string;
  recipientId: string;
}

/** @libar-docs-shape reference-sample */
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
| `@libar-docs-target` | `src/sample-sources/notification-service.ts` | Path where the real implementation will live |
| `@libar-docs-since` | `design-session-1` | Which design session created the stub |

### 8.2 Query stubs

```bash {"closeTerminalOnSuccess":"false","name":"query-stubs"}
npm run process:stubs 2>&1
```

> **Expected:** 3 stub entries (NotificationService + 2 shapes), all with `targetExists: false`.

### Checkpoint: Part 8

```bash {"closeTerminalOnSuccess":"false","name":"checkpoint-8"}
echo "=== Part 8 Checkpoint ==="
[ -f "src/stubs/notification-service.stub.ts" ] && echo "stub file: PASS" || echo "stub file: FAIL"
npm run process:stubs 2>&1 | grep '"unresolvedCount"'
npm run process:sources 2>&1 | grep -A2 '"Stub'
```

---

## Part 9: Full Generation & Linting

> **What you learn:** Generate all 26 docs, reference docs, and lint your annotations.

### 9.1 Generate everything

```bash {"closeTerminalOnSuccess":"false","name":"gen-all"}
npm run docs:all 2>&1
```

> **Expected:** 7 generators, 26 files written.

### 9.2 List all generated files

```bash {"closeTerminalOnSuccess":"false","name":"list-all-generated"}
echo "=== All Generated Files ==="
find docs-generated -name "*.md" -type f | sort
echo ""
echo "Total: $(find docs-generated -name "*.md" -type f | wc -l | tr -d ' ') files"
```

### 9.3 Add referenceDocConfigs to configuration

Before generating reference docs, add a `referenceDocConfigs` entry to `delivery-process.config.ts`. This defines a custom composite document scoped to specific bounded contexts:

```bash {"name":"add-reference-config"}
cat > delivery-process.config.ts << 'TYPESCRIPT'
import { defineConfig } from "@libar-dev/delivery-process/config";

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
  referenceDocConfigs: [
    {
      title: "Identity & Persistence Reference",
      conventionTags: [],
      shapeSources: ["src/sample-sources/**/*.ts"],
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
echo "Updated delivery-process.config.ts with referenceDocConfigs"
```

### 9.4 Generate the reference doc

```bash {"closeTerminalOnSuccess":"false","name":"gen-reference"}
npm run docs:reference 2>&1
```

### 9.5 List available generators

```bash {"closeTerminalOnSuccess":"false","name":"list-generators"}
npm run docs:list 2>&1
```

### 9.6 Lint patterns

```bash {"closeTerminalOnSuccess":"false","name":"lint-patterns"}
npm run lint:patterns 2>&1 || true
```

> **Note:** 3 errors are expected -- from `@libar-docs-shape` annotations on interfaces that lack their own `@libar-docs-pattern` names. This is normal.

### Checkpoint: Part 9

```bash {"closeTerminalOnSuccess":"false","name":"checkpoint-9"}
echo "=== Part 9 Checkpoint ==="
echo ""
total=$(find docs-generated -name "*.md" -type f | wc -l | tr -d ' ')
echo "Generated files: $total (expected: 26+)"
echo ""
for f in docs-generated/PATTERNS.md docs-generated/ROADMAP.md docs-generated/ARCHITECTURE.md docs-generated/OVERVIEW.md docs-generated/BUSINESS-RULES.md docs-generated/TAXONOMY.md; do
  basename="$(basename $f)"
  [ -f "$f" ] && echo "$basename: PASS" || echo "$basename: FAIL"
done
```

---

## Part 10: Advanced Process Data API

> **What you learn:** Query project state with advanced CLI commands.

### 10.1 Architecture neighborhood

See everything UserService touches -- uses, used-by, same-context peers:

```bash {"closeTerminalOnSuccess":"false","name":"arch-neighborhood"}
npm run process:query -- arch neighborhood UserService 2>&1
```

### 10.2 Blocking analysis

Find patterns stuck on incomplete dependencies:

```bash {"closeTerminalOnSuccess":"false","name":"arch-blocking"}
npm run process:query -- arch blocking 2>&1
```

### 10.3 Dangling references

Find broken references to nonexistent pattern names:

```bash {"closeTerminalOnSuccess":"false","name":"arch-dangling"}
npm run process:query -- arch dangling 2>&1
```

> **Expected:** Empty array -- all references resolve correctly.

### 10.4 Full pattern detail

Get complete metadata for a single pattern:

```bash {"closeTerminalOnSuccess":"false","name":"pattern-detail"}
npm run process:query -- pattern UserService 2>&1
```

### 10.5 Output modifiers

```bash {"closeTerminalOnSuccess":"false","name":"count-roadmap"}
echo "--- How many roadmap patterns? ---"
npm run process:query -- list --status roadmap --count 2>&1
echo ""
echo "--- All pattern names ---"
npm run process:query -- list --names-only 2>&1
```

### 10.6 Final overview

```bash {"closeTerminalOnSuccess":"false","name":"final-overview"}
npm run process:overview 2>&1
```

> **Expected:** 11 patterns, 3 blocking chains, 0% complete (no patterns have status `completed`).

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
npm run process:query -- list --count 2>&1 | grep '"data"'
echo ""

echo "--- Business Rules ---"
npm run process:rules 2>&1 | grep '"totalRules"'
echo ""

echo "--- Blocking Chains ---"
npm run process:query -- arch blocking 2>&1 | grep '"pattern"'
echo ""

echo "--- Bounded Contexts ---"
npm run process:query -- arch context 2>&1 | grep '"context"'
echo ""

echo "========================================"
echo "  All 10 parts complete!"
echo "========================================"
```

---

## Appendix: Tag Quick Reference

### Required Tags

| Tag | Format | Example |
|---|---|---|
| `@libar-docs` | file opt-in | `/** @libar-docs */` |
| `@libar-docs-pattern` | `Name` | `@libar-docs-pattern UserService` |

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
