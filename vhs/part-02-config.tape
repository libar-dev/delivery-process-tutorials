# Part 2: Configuration — config file + npm scripts + first overview
# Assumes: Parts 0-1 have been run

Output vhs/output/part-02-configuration.gif
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set TypingSpeed 40ms
Set Padding 20

Type "echo '═══ Part 2: Configuration ═══'"
Enter
Sleep 2s

# Create delivery-process.config.ts
Type "runme run create-config --filename TUTORIAL-RUNME.md"
Enter
Sleep 2s

Type "cat delivery-process.config.ts"
Enter
Sleep 4s

# Add npm scripts to package.json
Type "runme run add-npm-scripts --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

# First overview (empty project)
Type "echo '--- First overview (empty project) ---'"
Enter
Sleep 1s

Type "runme run first-overview --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

# Checkpoint
Type "runme run checkpoint-2 --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

Type "echo '✓ Part 2 complete'"
Enter
Sleep 2s
