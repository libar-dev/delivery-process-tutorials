# Generate Tutorial Article

## Instructions for Claude Code

Generate a fresh `TUTORIAL-ARTICLE-v2.md` by combining the tutorial narrative with captured CLI outputs.

### Prerequisites

Run the capture script first:

```bash
./scripts/generate-article-outputs.sh
```

This produces `scripts/outputs/` containing:
- `*.txt` — stdout capture for every cell
- `snapshots/<part>/` — file states after each part (source files, configs, generated docs, tree listing)
- `environment.txt` — Node.js version, OS, date, package version

### Prompt

Use this prompt with Claude Code:

---

**Task:** Generate `TUTORIAL-ARTICLE-v2.md` — a static, readable version of the tutorial with all CLI outputs embedded.

**Inputs to read:**

1. `TUTORIAL-RUNME.md` — the source of truth for narrative text, code blocks, and tutorial structure
2. `scripts/outputs/environment.txt` — test environment info for the header table
3. `scripts/outputs/*.txt` — captured cell outputs (one file per cell, named by cell name)
4. `scripts/outputs/snapshots/*/` — file snapshots after each part (read source files from here when needed)

**Output format:**

Follow the exact structure of `TUTORIAL-ARTICLE-v1.md` as a reference for style and format:

1. **Title + intro** — same as TUTORIAL-RUNME.md intro, adapted for article format
2. **Test Environment table** — populated from `environment.txt`
3. **Introduction** — rewritten from the notebook intro (no Runme-specific instructions)
4. **"What you will build/learn" table** — from TUTORIAL-RUNME.md
5. **Parts 1-10** — each part contains:
   - Section header (e.g., `## Part 3: Your First Annotation`)
   - Subsections with narrative text extracted from TUTORIAL-RUNME.md
   - Code blocks for file contents (from `snapshots/<part>/` files — use the actual file contents, not the heredoc from the cell)
   - CLI command + output blocks: show the command (`npm run process:overview`) then the captured output from the corresponding `.txt` file
   - "What just happened" callouts after key steps
   - Skip checkpoint cells — they are verification-only and not useful in the article
6. **Results Summary** — from `final-verification.txt`
7. **Appendix A: npm Scripts Reference** — table of all scripts
8. **Appendix B: Tag Quick Reference** — from TUTORIAL-RUNME.md appendix

**Key rules:**

- Every CLI output shown must come verbatim from the `scripts/outputs/*.txt` files
- File contents shown must come from the `scripts/outputs/snapshots/` directory
- Do NOT invent or approximate outputs — use exactly what was captured
- Strip ANSI color codes from captured outputs if present
- The article should read as a standalone document — no references to "run this cell" or Runme
- Use the same tone as TUTORIAL-ARTICLE-v1.md: direct, technical, tutorial-style
- Include the "Issues & Improvements" section only if discrepancies are found between narrative and actual outputs

---

### Workflow summary

```
1. Run:    ./scripts/generate-article-outputs.sh
2. Prompt: claude "Read scripts/GENERATE-ARTICLE-PROMPT.md and follow the instructions to generate TUTORIAL-ARTICLE-v2.md"
3. Review: Compare v2 with v1 to check for regressions or improvements
```
