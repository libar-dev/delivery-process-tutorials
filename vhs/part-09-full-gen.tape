# Part 9: Full Generation & Linting — all 26 docs + reference + lint
# Assumes: Parts 0-8 have been run

Output vhs/output/part-09-full-generation.gif
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set TypingSpeed 40ms
Set Padding 20

Type "echo '═══ Part 9: Full Generation & Linting ═══'"
Enter
Sleep 2s

# Generate all docs
Type "echo '--- Generating all documentation (7 generators) ---'"
Enter
Sleep 1s

Type "runme run gen-all --filename TUTORIAL-RUNME.md"
Enter
Sleep 8s

# List all generated files
Type "echo '--- All generated files ---'"
Enter
Sleep 1s

Type "runme run list-all-generated --filename TUTORIAL-RUNME.md"
Enter
Sleep 4s

# Update config with reference docs
Type "echo '--- Adding reference doc configuration ---'"
Enter
Sleep 1s

Type "runme run add-reference-config --filename TUTORIAL-RUNME.md"
Enter
Sleep 2s

# Generate reference docs
Type "runme run gen-reference --filename TUTORIAL-RUNME.md"
Enter
Sleep 5s

# List generators
Type "echo '--- Available generators ---'"
Enter
Sleep 1s

Type "runme run list-generators --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

# Lint patterns
Type "echo '--- Lint check (expect 3 warnings) ---'"
Enter
Sleep 1s

Type "runme run lint-patterns --filename TUTORIAL-RUNME.md"
Enter
Sleep 4s

Type "echo '✓ Part 9 complete — 26 docs generated'"
Enter
Sleep 2s
