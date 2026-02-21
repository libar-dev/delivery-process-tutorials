# Part 10: Advanced Process Data API — queries and final overview
# Assumes: Parts 0-9 have been run

Output vhs/output/part-10-advanced-queries.gif
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set TypingSpeed 40ms
Set Padding 20

Type "echo '═══ Part 10: Advanced Process Data API ═══'"
Enter
Sleep 2s

# Architecture neighborhood
Type "echo '--- Architecture neighborhood: UserService ---'"
Enter
Sleep 1s

Type "runme run arch-neighborhood --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

# Blocking analysis
Type "echo '--- Blocking analysis ---'"
Enter
Sleep 1s

Type "runme run arch-blocking --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

# Dangling references
Type "echo '--- Dangling reference check ---'"
Enter
Sleep 1s

Type "runme run arch-dangling --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

# Pattern detail
Type "echo '--- Pattern detail: UserService ---'"
Enter
Sleep 1s

Type "runme run pattern-detail --filename TUTORIAL-RUNME.md"
Enter
Sleep 4s

# Roadmap count
Type "echo '--- Roadmap count ---'"
Enter
Sleep 1s

Type "runme run count-roadmap --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

# Final overview
Type "echo '--- Final project overview ---'"
Enter
Sleep 1s

Type "runme run final-overview --filename TUTORIAL-RUNME.md"
Enter
Sleep 4s

# Final verification
Type "echo '--- Final verification ---'"
Enter
Sleep 1s

Type "runme run final-verification --filename TUTORIAL-RUNME.md"
Enter
Sleep 5s

Type "echo '✓ Tutorial complete!'"
Enter
Sleep 3s
