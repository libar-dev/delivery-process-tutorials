# Part 8: Design Stubs — describe future implementations
# Assumes: Parts 0-7 have been run

Output vhs/output/part-08-design-stubs.gif
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set TypingSpeed 40ms
Set Padding 20

Type "echo '═══ Part 8: Design Stubs ═══'"
Enter
Sleep 2s

# Create notification service stub
Type "runme run create-notification-stub --filename TUTORIAL-RUNME.md"
Enter
Sleep 2s

Type "cat src/stubs/notification-service.stub.ts"
Enter
Sleep 4s

# Query stubs
Type "echo '--- Design stubs ---'"
Enter
Sleep 1s

Type "runme run query-stubs --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

Type "echo '✓ Part 8 complete — stub registered'"
Enter
Sleep 2s
