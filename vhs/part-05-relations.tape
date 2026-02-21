# Part 5: Relationships & Multiple Sources — dependency graph
# Assumes: Parts 0-4 have been run

Output vhs/output/part-05-relationships.gif
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set TypingSpeed 40ms
Set Padding 20

Type "echo '═══ Part 5: Relationships & Multiple Sources ═══'"
Enter
Sleep 2s

# Final user-service.ts with relationship tags
Type "runme run create-user-service-final --filename TUTORIAL-RUNME.md"
Enter
Sleep 2s

# Create auth-handler.ts
Type "runme run create-auth-handler --filename TUTORIAL-RUNME.md"
Enter
Sleep 2s

# Create event-store.ts
Type "runme run create-event-store --filename TUTORIAL-RUNME.md"
Enter
Sleep 2s

# Show all source files
Type "echo '--- Source files created ---'"
Enter
Sleep 1s

Type "ls -la src/sample-sources/"
Enter
Sleep 2s

# Overview with dependency graph
Type "echo '--- Overview with dependencies ---'"
Enter
Sleep 1s

Type "runme run overview-with-deps --filename TUTORIAL-RUNME.md"
Enter
Sleep 4s

# Dependency tree
Type "echo '--- Dependency tree for AuthHandler ---'"
Enter
Sleep 1s

Type "runme run dep-tree-auth --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

# Architecture contexts
Type "echo '--- Architecture contexts ---'"
Enter
Sleep 1s

Type "runme run arch-contexts --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

# Roadmap items
Type "echo '--- Roadmap items ---'"
Enter
Sleep 1s

Type "runme run list-roadmap --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

Type "echo '✓ Part 5 complete — 6 patterns, blocking chains visible'"
Enter
Sleep 2s
