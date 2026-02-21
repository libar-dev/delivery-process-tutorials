# Part 3: Your First Annotation — create user-service.ts v1
# Assumes: Parts 0-2 have been run

Output vhs/output/part-03-first-annotation.gif
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set TypingSpeed 40ms
Set Padding 20

Type "echo '═══ Part 3: Your First Annotation ═══'"
Enter
Sleep 2s

# Create user-service.ts with basic tags
Type "runme run create-user-service-v1 --filename TUTORIAL-RUNME.md"
Enter
Sleep 2s

Type "cat src/sample-sources/user-service.ts"
Enter
Sleep 5s

# See it detected
Type "echo '--- Process overview ---'"
Enter
Sleep 1s

Type "runme run overview-after-first --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

# Check sources
Type "echo '--- Source files ---'"
Enter
Sleep 1s

Type "runme run sources-after-first --filename TUTORIAL-RUNME.md"
Enter
Sleep 4s

Type "echo '✓ Part 3 complete — 1 pattern detected'"
Enter
Sleep 2s
