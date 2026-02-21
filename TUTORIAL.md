# Delivery Process: Getting Started Tutorial

## Why Context Engineering?

You have 50 TypeScript files. An AI coding agent asks: "What depends on UserService?" Today, you'd point it at a stale README or a Confluence page from last quarter. The agent parses free-form text, guesses at imports, and hallucinates relationships that don't exist.

**Context engineering** makes code the single source of truth for delivery state — not separate documents that drift.

| Aspect | Traditional Docs | Context Engineering |
|---|---|---|
| **Source** | Separate Markdown/Confluence | Annotations in code + Gherkin specs |
| **Freshness** | Manual updates — drifts within days | Generated from source — always current |
| **AI Integration** | Parse stale Markdown | CLI queries with typed JSON output |
| **Enforcement** | Guidelines (ignored) | FSM-validated state transitions |

In this tutorial, you'll annotate a small project and watch the system:

- **Extract** patterns, relationships, and business rules from your code
- **Generate** 26 living documentation files (architecture diagrams, roadmaps, business rules)
- **Answer** structured queries about your project state via CLI

The annotations live in your code. The docs regenerate in seconds. Nothing drifts.

---

## What You'll Build

```
your-project/
├── delivery-process.config.ts           # Process configuration
├── src/
│   ├── sample-sources/                  # Implementation code (annotated)
│   │   ├── user-service.ts
│   │   ├── auth-handler.ts
│   │   └── event-store.ts
│   ├── specs/                           # Plan-level specs (Gherkin features)
│   │   ├── user-registration.feature
│   │   └── authentication.feature
│   └── stubs/                           # Design-level specs (stubs)
│       └── notification-service.stub.ts
├── docs-generated/                      # 26 generated doc files
│   ├── PATTERNS.md
│   ├── ROADMAP.md
│   ├── ARCHITECTURE.md
│   ├── BUSINESS-RULES.md
│   ├── OVERVIEW.md
│   ├── TAXONOMY.md
│   └── ...
├── package.json
└── tsconfig.json
```

## What You'll Learn

| Part | Topic | What You'll Do | Time |
|------|-------|----------------|------|
| 1 | Project Setup | Initialize a project with all dependencies | 3 min |
| 2 | Configuration | Configure sources, output, and presets | 3 min |
| 3 | First Annotation | Annotate one file and see it detected | 5 min |
| 4 | Adding Richness | Layer in architecture, enrichment, and shape tags | 7 min |
| 5 | Relationships | Connect multiple files into a dependency graph | 7 min |
| 6 | Doc Generation | Generate pattern registry and roadmap | 5 min |
| 7 | Gherkin Specs | Write plan-level specs with business rules | 8 min |
| 8 | Design Stubs | Describe future implementations | 4 min |
| 9 | Full Generation | Generate all 26 docs + reference docs + linting | 7 min |
| 10 | Advanced Queries | Query project state with advanced CLI commands | 5 min |

**Total: ~55 minutes** | **Prerequisites:** Node.js >= 18, npm

---

## Part 1: Project Setup

### 1.1 Initialize the project

```bash
mkdir dp-mini-demo && cd dp-mini-demo
npm init -y
```

Edit `package.json` to set `"type": "module"` and `"private": true`:

```json
{
  "name": "dp-mini-demo",
  "version": "1.0.0",
  "type": "module",
  "private": true
}
```

### 1.2 Install dependencies

```bash
npm install @libar-dev/delivery-process@pre
npm install -D typescript tsx
```

> **Pre-release note:** The `@pre` dist-tag installs the latest pre-release version (currently v1.0.0-pre.0). Once 1.0.0 stable ships, this becomes `npm install @libar-dev/delivery-process`.

- `@libar-dev/delivery-process` — the documentation generation engine
- `typescript` — for type checking
- `tsx` — for running TypeScript CLI tools directly

### 1.3 Create tsconfig.json

```json
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
```

### 1.4 Create folder structure

```bash
mkdir -p src/sample-sources src/specs src/stubs
```

### Checkpoint: Part 1

- [ ] `package.json` has `"type": "module"`
- [ ] `@libar-dev/delivery-process` appears in dependencies
- [ ] `typescript` and `tsx` appear in devDependencies
- [ ] `tsconfig.json` exists
- [ ] Empty folders: `src/sample-sources/`, `src/specs/`, `src/stubs/`

---

## Part 2: Configuration

_With the project scaffolded, you'll now tell the delivery process where to find your sources and where to write generated docs._

### 2.1 Create `delivery-process.config.ts`

```typescript
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
```

### 2.2 Configuration fields explained

| Field | Purpose |
|---|---|
| `preset` | Tag taxonomy preset — determines the tag prefix and available categories |
| `sources.typescript` | Glob patterns for your implementation TypeScript files |
| `sources.features` | Glob patterns for Gherkin `.feature` files (plan-level specs) |
| `sources.stubs` | Glob patterns for design-level stub TypeScript files |
| `output.directory` | Where generated docs are written. Default: `docs/architecture` |
| `output.overwrite` | Whether to overwrite existing files. Default: `false` |

### 2.3 Available presets

| Preset | Tag Prefix | File Opt-In | Categories |
|---|---|---|---|
| `generic` | `@docs-` | `@docs` | 3: core, api, infra |
| `libar-generic` | `@libar-docs-` | `@libar-docs` | 3: core, api, infra |
| `ddd-es-cqrs` | `@libar-docs-` | `@libar-docs` | 21: full DDD taxonomy |

We use `libar-generic` throughout this tutorial. It provides three categories (`core`, `api`, `infra`) with the `@libar-docs-` tag prefix.

### 2.4 Add npm scripts

Add the following to your `package.json` scripts:

```json
{
  "scripts": {
    "process:query":    "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/process-api.js",
    "process:overview": "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/process-api.js overview",
    "process:status":   "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/process-api.js status",
    "process:list":     "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/process-api.js list",
    "process:tags":     "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/process-api.js tags",
    "process:sources":  "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/process-api.js sources",
    "process:rules":    "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/process-api.js rules",
    "process:stubs":    "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/process-api.js stubs",

    "docs:patterns":       "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js -g patterns -f",
    "docs:roadmap":        "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js -g roadmap -f",
    "docs:reference":      "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js -g reference-docs -f",
    "docs:overview":       "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js -g overview-rdm -f",
    "docs:architecture":   "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js -g architecture -f",
    "docs:business-rules": "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js -g business-rules -f",
    "docs:taxonomy":       "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js -g taxonomy -f",
    "docs:all":            "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js -g patterns,roadmap,reference-docs,overview-rdm,architecture,business-rules,taxonomy -f",
    "docs:list":           "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js --list-generators",

    "lint:patterns": "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/lint-patterns.js -i \"src/sample-sources/**/*.ts\"",
    "lint:validate": "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/validate-patterns.js -i \"src/sample-sources/**/*.ts\" --features \"src/specs/**/*.feature\""
  }
}
```

There are two categories of scripts:

**`process:*`** — Query the Process Data API. These scan your sources and return structured data (JSON or formatted text) about your patterns, status, relationships, and business rules. They never write files.

**`docs:*`** — Run doc generators. These scan your sources and write markdown files to `docs-generated/`.

### 2.5 Your first Process Data API call

Even with no source files yet, you can run:

```bash
npm run process:overview
```

```
=== PROGRESS ===
0 patterns (0 completed, 0 active, 0 planned) = 0%
```

The Process Data API is your window into the delivery process state. We'll use it after every change to see what the system detects.

### Checkpoint: Part 2

- [ ] `delivery-process.config.ts` exists with `defineConfig()`
- [ ] `package.json` has all `process:*` and `docs:*` scripts
- [ ] `npm run process:overview` runs without errors

---

## Part 3: Your First Annotation

_With configuration in place, you'll now annotate one TypeScript file and see the system detect it._

### 3.1 File opt-in

Every file that the scanner should process needs a **file opt-in marker**. For the `libar-generic` preset, this is:

```typescript
/** @libar-docs */
```

This must be a standalone JSDoc comment at the top of the file. Without it, the file is invisible to the scanner.

### 3.2 Create your first annotated source

Create `src/sample-sources/user-service.ts` with just the essential tags:

```typescript
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
```

Four tags is all you need to get started:
- `@libar-docs-pattern UserService` — names this pattern (required)
- `@libar-docs-status active` — FSM status: `roadmap` → `active` → `completed`, or `deferred`
- `@libar-docs-core` — category assignment (flag tag — no value needed)
- `@libar-docs-brief` — short description for summary tables

### 3.3 See it detected

```bash
npm run process:overview
```

```
=== PROGRESS ===
1 patterns (0 completed, 1 active, 0 planned) = 0%

=== ACTIVE PHASES ===
(none yet — we haven't added a phase tag)
```

> **What just happened:** The scanner found `user-service.ts`, detected the `@libar-docs` opt-in marker, and extracted the `UserService` pattern with status `active` in the `core` category. One file, one pattern — and it's already queryable.

Verify which files the scanner found:

```bash
npm run process:sources
```

```json
{
  "success": true,
  "data": {
    "types": [
      {
        "type": "TypeScript (annotated)",
        "count": 1,
        "files": ["src/sample-sources/user-service.ts"]
      }
    ],
    "totalFiles": 1
  }
}
```

### Recap: Part 3

You created one annotated file and proved the scanner detects it. The minimum viable annotation is:

1. `@libar-docs` — file opt-in marker
2. `@libar-docs-pattern Name` — names the pattern
3. `@libar-docs-status` — FSM status
4. A category flag (`@libar-docs-core`, `-api`, or `-infra`)

Next, you'll add tags that make the documentation richer.

---

## Part 4: Adding Richness Layer by Layer

_In Part 3 you created a working annotation with 4 tags. Now you'll layer in architecture, enrichment, and shape extraction tags — each group unlocks new documentation capabilities._

### 4.1 Add architecture tags

Add these three tags to the JSDoc block in `user-service.ts`, after `@libar-docs-brief`:

```typescript
 * @libar-docs-arch-role service
 * @libar-docs-arch-context identity
 * @libar-docs-arch-layer application
```

Architecture tags place your pattern in a structured topology:

| Tag | Example | Purpose |
|---|---|---|
| `@libar-docs-arch-role` | `service` | Component type: `service`, `infrastructure`, etc. |
| `@libar-docs-arch-context` | `identity` | Bounded context (creates diagram subgraphs) |
| `@libar-docs-arch-layer` | `application` | Architecture layer: `domain`, `application`, `infrastructure` |

Run `npm run process:tags` and you'll see architecture metadata now appears in the tag usage report — `arch-role: service`, `arch-context: identity`, `arch-layer: application`.

> **What just happened:** Architecture tags tell the system where this component lives in your system topology. These drive the Mermaid diagrams generated later — bounded contexts become subgraphs, roles become node labels.

### 4.2 Add enrichment tags

Add these tags to `user-service.ts`:

```typescript
 * @libar-docs-usecase "Register a new user account via the signup form"
 * @libar-docs-usecase "Look up a user by ID for profile display"
 * @libar-docs-usecase "Deactivate a compromised user account"
 * @libar-docs-quarter Q1-2026
 * @libar-docs-phase 1
 * @libar-docs-release v0.1.0
```

| Tag | Example | Purpose |
|---|---|---|
| `@libar-docs-usecase` | `"Register a new user..."` | Use cases (quoted, repeatable) |
| `@libar-docs-quarter` | `Q1-2026` | Timeline tracking |
| `@libar-docs-phase` | `1` | Roadmap phase number |
| `@libar-docs-release` | `v0.1.0` | Target release version |

```bash
npm run process:overview
```

```
=== PROGRESS ===
1 patterns (0 completed, 1 active, 0 planned) = 0%

=== ACTIVE PHASES ===
Phase 1: Inception (1 active)
```

> **What just happened:** The `@libar-docs-phase 1` tag assigns UserService to Phase 1. Phase names like "Inception" come from the **6-phase-standard** workflow built into the preset. The six phases are: Inception, Elaboration, Session, Construction, Validation, Retrospective.

### 4.3 Add shape extraction

Shape extraction pulls TypeScript interfaces into your generated docs. Add this tag to the pattern's JSDoc block:

```typescript
 * @libar-docs-extract-shapes UserRecord
```

Then add the interface above the class, with its own shape tag:

```typescript
/** @libar-docs-shape reference-sample */
export interface UserRecord {
  id: string;
  email: string;
  active: boolean;
}
```

| Tag | Example | Purpose |
|---|---|---|
| `@libar-docs-extract-shapes` | `UserRecord` | Extract named TypeScript types into docs |
| `@libar-docs-shape` | `reference-sample` | Mark an interface for shape discovery (optional group name) |

```bash
npm run process:overview
```

The pattern count increases — `UserRecord` now appears as a separate shape pattern in the registry.

> **Note:** `@libar-docs-shape` on an interface creates a lightweight "Shape" entry. The linter will flag these for missing `@libar-docs-pattern` names, which is expected and harmless.

### 4.4 Full tag reference

Here's the complete tag reference for TypeScript annotations. You've now used every group:

**Identity & Status:**

| Tag | Example | Purpose |
|---|---|---|
| `@libar-docs-pattern` | `UserService` | Names this pattern (required) |
| `@libar-docs-status` | `active` | FSM status: `roadmap` → `active` → `completed`, or `deferred` |
| `@libar-docs-core` | _(flag)_ | Category assignment. Also: `@libar-docs-api`, `@libar-docs-infra` |

**Architecture:**

| Tag | Example | Purpose |
|---|---|---|
| `@libar-docs-arch-role` | `service` | Component type |
| `@libar-docs-arch-context` | `identity` | Bounded context |
| `@libar-docs-arch-layer` | `application` | Architecture layer |

**Enrichment:**

| Tag | Example | Purpose |
|---|---|---|
| `@libar-docs-brief` | `Core user lifecycle...` | Short description for summary tables |
| `@libar-docs-usecase` | `"Register a new user..."` | Use cases (quoted, repeatable) |
| `@libar-docs-quarter` | `Q1-2026` | Timeline tracking |
| `@libar-docs-phase` | `1` | Roadmap phase number |
| `@libar-docs-release` | `v0.1.0` | Target release version |

**Shapes:**

| Tag | Example | Purpose |
|---|---|---|
| `@libar-docs-extract-shapes` | `UserRecord` | Extract named types into docs |
| `@libar-docs-shape` | `reference-sample` | Mark an interface for shape discovery |

### Checkpoint: Part 4

- [ ] `user-service.ts` has architecture tags (`arch-role`, `arch-context`, `arch-layer`)
- [ ] `user-service.ts` has enrichment tags (`usecase`, `quarter`, `phase`, `release`)
- [ ] `user-service.ts` has shape extraction (`extract-shapes` + `@libar-docs-shape` on interface)
- [ ] `npm run process:overview` shows "Phase 1: Inception"

### Recap: Part 4

Starting from 4 tags, you added three groups:

- **Architecture tags** — role, context, layer → drive Mermaid diagrams
- **Enrichment tags** — use cases, timeline, release → drive roadmaps and detail pages
- **Shape extraction** — TypeScript interfaces become API type documentation

Your single file now carries enough metadata to generate rich, multi-format documentation.

---

## Part 5: Relationships & Multiple Sources

_In Part 4, you enriched a single file with architecture and enrichment tags. Now you'll connect multiple files into a live dependency graph._

### 5.1 Add relationship tags to user-service.ts

Add these tags to `user-service.ts`:

```typescript
 * @libar-docs-used-by AuthHandler
 * @libar-docs-uses EventStore
 * @libar-docs-depends-on EventStore
 * @libar-docs-see-also AuthHandler, EventStore
```

These reference patterns that don't exist yet — that's intentional. The system will track these as pending references until you create the matching files.

**Relationship tags:**

| Tag | Example | Purpose |
|---|---|---|
| `@libar-docs-uses` | `EventStore` | Direct dependency (solid arrow `-->` in diagrams) |
| `@libar-docs-used-by` | `AuthHandler` | Reverse dependency |
| `@libar-docs-depends-on` | `EventStore` | Roadmap sequencing (dashed arrow `-.->`) |
| `@libar-docs-enables` | `UserService` | Reverse sequencing |
| `@libar-docs-see-also` | `AuthHandler, EventStore` | Cross-reference without dependency |

### 5.2 The full user-service.ts

After all the additions from Parts 3–5, your file should look like this:

```typescript
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
```

### 5.3 Add two more patterns

Create `src/sample-sources/auth-handler.ts`:

```typescript
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
```

Create `src/sample-sources/event-store.ts`:

```typescript
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
```

Notice how these files use the same tag patterns you learned: identity + architecture + enrichment + shapes + relationships. `AuthHandler` uses `UserService`, while `EventStore` is used by `UserService` and has status `deferred`.

### 5.4 See the dependency graph

```bash
npm run process:overview
```

```
=== PROGRESS ===
6 patterns (0 completed, 1 active, 5 planned) = 0%

=== ACTIVE PHASES ===
Phase 1: Inception (1 active)

=== BLOCKING ===
UserService blocked by: EventStore
AuthHandler blocked by: UserService
```

> **What just happened:** The system automatically computed the dependency chain: AuthHandler depends on UserService, which depends on EventStore. The blocking report surfaces this — no manual tracking needed.

Explore the full dependency tree:

```bash
npm run process:query -- dep-tree AuthHandler
```

```
EventStore (3, deferred)
  -> UserService (1, active)
    -> AuthHandler (2, roadmap) <- YOU ARE HERE
```

This shows the chain from root dependency (EventStore) through UserService to AuthHandler, with phase numbers and statuses at each level.

List all bounded contexts:

```bash
npm run process:query -- arch context
```

```json
{
  "success": true,
  "data": [
    { "context": "identity", "count": 3, "patterns": ["UserService", "AuthHandler", "..."] },
    { "context": "persistence", "count": 1, "patterns": ["EventStore"] }
  ]
}
```

Filter patterns by status:

```bash
npm run process:query -- list --status roadmap
```

Shows your planned work backlog — all patterns with status `roadmap`.

### Checkpoint: Part 5

Before moving on, verify:
- [ ] `npm run process:sources` shows 3 TypeScript files
- [ ] `npm run process:overview` shows 6+ patterns (3 main + 3 shapes)
- [ ] `npm run process:query -- arch context` shows `identity` and `persistence`
- [ ] `npm run process:query -- dep-tree AuthHandler` shows a dependency chain

### Recap: Part 5

- Multiple sources with `@libar-docs-uses` and `@libar-docs-depends-on` create a live dependency graph
- The `process:overview` blocking report surfaces dependency chains automatically
- `dep-tree` shows recursive dependencies for any pattern
- Pattern names in relationship tags must match exactly (case-sensitive)

---

## Part 6: Generate Documentation

_You have 3 annotated TypeScript files with rich metadata and relationships. Now you'll generate living documentation from these annotations._

### 6.1 Generate the Pattern Registry

```bash
npm run docs:patterns
```

```
Running generator: patterns
  ✓ PATTERNS.md
  ✓ patterns/user-service.md
  ✓ patterns/user-record.md
  ✓ patterns/event-store.md
  ✓ patterns/domain-event.md
  ✓ patterns/auth-handler.md
  ✓ patterns/auth-result.md
```

**`PATTERNS.md`** is the pattern registry — an index of all patterns with:
- Progress bar and status counts (completed / active / planned)
- Categorized listing (API, Core, Infra, Shape)
- Brief descriptions from `@libar-docs-brief`
- A Mermaid dependency graph showing `uses` (solid), `depends-on` (dashed), and `implements` (dotted) relationships

**`patterns/*.md`** are per-pattern detail pages with:
- Status, category, phase, quarter metadata table
- Description from JSDoc markdown
- Use cases from `@libar-docs-usecase` tags
- Dependencies list

### 6.2 Generate the Roadmap

```bash
npm run docs:roadmap
```

```
Running generator: roadmap
  ✓ ROADMAP.md
  ✓ phases/phase-01-inception.md
  ✓ phases/phase-02-elaboration.md
  ✓ phases/phase-03-session.md
```

**`ROADMAP.md`** organizes patterns by phase with:
- Overall progress bar and metrics
- Phase navigation table with per-phase completion percentages
- Per-phase sections listing patterns with descriptions

Phase names come from the default **6-phase-standard** workflow: Inception, Elaboration, Session, Construction, Validation, Retrospective. Patterns are assigned to phases via `@libar-docs-phase N`.

### Checkpoint: Part 6

- [ ] `docs-generated/PATTERNS.md` exists with a Mermaid dependency graph
- [ ] `docs-generated/patterns/` has individual pattern detail pages
- [ ] `docs-generated/ROADMAP.md` exists with phase sections
- [ ] `docs-generated/phases/` has phase detail pages

### Recap: Part 6

- `patterns` generator → registry index + per-pattern detail pages
- `roadmap` generator → phase-based roadmap + per-phase detail pages
- All content is derived from your annotations — change the code, regenerate, docs update

---

## Part 7: Plan-Level Specs (Gherkin Features)

_TypeScript annotations describe what exists. Gherkin features describe what needs to be built — acceptance criteria, deliverables, and business rules that complement your code annotations._

### 7.1 Reading Gherkin

> **Quick primer:** In Gherkin files, tags before `Feature:` are metadata (like JSDoc tags). `Background:` sets up shared context. `Rule:` blocks define business constraints. `Scenario:` blocks are individual test cases with Given/When/Then steps.

### 7.2 Create `src/specs/user-registration.feature`

> **Important:** Gherkin features must include the `@libar-docs` opt-in tag. Without it, the scanner ignores the file entirely — just like TypeScript files.

```gherkin
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
```

### 7.3 Gherkin annotation anatomy

**Feature-level tags** (before `Feature:`) use colon syntax — not spaces like TypeScript:

| Syntax | Context | Example |
|---|---|---|
| Space-separated | TypeScript JSDoc | `@libar-docs-pattern UserService` |
| Colon-separated | Gherkin tags | `@libar-docs-pattern:UserRegistration` |

Key feature-level tags:

| Tag | Purpose |
|---|---|
| `@libar-docs` | **Required.** Opts the file into scanning. |
| `@libar-docs-pattern:UserRegistration` | Names this as a pattern. |
| `@libar-docs-implements:UserService` | Links this spec to the TypeScript pattern it specifies (dotted arrows in diagrams). |
| `@libar-docs-depends-on:UserRegistration` | Roadmap sequencing between specs. |

**Background: Deliverables** — A data table under `Background:` that tracks deliverables. Each row specifies a deliverable name, its status, and the source file where it will be implemented. These show up in roadmap tracking and pattern detail pages.

**Rule: blocks** — Gherkin `Rule:` blocks are extracted as business rules. Add structured annotations inside the rule description:

- `**Invariant:**` — The constraint that must hold (extracted verbatim)
- `**Rationale:**` — Why the invariant matters
- Scenarios under the rule are linked as `Verified by:` entries

**Semantic scenario tags** — Tags like `@happy-path`, `@validation`, `@business-rule` categorize scenarios for reporting.

### 7.4 Add a second feature spec

Create `src/specs/authentication.feature`:

```gherkin
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
```

This feature demonstrates cross-pattern traceability:
- `@libar-docs-implements:AuthHandler` — links this spec to the TypeScript implementation
- `@libar-docs-depends-on:UserRegistration` — sequencing between specs

### 7.5 Query business rules

```bash
npm run process:rules
```

```json
{
  "success": true,
  "data": {
    "productAreas": [
      {
        "productArea": "Platform",
        "ruleCount": 5,
        "invariantCount": 5,
        "phases": [
          {
            "phase": "Phase 1",
            "features": [
              {
                "pattern": "UserRegistration",
                "source": "src/specs/user-registration.feature",
                "rules": [
                  {
                    "name": "Valid registrations create new accounts",
                    "invariant": "Each email address maps to exactly one user account.",
                    "rationale": "Prevents account confusion and ensures unique identity.",
                    "verifiedBy": ["Successful registration with valid email", "Registration assigns a unique user ID"],
                    "scenarioCount": 2
                  }
                ]
              }
            ]
          }
        ]
      }
    ],
    "totalRules": 5,
    "totalInvariants": 5
  }
}
```

> **What just happened:** The system extracted 5 business rules from 2 Gherkin features, each with invariant statements and scenario verification links. Every `Rule:` block with an `**Invariant:**` becomes a queryable business rule.

(Output truncated for brevity — the full JSON includes all 5 rules across both features.)

### 7.6 Generate business rules documentation

```bash
npm run docs:business-rules
```

```
Running generator: business-rules
  ✓ BUSINESS-RULES.md
  ✓ business-rules/platform.md
```

`BUSINESS-RULES.md` shows a summary: "5 rules from 2 features across 1 product area." The detail page `business-rules/platform.md` lists every invariant with its rationale and verification scenarios.

### 7.7 Check the enriched overview

```bash
npm run process:overview
```

```
=== PROGRESS ===
11 patterns (0 completed, 1 active, 10 planned) = 0%

=== ACTIVE PHASES ===
Phase 1: Inception (1 active)

=== BLOCKING ===
UserService blocked by: EventStore
AuthHandler blocked by: UserService
Authentication blocked by: UserRegistration
```

The Gherkin features added 2 more main patterns (UserRegistration, Authentication) plus the blocking analysis now includes spec-level dependencies.

### Checkpoint: Part 7

- [ ] `npm run process:sources` shows 3 TypeScript + 2 Gherkin files
- [ ] `npm run process:rules` returns 5 business rules
- [ ] `docs-generated/BUSINESS-RULES.md` exists
- [ ] `npm run process:overview` shows 11 patterns

### Recap: Part 7

- Gherkin features own planning metadata: status, phase, deliverables, business rules
- TypeScript owns implementation metadata: uses, used-by, shapes, architecture
- Together they form a complete picture — neither duplicates the other
- `Rule:` blocks with `**Invariant:**`/`**Rationale:**` become queryable business rules
- Gherkin tags use colon syntax (`@libar-docs-pattern:Name`), TypeScript uses spaces

---

## Part 8: Design Stubs

_Design stubs describe a pattern's design before the implementation exists. They document the API contract, design decisions, and target path — making the "not yet built" parts of your system visible._

### 8.1 Create `src/stubs/notification-service.stub.ts`

```typescript
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
```

### 8.2 Stub-specific tags

| Tag | Example | Purpose |
|---|---|---|
| `@libar-docs-target` | `src/sample-sources/notification-service.ts` | Path where the real implementation will live. The resolver checks if this file exists. |
| `@libar-docs-since` | `design-session-1` | Identifies which design session created the stub. |

### 8.3 Query stubs

```bash
npm run process:stubs
```

```json
{
  "success": true,
  "data": [
    {
      "pattern": "NotificationService",
      "stubs": [
        {
          "stubName": "NotificationService",
          "stubFile": "src/stubs/notification-service.stub.ts",
          "targetPath": "src/sample-sources/notification-service.ts",
          "since": "design-session-1",
          "targetExists": false
        }
      ],
      "resolvedCount": 0,
      "unresolvedCount": 1
    }
  ]
}
```

> **What just happened:** `targetExists: false` tells you the implementation doesn't exist yet. When you create the real file at `src/sample-sources/notification-service.ts`, the resolver will mark it as resolved.

### Checkpoint: Part 8

- [ ] `src/stubs/notification-service.stub.ts` exists with `@libar-docs-target` and `@libar-docs-since`
- [ ] `npm run process:stubs` shows the stub with `targetExists: false`
- [ ] `npm run process:sources` shows 1 stub file

### Recap: Part 8

- Stubs document API contracts before implementation exists
- `@libar-docs-target` tracks where the real file will live
- `@libar-docs-since` records which design session created the stub
- The stubs query shows resolution status — unresolved stubs are visible work items

---

## Part 9: Reference Docs & Full Generation

_You have all source types in place: TypeScript, Gherkin, and stubs. Now you'll create a bespoke reference document, generate everything, and lint your annotations._

### 9.1 Add referenceDocConfigs to configuration

Update `delivery-process.config.ts` to add the `referenceDocConfigs` array:

```typescript
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
```

### 9.2 Reference doc config fields

| Field | Purpose |
|---|---|
| `title` | Document heading |
| `conventionTags` | Convention tags to include (from `@libar-docs-convention`-tagged files) |
| `shapeSources` | Glob patterns for TypeScript shape extraction |
| `behaviorCategories` | Category filters — which patterns' descriptions to include |
| `diagramScopes` | Scoped Mermaid diagrams with bounded context filtering |
| `claudeMdSection` | Target directory under `_claude-md/` for AI-consumption summary |
| `docsFilename` | Output filename in `docs/` for the detailed version |
| `claudeMdFilename` | Output filename in `_claude-md/` for the compact version |

**Diagram scope options:**

| Field | Purpose |
|---|---|
| `archContext` | Filter to patterns in these bounded contexts |
| `direction` | Mermaid graph direction: `TB` (top-bottom) or `LR` (left-right) |
| `diagramType` | `graph`, `sequenceDiagram`, `stateDiagram-v2`, `C4Context`, `classDiagram` |
| `showEdgeLabels` | Show relationship type labels on arrows |

### 9.3 Generate the reference doc

```bash
npm run docs:reference
```

```
Running generator: reference-docs
  ✓ docs/IDENTITY-PERSISTENCE-REFERENCE.md
  ✓ _claude-md/reference/identity-persistence-reference.md
```

The generated reference doc includes:

**1. Architecture Diagram** — A Mermaid graph scoped to `identity` and `persistence` contexts with labeled edges showing uses (solid) and depends-on (dashed) relationships.

**2. API Types** — TypeScript interfaces extracted from shapes: `UserRecord`, `DomainEvent`, `AuthResult`.

**3. Behavior Specifications** — Descriptions from each pattern's JSDoc, including Gherkin feature rule blocks with invariants.

Each `referenceDocConfigs` entry produces two files: a detailed version in `docs/` and a compact version in `_claude-md/` for AI context consumption.

### 9.4 Generate everything

```bash
npm run docs:all
```

```
Running generator: patterns        → PATTERNS.md + 11 detail pages
Running generator: roadmap         → ROADMAP.md + 3 phase pages
Running generator: reference-docs  → 2 files (detailed + compact)
Running generator: overview-rdm    → OVERVIEW.md
Running generator: architecture    → ARCHITECTURE.md
Running generator: business-rules  → BUSINESS-RULES.md + 1 detail page
Running generator: taxonomy        → TAXONOMY.md + 3 detail pages

✅ 26 files written
```

### 9.5 Available generators

Run `npm run docs:list` to see all registered generators. Key ones used in `docs:all`:

| Generator Name | Output | Description |
|---|---|---|
| `patterns` | PATTERNS.md | Pattern registry with categories, dependencies, detail pages |
| `roadmap` | ROADMAP.md | Development roadmap by phase with progress tracking |
| `reference-docs` | docs/*.md | Bespoke reference docs from `referenceDocConfigs` |
| `overview-rdm` | OVERVIEW.md | Project architecture overview |
| `architecture` | ARCHITECTURE.md | Mermaid component diagram with bounded context subgraphs |
| `business-rules` | BUSINESS-RULES.md | Business rules and invariants from Gherkin `Rule:` blocks |
| `taxonomy` | TAXONOMY.md | Tag taxonomy reference with all metadata tags and format types |

> **Tip:** Pass all generators as a single comma-separated value: `-g patterns,roadmap,architecture`. Do **not** use multiple `-g` flags — this is not supported and may cause generators to be silently skipped.

Other available generators: `current`, `remaining`, `adrs`, `validation-rules`, `requirements`, `milestones`, `changelog`, `session`, `session-plan`, `session-findings`, `planning-checklist`, `traceability`, `pr-changes`.

### 9.6 ARCHITECTURE.md highlights

The architecture generator creates a Mermaid component diagram with:
- Bounded context subgraphs (`identity`, `persistence`)
- Component role labels (`[service]`, `[infrastructure]`)
- Relationship arrows with correct styles (solid for `uses`, dashed for `depends-on`)
- A legend explaining arrow styles
- A component inventory table listing every component with its context, role, layer, and source file

### 9.7 TAXONOMY.md highlights

The taxonomy generator documents the entire tag system:
- All 3 categories with priorities
- All 53 metadata tags grouped by domain (Core, Relationship, Timeline, ADR, Architecture, etc.)
- Format types (value, enum, quoted-value, csv, number, flag)
- Available presets
- A Mermaid pipeline diagram showing the Config → Scanner → Extractor → Transformer → Codec → Markdown flow

### 9.8 Linting

```bash
npm run lint:patterns
```

```
src/sample-sources/user-service.ts
  34:1  error    missing-pattern-name  Pattern missing explicit name...
  34:1  warning  missing-status        No @libar-docs-status found...

src/sample-sources/event-store.ts
  32:1  error    missing-pattern-name  Pattern missing explicit name...

src/sample-sources/auth-handler.ts
  31:1  error    missing-pattern-name  Pattern missing explicit name...

✗ 3 errors, 6 warnings, 3 info
```

The 3 errors are from `@libar-docs-shape` annotations on interfaces — these are lightweight shape entries that lack their own `@libar-docs-pattern` names. This is expected. The shapes are discovered through the `@libar-docs-extract-shapes` tag on the parent pattern, so they don't need independent pattern names.

### Checkpoint: Part 9

- [ ] `delivery-process.config.ts` has `referenceDocConfigs`
- [ ] `npm run docs:all` writes 26 files to `docs-generated/`
- [ ] `docs-generated/docs/IDENTITY-PERSISTENCE-REFERENCE.md` exists
- [ ] `docs-generated/_claude-md/reference/` has the compact version
- [ ] `npm run lint:patterns` shows 3 errors (all expected shape warnings)

### Recap: Part 9

- Reference docs are custom composite documents scoped to bounded contexts
- `docs:all` generates everything in one command — 7 generators produce 26 files
- The linter validates annotation quality; shape-only warnings are expected
- Two output formats per reference doc: detailed (for humans) and compact (for AI agents)

---

## Part 10: Advanced Process Data API

_Throughout this tutorial, you've used `process:overview`, `process:sources`, `process:tags`, `process:rules`, `process:stubs`, and commands like `dep-tree`, `list`, and `arch context`. This section covers advanced queries you haven't seen yet._

### 10.1 Commands you already know

| Command | First Used | Purpose |
|---------|-----------|---------|
| `process:overview` | Part 3 | Project health summary |
| `process:sources` | Part 3 | Source file inventory |
| `process:tags` | Part 4 | Tag usage distribution |
| `process:list` | Part 5 | Pattern listing with filters |
| `dep-tree` | Part 5 | Recursive dependency chains |
| `arch context` | Part 5 | Bounded context listing |
| `process:rules` | Part 7 | Business rules from Gherkin |
| `process:stubs` | Part 8 | Design stub resolution status |

### 10.2 Architecture neighborhood

See everything a pattern touches — uses, used-by, same-context peers:

```bash
npm run process:query -- arch neighborhood UserService
```

```json
{
  "data": {
    "pattern": "UserService",
    "context": "identity",
    "uses": [{ "name": "EventStore", "status": "deferred", "archContext": "persistence" }],
    "usedBy": [{ "name": "AuthHandler", "status": "roadmap", "archContext": "identity" }],
    "sameContext": [
      { "name": "AuthHandler", "archContext": "identity" },
      { "name": "NotificationService", "archContext": "identity" }
    ],
    "implementedBy": ["UserRegistration"]
  }
}
```

### 10.3 Blocking analysis

Find patterns stuck on incomplete dependencies:

```bash
npm run process:query -- arch blocking
```

```json
{
  "data": [
    { "pattern": "UserService", "status": "active", "blockedBy": ["EventStore"] },
    { "pattern": "AuthHandler", "status": "roadmap", "blockedBy": ["UserService"] },
    { "pattern": "Authentication", "status": "roadmap", "blockedBy": ["UserRegistration"] }
  ]
}
```

### 10.4 Dangling references

Find broken references to nonexistent pattern names:

```bash
npm run process:query -- arch dangling
```

Returns an empty array if all references resolve — which they should in this tutorial project.

### 10.5 Full pattern detail

Get complete metadata for a single pattern:

```bash
npm run process:query -- pattern UserService
```

Returns the full JSON with all tags, relationships, extracted shapes, deliverables, and source info.

### 10.6 Output modifiers

Any JSON-outputting command supports these composable modifiers:

| Flag | Effect | Example |
|---|---|---|
| `--names-only` | Return array of pattern name strings | `list --names-only` |
| `--count` | Return integer count | `list --status roadmap --count` |
| `--fields name,status,phase` | Selected fields only | `list --fields patternName,status` |
| `--full` | Bypass summarization, return raw data | `list --full` |

```bash
# How many roadmap patterns?
npm run process:query -- list --status roadmap --count

# Just the names
npm run process:query -- list --names-only
```

### Recap: Part 10

- `arch neighborhood` shows a pattern's full connectivity
- `arch blocking` surfaces dependency bottlenecks
- `arch dangling` catches broken references
- `pattern <name>` returns complete JSON detail
- Output modifiers (`--names-only`, `--count`, `--fields`, `--full`) shape any query's response

---

## Conclusion: What's Next

You've built a fully annotated project with:

- **3 TypeScript sources** with identity, status, architecture, and relationship metadata
- **2 Gherkin features** with business rules, acceptance criteria, and deliverables
- **1 design stub** for a pattern that doesn't exist yet
- **26 generated documentation files** covering patterns, roadmaps, architecture, business rules, taxonomy, and reference docs

Everything was derived from annotations in your code — nothing was hand-authored in `docs-generated/`.

### Where to go from here

1. **Annotate your real project** — Start with 2–3 core files, run `process:overview`, and grow from there
2. **Add to CI** — Run `lint:patterns` and `lint:validate` in your pipeline to enforce annotation quality
3. **Feed AI agents** — Point Claude Code or Cursor at `process:query` commands instead of stale Markdown
4. **Explore the full tag taxonomy** — Run `npm run docs:taxonomy` and read `docs-generated/TAXONOMY.md` for all 53 metadata tags
5. **Try the `ddd-es-cqrs` preset** — For DDD projects with 21 categories and full bounded context support

### Resources

- [Package README](https://www.npmjs.com/package/@libar-dev/delivery-process) — Full documentation and value proposition
- `node_modules/@libar-dev/delivery-process/docs/INDEX.md` — Complete docs index with section links and reading paths
- `node_modules/@libar-dev/delivery-process/docs/PROCESS-API.md` — All 26+ API methods
- `node_modules/@libar-dev/delivery-process/docs/ANNOTATION-GUIDE.md` — Complete annotation reference with shape extraction modes

---

## Troubleshooting & FAQ

### "npm run process:overview shows 0 patterns"

- Check that your source file has `/** @libar-docs */` as a **standalone JSDoc comment** at the top of the file — not inside a class or function
- Check that `delivery-process.config.ts` has the correct glob pattern matching your file path
- Run `npm run process:sources` to see which files the scanner actually found

### "Lint shows errors for shape patterns"

This is expected. `@libar-docs-shape` on interfaces creates lightweight shape entries in the registry. The linter flags these for missing `@libar-docs-pattern` names. These are informational, not blocking — the shapes are discovered through the parent pattern's `@libar-docs-extract-shapes` tag.

### "Phase names don't match expectations"

Phase numbers map to the **6-phase-standard** workflow:
1. Inception, 2. Elaboration, 3. Session, 4. Construction, 5. Validation, 6. Retrospective

### "docs:all generates fewer files than expected"

- Check that all source directories have files: `src/sample-sources/`, `src/specs/`, `src/stubs/`
- Run `npm run process:sources` to verify all file types are detected
- Ensure `referenceDocConfigs` is present in `delivery-process.config.ts` for reference doc generation

### "dep-tree shows no dependencies"

- Verify both the source and target patterns exist: `npm run process:query -- list --names-only`
- Check for typos in `@libar-docs-uses` and `@libar-docs-depends-on` values — pattern names are case-sensitive

### "Gherkin feature not detected"

- Ensure `@libar-docs` appears as the first tag above `Feature:` (no other tags before it)
- Tags use colon syntax in Gherkin: `@libar-docs-pattern:Name` (not `@libar-docs-pattern Name`)
- Verify `sources.features` in config matches your file path

### FAQ: Why annotations instead of a separate config file?

Annotations live next to the code they describe. When you move, rename, or delete code, the annotations move with it. A separate config file would drift — annotations can't.

### FAQ: Can I use npx instead of tsx?

The package exports CLI binaries (`generate-docs`, `process-api`, `lint-patterns`, etc.), so `npx generate-docs` should work. This tutorial uses `tsx` to run the dist files directly for reliability across environments.

---

## Appendix A: Full npm Scripts Reference

| Script | Description |
|---|---|
| **Process Data API** | |
| `npm run process:query -- <cmd>` | Run any process-api subcommand |
| `npm run process:overview` | Project health summary |
| `npm run process:status` | Pattern counts and completion % |
| `npm run process:list` | List all patterns |
| `npm run process:tags` | Tag usage report |
| `npm run process:sources` | Source file inventory |
| `npm run process:rules` | Business rules from Gherkin |
| `npm run process:stubs` | Design stubs with resolution status |
| **Doc Generators** | |
| `npm run docs:all` | Generate all doc types (7 generators) |
| `npm run docs:patterns` | Pattern registry + detail pages |
| `npm run docs:roadmap` | Roadmap by phase |
| `npm run docs:reference` | Bespoke reference docs |
| `npm run docs:overview` | Project overview |
| `npm run docs:architecture` | Architecture diagrams |
| `npm run docs:business-rules` | Business rules + invariants |
| `npm run docs:taxonomy` | Tag taxonomy reference |
| `npm run docs:list` | List all available generators |
| **Linting** | |
| `npm run lint:patterns` | Check annotation quality |
| `npm run lint:validate` | Cross-source validation (TS + Gherkin) |

---

## Appendix B: Setup Checklist

This is the complete checklist of everything a project setup command would create:

### Files

- [ ] `package.json` — ESM, dependency on `@libar-dev/delivery-process@pre`, devDependencies on `typescript` + `tsx`, all npm scripts
- [ ] `tsconfig.json` — ES2022, NodeNext, strict, includes src/ and config
- [ ] `delivery-process.config.ts` — Preset, sources (typescript + features + stubs), output directory

### Directories

- [ ] `src/sample-sources/` — TypeScript implementation files
- [ ] `src/specs/` — Gherkin plan-level specs
- [ ] `src/stubs/` — Design-level stub files
- [ ] `docs-generated/` — Created automatically by generators

### Sample Files (optional scaffold)

- [ ] `src/sample-sources/user-service.ts` — Annotated sample with all key tags
- [ ] `src/specs/user-registration.feature` — Sample plan-level spec with Background, Rules, scenarios
- [ ] `src/stubs/notification-service.stub.ts` — Sample design stub

### Validation

- [ ] `npm run process:overview` — Returns pattern count > 0
- [ ] `npm run docs:patterns` — Generates PATTERNS.md
- [ ] `npm run process:rules` — Returns business rules (if features exist)

---

## Appendix C: Tag Quick Reference

### Required Tags

| Tag | Format | Example |
|---|---|---|
| `@libar-docs` | file opt-in (standalone JSDoc or Gherkin tag) | `/** @libar-docs */` |
| `@libar-docs-pattern` | `Name` | `@libar-docs-pattern UserService` |

### Status FSM

```
roadmap → active → completed
  ↓         ↓
deferred  roadmap (blocked)
```

### Relationship Arrows in Diagrams

| Tag | Arrow Style | Meaning |
|---|---|---|
| `uses` / `used-by` | `-->` solid | Direct dependency |
| `depends-on` / `enables` | `-.->` dashed | Roadmap sequencing |
| `implements` | `..->` dotted | Spec realizes code |
| `extends` | `-->>` open | Generalization |

### Tag Syntax by Context

| Context | Syntax | Example |
|---|---|---|
| TypeScript JSDoc | Space-separated | `@libar-docs-pattern UserService` |
| Gherkin tags | Colon-separated | `@libar-docs-pattern:UserService` |
