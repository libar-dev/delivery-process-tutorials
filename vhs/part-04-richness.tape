# Part 4: Adding Richness — architecture, enrichment, and shape tags
# Assumes: Parts 0-3 have been run

Output vhs/output/part-04-richness.gif
Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set TypingSpeed 40ms
Set Padding 20

Type "echo '═══ Part 4: Adding Richness Layer by Layer ═══'"
Enter
Sleep 2s

# Replace user-service.ts with enriched version
Type "runme run create-user-service-v2 --filename TUTORIAL-RUNME.md"
Enter
Sleep 2s

Type "cat src/sample-sources/user-service.ts"
Enter
Sleep 6s

# Tag usage report
Type "echo '--- Tag usage report ---'"
Enter
Sleep 1s

Type "runme run tags-after-richness --filename TUTORIAL-RUNME.md"
Enter
Sleep 4s

# Overview now shows shapes
Type "echo '--- Overview with shapes ---'"
Enter
Sleep 1s

Type "runme run overview-after-richness --filename TUTORIAL-RUNME.md"
Enter
Sleep 3s

Type "echo '✓ Part 4 complete — 2 patterns (UserService + UserRecord shape)'"
Enter
Sleep 2s
