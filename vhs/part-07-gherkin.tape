# Part 7: Gherkin Specs — business rules from feature files
# Assumes: Parts 0-6 have been run

Output vhs/output/part-07-gherkin-specs.gif
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set TypingSpeed 40ms
Set Padding 20

Type "echo '═══ Part 7: Plan-Level Specs (Gherkin Features) ═══'"
Enter
Sleep 2s

# Create user registration feature
Type "runme run create-user-reg-feature --filename TUTORIAL-RUNME.md"
Enter
Sleep 2s

# Create authentication feature
Type "runme run create-auth-feature --filename TUTORIAL-RUNME.md"
Enter
Sleep 2s

Type "ls src/specs/"
Enter
Sleep 2s

# Query business rules
Type "echo '--- Business rules extracted ---'"
Enter
Sleep 1s

Type "runme run query-rules --filename TUTORIAL-RUNME.md"
Enter
Sleep 4s

# Generate business rules doc
Type "echo '--- Generating business rules doc ---'"
Enter
Sleep 1s

Type "runme run gen-business-rules --filename TUTORIAL-RUNME.md"
Enter
Sleep 4s

# Overview after Gherkin
Type "echo '--- Overview with Gherkin patterns ---'"
Enter
Sleep 1s

Type "runme run overview-after-gherkin --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

# Sources after Gherkin
Type "echo '--- All source files ---'"
Enter
Sleep 1s

Type "runme run sources-after-gherkin --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

Type "echo '✓ Part 7 complete — 8 patterns, 5 business rules'"
Enter
Sleep 2s
