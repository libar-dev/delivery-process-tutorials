# VHS Tutorial Recordings

Automated terminal recordings of the dp-mini-demo tutorial using [VHS](https://github.com/charmbracelet/vhs).

## Prerequisites

```bash
brew install vhs
```

## Usage

Tapes must be run **in order** — each part depends on the previous parts having been executed.

### Record the full tutorial

```bash
cd /path/to/dp-mini-demo

# Step 1: Clean setup
vhs vhs/part-00-setup.tape

# Step 2: Record each part
vhs vhs/part-01-project.tape
vhs vhs/part-02-config.tape
vhs vhs/part-03-first.tape
vhs vhs/part-04-richness.tape
vhs vhs/part-05-relations.tape
vhs vhs/part-06-docs.tape
vhs vhs/part-07-gherkin.tape
vhs vhs/part-08-stubs.tape
vhs vhs/part-09-full-gen.tape
vhs vhs/part-10-advanced.tape
```

### Record a single part

To re-record just one part (e.g., after changing Part 7), you need to run all prior parts first:

```bash
# Run setup + parts 1-6 to get to the right state
vhs vhs/part-00-setup.tape
for i in 01 02 03 04 05 06; do vhs vhs/part-${i}-*.tape; done

# Now record Part 7
vhs vhs/part-07-gherkin.tape
```

### Record all parts (one-liner)

```bash
for tape in vhs/part-*.tape; do echo "Recording: $tape"; vhs "$tape"; done
```

## Output

GIF files are written to `vhs/output/`:

| File | Part |
|------|------|
| `part-00-setup.gif` | Setup: reset + install |
| `part-01-project-setup.gif` | Part 1: Project Setup |
| `part-02-configuration.gif` | Part 2: Configuration |
| `part-03-first-annotation.gif` | Part 3: Your First Annotation |
| `part-04-richness.gif` | Part 4: Adding Richness |
| `part-05-relationships.gif` | Part 5: Relationships |
| `part-06-doc-generation.gif` | Part 6: Doc Generation |
| `part-07-gherkin-specs.gif` | Part 7: Gherkin Specs |
| `part-08-design-stubs.gif` | Part 8: Design Stubs |
| `part-09-full-generation.gif` | Part 9: Full Generation |
| `part-10-advanced-queries.gif` | Part 10: Advanced Queries |

## Customization

Edit any `.tape` file to adjust:
- `Set FontSize` — text size (default: 14)
- `Set Width/Height` — terminal dimensions (default: 1200x600)
- `Set Theme` — color theme (default: Catppuccin Mocha)
- `Set TypingSpeed` — typing animation speed (default: 40ms)
- `Sleep` durations — pause between commands

Change output format by changing the file extension in `Output`:
- `.gif` — animated GIF (default, good for embedding)
- `.mp4` — video (higher quality, smaller size)
- `.webm` — web video format

## CI/CD

Use [vhs-action](https://github.com/charmbracelet/vhs-action) to keep recordings up-to-date:

```yaml
- uses: charmbracelet/vhs-action@v2
  with:
    path: vhs/part-03-first.tape
```
