# Agent Usage Guide

## Overview

The automated agent workflow fetches GitHub issues, applies code fixes, runs tests, and closes issues automatically. This guide shows you how to use it.

---

## Quick Start

```bash
cd /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange
./scripts/complete-agent-workflow.sh <issue_number> <device_id>
```

**Example:**
```bash
./scripts/complete-agent-workflow.sh 5 57111FDCH007MJ
```

---

## Prerequisites

### 1. Device Setup
```bash
# Check device is connected
adb devices

# Expected output:
# List of devices attached
# 57111FDCH007MJ  device
```

### 2. GitHub CLI (Optional but Recommended)
```bash
# Install GitHub CLI
brew install gh

# Authenticate
gh auth login

# Verify
gh auth status
```

### 3. Python Dependencies
```bash
# Ensure Python 3 is available
python3 --version

# Install matplotlib for charts (optional)
pip3 install matplotlib
```

### 4. Project Directory
```bash
# Always run from project root
cd /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange
pwd  # Should show the project path
```

---

## Usage

### Basic Usage

```bash
./scripts/complete-agent-workflow.sh <issue_number> <device_id>
```

**Parameters:**
- `issue_number` - GitHub issue number to fix
- `device_id` - Android device ID (default: 57111FDCH007MJ)

### Examples

**Fix issue #5:**
```bash
./scripts/complete-agent-workflow.sh 5 57111FDCH007MJ
```

**Fix issue #3 with default device:**
```bash
./scripts/complete-agent-workflow.sh 3
```

**Test with offline mode (no GitHub API):**
```bash
./scripts/complete-agent-workflow.sh 999 57111FDCH007MJ
```

---

## Workflow Phases

The agent executes 10 automated phases:

### Phase 1: Fetch Issue
- Fetches issue from GitHub API
- Falls back to offline mode if API unavailable
- Analyzes issue title and body for patterns

### Phase 2: Before Screenshot
- Launches app on device
- Captures current state
- Saves to `screenshots/issue-{N}/before-fix.png`

### Phase 3: Apply Fix
- Detects issue type (crash, navigation, null safety, etc.)
- **Actually modifies code files**
- Creates fix documentation in `docs/fix-issue-{N}.md`

**Fix patterns:**
- **Crash/Exception**: Adds try-catch blocks
- **Navigation**: Adds lifecycle checks
- **Null Safety**: Adds null checks with defaults

### Phase 4: Build & Install
- Runs `./gradlew clean assembleDebug`
- Installs APK on device
- Verifies installation success

### Phase 5: After Screenshot
- Launches fixed app
- Captures new state
- Saves to `screenshots/issue-{N}/after-fix.png`

### Phase 6: Run Tests
- Executes `./gradlew testDebugUnitTest`
- Parses **actual JUnit XML results**
- Generates coverage report
- Sets `TESTS_PASSED` flag

### Phase 7: Generate Charts
- Creates test result visualizations
- Saves to `automation-results/test-chart-issue-{N}.png`

### Phase 8: Create Report
- Generates markdown report
- Includes screenshots, test results, files changed
- Saves to `screenshots/issue-{N}/fix-report.md`

### Phase 9: Commit & Push
- **Verifies** code changed and tests passed
- Commits only if verification passes
- Pushes to GitHub main branch

### Phase 10: Close Issue
- **Only closes if:**
  - ✅ Code was modified
  - ✅ All tests passed
  - ✅ Build succeeded
- Otherwise: Comments on issue for manual review

---

## Verification Logic

The agent uses strict verification before closing issues:

```bash
# Issue is CLOSED only if:
CODE_CHANGED=true  AND  TESTS_PASSED=true

# Otherwise:
# - Comment added to issue
# - Issue left open for manual review
```

---

## Output Files

After running, check these locations:

### Screenshots
```
screenshots/issue-{N}/
├── before-fix.png       # App state before fix
├── after-fix.png        # App state after fix
└── fix-report.md        # Detailed markdown report
```

### Documentation
```
docs/
└── fix-issue-{N}.md     # Fix documentation with code changes
```

### Test Results
```
automation-results/
└── test-chart-issue-{N}.png  # Visual test results chart
```

### Build Artifacts
```
app/build/
├── test-results/testDebugUnitTest/  # JUnit XML results
└── reports/jacoco/                  # Coverage reports
```

---

## Success Example

```
🤖 COMPLETE AGENT WORKFLOW
============================
Issue: #5
Device: 57111FDCH007MJ

📋 PHASE 1: Fetching Issue from GitHub MCP
✅ Fetched: App crashes on contact click

📸 PHASE 2: Capturing BEFORE Screenshot
✅ Before screenshot captured

🔧 PHASE 3: Analyzing and Applying Fix
   Detected: Crash/Exception issue
   ✅ Applied error handling in ContactsFragment
   Detected: Navigation issue
   ✅ Applied navigation safety in ContactDetailFragment
📄 Created documentation: docs/fix-issue-5.md

📝 Fix Summary:
   - Added try-catch blocks around navigation
   - Added safe navigation checks
   - Added null safety checks for contact data

📁 Files Modified:
   - ContactsFragment.kt
   - ContactDetailFragment.kt

🔨 PHASE 4: Building and Installing
✅ Build successful
✅ Installed

📸 PHASE 5: Capturing AFTER Screenshot
✅ After screenshot captured

🧪 PHASE 6: Running Test Automation
✅ Unit Tests: 15/15 passed
✅ Coverage: 92%

📊 PHASE 7: Generating Test Charts
✅ Test chart generated

📝 PHASE 8: Creating Fix Report
✅ Fix report created

📤 PHASE 9: Publishing to GitHub
✅ Verification passed: Code changed and tests passing
✅ Pushed to GitHub

🎯 PHASE 10: Closing Issue on GitHub
✅ Verification passed: Code changed and tests passing
✅ Issue #5 closed on GitHub

============================================
✨ COMPLETE AGENT WORKFLOW FINISHED
============================================

Summary for Issue #5:
  ✅ Fetched from GitHub MCP
  ✅ Before screenshot captured
  ✅ Fix applied
  ✅ After screenshot captured
  ✅ Tests run (15/15 passed)
  ✅ Results committed and pushed
  ✅ Issue closed

📁 Results Location:
  - Screenshots: screenshots/issue-5/
  - Fix Report: screenshots/issue-5/fix-report.md
  - Test Chart: automation-results/test-chart-issue-5.png
  - Fix Documentation: docs/fix-issue-5.md

🔗 GitHub: https://github.com/kondlada/CodeFixChallenge/issues/5

✨ ALL AUTOMATION COMPLETE - ISSUE RESOLVED!
```

---

## Failure Example (Manual Review Required)

```
🧪 PHASE 6: Running Test Automation
❌ Unit Tests: 12/15 passed, 3 failed
⚠️  Coverage: 85%

📤 PHASE 9: Publishing to GitHub
⚠️  WARNING: No code changes and tests failed
   Skipping commit - fix needs more work

🎯 PHASE 10: Closing Issue on GitHub
❌ Verification failed: Cannot close issue
   Code changed: false
   Tests passed: false

💬 Comment added to issue #5
⚠️  Issue NOT closed - manual review required

============================================
✨ COMPLETE AGENT WORKFLOW FINISHED
============================================

Summary for Issue #5:
  ✅ Fetched from GitHub MCP
  ✅ Before screenshot captured
  ✅ Fix applied
  ✅ After screenshot captured
  ⚠️  Tests run (12/15 passed, 3 failed)
  ⚠️  Commit skipped (verification failed)
  ⚠️  Issue NOT closed (needs review)

⚠️  AUTOMATION COMPLETE - MANUAL REVIEW REQUIRED

Next Steps:
  1. Review the fix documentation
  2. Check test failures if any
  3. Apply additional fixes if needed
  4. Re-run workflow to verify
```

---

## Checking Results

### View Code Changes
```bash
# See what was modified
git diff HEAD~1 -- app/

# View specific file changes
git show HEAD:app/src/main/java/com/ai/codefixchallange/presentation/contacts/ContactsFragment.kt
```

### View Fix Documentation
```bash
# Read the fix documentation
cat docs/fix-issue-5.md

# View fix report
cat screenshots/issue-5/fix-report.md
```

### View Screenshots
```bash
# Open before screenshot
open screenshots/issue-5/before-fix.png

# Open after screenshot
open screenshots/issue-5/after-fix.png
```

### View Test Results
```bash
# Check test output
cat /tmp/agent-workflow/test_results.txt

# View HTML test report
open app/build/reports/tests/testDebugUnitTest/index.html

# View coverage report
open app/build/reports/jacoco/jacocoTestReport/html/index.html
```

### View Test Chart
```bash
# Open visual chart
open automation-results/test-chart-issue-5.png
```

---

## Troubleshooting

### Device Not Found
```bash
# Check device connection
adb devices

# Reconnect device
adb kill-server
adb start-server
adb devices
```

### GitHub CLI Not Authenticated
```bash
# Login to GitHub
gh auth login

# Check status
gh auth status

# If issues persist, use token
gh auth login --with-token < token.txt
```

### Build Failures
```bash
# Clean build
./gradlew clean

# Check Gradle version
./gradlew --version

# Rebuild
./gradlew assembleDebug
```

### Test Failures
```bash
# Run tests manually
./gradlew testDebugUnitTest

# View detailed output
./gradlew testDebugUnitTest --info

# Check specific test
./gradlew test --tests "ContactsViewModelTest"
```

### Permission Issues
```bash
# Make script executable
chmod +x scripts/complete-agent-workflow.sh
chmod +x scripts/test-runner.sh
chmod +x scripts/screenshot-capture.sh
```

---

## Advanced Usage

### Re-running After Manual Fixes

If the agent couldn't fully fix an issue:

1. Review the fix documentation
2. Apply manual code changes
3. Re-run the workflow:

```bash
./scripts/complete-agent-workflow.sh 5 57111FDCH007MJ
```

The workflow is **idempotent** - it safely handles re-runs:
- Skips existing screenshots
- Detects already-applied fixes
- Re-runs tests with new changes
- Only commits new changes

### Testing Without Closing Issues

To test the workflow without closing issues:

1. Comment out the close command in the script, or
2. Don't authenticate GitHub CLI (workflow will skip closing)

### Custom Device ID

```bash
# Use different device
adb devices  # Find your device ID
./scripts/complete-agent-workflow.sh 5 YOUR_DEVICE_ID
```

---

## What Gets Fixed Automatically

The agent can automatically fix:

### ✅ Crash/Exception Issues
- Adds try-catch blocks around navigation
- Adds error handling for fragment operations
- Shows user-friendly error messages

### ✅ Navigation Issues
- Adds lifecycle checks (`isAdded && view != null`)
- Prevents navigation when fragment not attached
- Handles back navigation safely

### ✅ Null Safety Issues
- Adds null checks with default values
- Uses Elvis operator (`?: "default"`)
- Prevents NullPointerExceptions

### ⚠️ Manual Review Required
- Complex business logic issues
- UI/UX improvements
- Performance optimizations
- Database schema changes

---

## Best Practices

1. **Always check device connection** before running
2. **Review fix documentation** even when auto-closed
3. **Run tests locally** before pushing to production
4. **Keep issues descriptive** - helps agent identify patterns
5. **Use re-runs** for complex issues requiring iteration

---

## Files Modified by Agent

The agent may modify these files:

```
app/src/main/java/com/ai/codefixchallange/
├── presentation/
│   ├── contacts/ContactsFragment.kt
│   └── detail/ContactDetailFragment.kt
└── (other files based on issue analysis)
```

All changes are:
- ✅ Committed to git
- ✅ Documented in fix reports
- ✅ Tested before closing issues
- ✅ Reversible via git

---

## Support

For issues with the agent:

1. Check `AGENT_FIXES_APPLIED.md` for recent changes
2. Review `/tmp/agent-workflow/` logs
3. Check GitHub issue comments for error details
4. Review test output in build reports

---

**Last Updated**: March 14, 2026  
**Version**: 2.0 (Fixed - Now applies real code changes)
