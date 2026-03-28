# Migration Changes: @libar-dev/delivery-process → @libar-dev/architect

Reference for migrating consumer projects from `@libar-dev/delivery-process` to `@libar-dev/architect` v1.0.0-pre.3.

---

## 1. Package dependency

**Change:** Replace the npm dependency name and bump version.

```diff
- "@libar-dev/delivery-process": "1.0.0-pre.0"
+ "@libar-dev/architect": "1.0.0-pre.3"
```

Then run `npm install` (or `pnpm install`).

---

## 2. Config file rename

**Change:** Rename the config file.

```
delivery-process.config.ts → architect.config.ts
```

The new package searches for `architect.config.ts` first, then falls back to `delivery-process.config.ts` with a deprecation warning. Rename to avoid the warning.

**Also update:**
- `tsconfig.json` `include` array: `"delivery-process.config.ts"` → `"architect.config.ts"`
- `.gitignore` if it lists `delivery-process.config.ts`
- Any scripts that copy or reference the config filename

---

## 3. Config file import path

**Change:** Update the `defineConfig` import.

```diff
- import { defineConfig } from "@libar-dev/delivery-process/config";
+ import { defineConfig } from "@libar-dev/architect/config";
```

---

## 4. Config schema: `shapeSources` removed

**Change:** Remove the `shapeSources` field from `referenceDocConfigs` entries.

```diff
  referenceDocConfigs: [{
    title: "...",
    conventionTags: [],
-   shapeSources: ["src/**/*.ts"],
    behaviorCategories: ["core", "api", "infra"],
```

Shapes are now selected via `shapeSelectors` (fine-grained declaration-level filtering) or auto-discovered from the dataset. The old glob-based `shapeSources` field was removed.

**New field (optional):** `shapeSelectors: ShapeSelector[]` where:
- `{ group: "api-types" }` — select shapes by group tag
- `{ source: "src/foo.ts", names: ["MyType"] }` — specific shapes from a file
- `{ source: "src/foo.ts" }` — all tagged shapes from a file

---

## 5. Config schema: reference doc output path

**Change:** Reference docs now output to `reference/` instead of `docs/`.

```diff
- ✓ docs/IDENTITY-PERSISTENCE-REFERENCE.md
+ ✓ reference/IDENTITY-PERSISTENCE-REFERENCE.md
```

Update any references to the old `docs/` output path in documentation or scripts.

---

## 6. Annotation prefix (TypeScript)

**Change:** Replace all annotation tags.

```diff
- /** @libar-docs */
+ /** @architect */

- * @libar-docs-pattern UserService
- * @libar-docs-status active
- * @libar-docs-core
+ * @architect-pattern UserService
+ * @architect-status active
+ * @architect-core

- /** @libar-docs-shape reference-sample */
+ /** @architect-shape reference-sample */
```

**Shortcut:** Global find-replace `@libar-docs` → `@architect` catches both the file opt-in tag and all prefixed tags.

**Backward compatibility:** Consumers can set `tagPrefix: '@libar-docs-'` in `architect.config.ts` to keep existing annotations without mass-replacement.

---

## 7. Annotation prefix (Gherkin)

**Change:** Same prefix change, colon syntax.

```diff
- @libar-docs
- @libar-docs-pattern:UserRegistration
- @libar-docs-status:roadmap
+ @architect
+ @architect-pattern:UserRegistration
+ @architect-status:roadmap
```

Same global find-replace works: `@libar-docs` → `@architect`.

---

## 8. CLI paths in npm scripts

**Change:** Update all CLI invocation paths.

```diff
- "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/process-api.js"
+ "tsx ./node_modules/@libar-dev/architect/dist/cli/process-api.js"

- "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/generate-docs.js"
+ "tsx ./node_modules/@libar-dev/architect/dist/cli/generate-docs.js"

- "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/lint-patterns.js"
+ "tsx ./node_modules/@libar-dev/architect/dist/cli/lint-patterns.js"

- "tsx ./node_modules/@libar-dev/delivery-process/dist/cli/validate-patterns.js"
+ "tsx ./node_modules/@libar-dev/architect/dist/cli/validate-patterns.js"
```

The JS filenames (`process-api.js`, `generate-docs.js`, etc.) are unchanged — only the package directory path changes.

---

## 9. CLI output changes

**Change:** CLI output now references the new names.

- Config source line: `Using sources from delivery-process.config.ts...` → `Using sources from project config...`
- Lint config path: references `architect.config.ts`
- Lint error messages: `@libar-docs-pattern` → `@architect-pattern` etc.
- Overview includes `=== DATA API ===` section with `pnpm architect:query` references

---

## 10. Preset table (documentation only)

**Change:** The preset tag prefixes have changed.

| Preset | Old Prefix | New Prefix | Old Opt-In | New Opt-In |
|--------|-----------|------------|-----------|------------|
| `generic` | `@docs-` | `@docs-` | `@docs` | `@docs` |
| `libar-generic` | `@libar-docs-` | `@architect-` | `@libar-docs` | `@architect` |
| `ddd-es-cqrs` | `@libar-docs-` | `@architect-` | `@libar-docs` | `@architect` |

---

## Quick migration checklist

1. [ ] Update `package.json` dependency: name + version
2. [ ] Run `npm install`
3. [ ] Rename `delivery-process.config.ts` → `architect.config.ts`
4. [ ] Update import in config: `@libar-dev/architect/config`
5. [ ] Remove `shapeSources` from `referenceDocConfigs` (use `shapeSelectors` if needed)
6. [ ] Update `tsconfig.json` include path
7. [ ] Update `.gitignore` if applicable
8. [ ] Global find-replace in source files: `@libar-docs` → `@architect`
9. [ ] Update npm script CLI paths: `@libar-dev/delivery-process/dist/` → `@libar-dev/architect/dist/`
10. [ ] Regenerate documentation: `npm run docs:all`
11. [ ] Grep audit: `grep -r "@libar-docs" --include="*.ts" --include="*.feature"` should return 0

## Grep audit commands

```bash
# All should return 0 matches
grep -r "@libar-dev/delivery-process" --include="*.ts" --include="*.md" --include="*.json" . | grep -v node_modules
grep -r "delivery-process\.config" --include="*.ts" --include="*.md" --include="*.json" . | grep -v node_modules
grep -r "@libar-docs" --include="*.ts" --include="*.md" --include="*.feature" . | grep -v node_modules
```
