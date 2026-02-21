# Part 0: Setup — Reset workspace and install dependencies
# Run this before any other part tape to ensure clean state

Output vhs/output/part-00-setup.gif
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set TypingSpeed 40ms
Set Padding 20

Type "echo '═══ Part 0: Setup — Clean Workspace ═══'"
Enter
Sleep 2s

# Reset workspace to clean state
Type "runme run reset-workspace --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

# Install dependencies
Type "runme run install-deps --filename TUTORIAL-RUNME.md"
Enter
Sleep 8s

# Show clean state
Type "ls -la"
Enter
Sleep 2s

Type "cat package.json"
Enter
Sleep 3s

Type "echo '✓ Setup complete — ready for Part 1'"
Enter
Sleep 2s
