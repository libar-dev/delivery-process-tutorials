# Part 1: Project Setup — tsconfig + folder structure
# Assumes: Part 0 (setup) has been run

Output vhs/output/part-01-project-setup.gif
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set TypingSpeed 40ms
Set Padding 20

Type "echo '═══ Part 1: Project Setup ═══'"
Enter
Sleep 2s

# Verify dependencies are installed
Type "runme run verify-deps --filename TUTORIAL-RUNME.md"
Enter
Sleep 4s

# Create tsconfig.json
Type "runme run create-tsconfig --filename TUTORIAL-RUNME.md"
Enter
Sleep 2s

Type "cat tsconfig.json"
Enter
Sleep 3s

# Create folder structure
Type "runme run create-folders --filename TUTORIAL-RUNME.md"
Enter
Sleep 2s

Type "find src/ -type d"
Enter
Sleep 2s

# Checkpoint
Type "runme run checkpoint-1 --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

Type "echo '✓ Part 1 complete'"
Enter
Sleep 2s
