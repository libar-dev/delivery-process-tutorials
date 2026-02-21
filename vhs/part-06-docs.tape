# Part 6: Generate Documentation — pattern registry + roadmap
# Assumes: Parts 0-5 have been run

Output vhs/output/part-06-doc-generation.gif
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set TypingSpeed 40ms
Set Padding 20

Type "echo '═══ Part 6: Generate Documentation ═══'"
Enter
Sleep 2s

# Generate pattern docs
Type "echo '--- Generating pattern registry ---'"
Enter
Sleep 1s

Type "runme run gen-patterns --filename TUTORIAL-RUNME.md"
Enter
Sleep 5s

# Generate roadmap
Type "echo '--- Generating roadmap ---'"
Enter
Sleep 1s

Type "runme run gen-roadmap --filename TUTORIAL-RUNME.md"
Enter
Sleep 4s

# List generated files
Type "echo '--- Generated files ---'"
Enter
Sleep 1s

Type "runme run list-generated --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

Type "echo '✓ Part 6 complete — first docs generated'"
Enter
Sleep 2s
