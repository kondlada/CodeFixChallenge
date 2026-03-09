# 🤖 Agent Commands - Quick Reference

## 📋 Command to Run Agent

### Basic Command (Auto-detect device)
```bash
cd /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange
./scripts/complete-agent-workflow.sh <issue_number>
```

### Full Command (Specify device)
```bash
cd /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange
./scripts/complete-agent-workflow.sh <issue_number> <device_id>
```

---

## 🎯 Step-by-Step Usage

### Step 1: Check for Open Issues

**Option A: Via Browser**
```
Open: https://github.com/kondlada/CodeFixChallenge/issues
```

**Option B: Via Command Line**
```bash
# Check open issues with curl and python
cd /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange

curl -s "https://api.github.com/repos/kondlada/CodeFixChallenge/issues?state=open" | \
python3 -c "
import sys, json
data = json.load(sys.stdin)
issues = [i for i in data if 'pull_request' not in i]
if issues:
    print('📋 Open Issues:')
    for i in issues:
        print(f\"  #{i['number']}: {i['title']}\")
else:
    print('No open issues')
"
```

**Option C: Using GitHub CLI (if installed)**
```bash
gh issue list --repo kondlada/CodeFixChallenge --state open
```

---

### Step 2: Check Connected Device

```bash
adb devices
```

**Expected Output:**
```
List of devices attached
57111FDCH007MJ  device
emulator-5554   device
```

**If no devices:**
- Connect physical device via USB
- Or start an emulator: `emulator -avd <avd_name>`

---

### Step 3: Run Agent to Fix Issue

**Example: Fix Issue #3**
```bash
cd /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange

# Option 1: Auto-detect device
./scripts/complete-agent-workflow.sh 3

# Option 2: Specify device (recommended)
./scripts/complete-agent-workflow.sh 3 57111FDCH007MJ
```

---

## 📊 What the Agent Does

When you run the command, the agent will:

```
Phase 1: 📋 Fetch Issue from GitHub
         - Fetches issue details
         - Analyzes components
         - Determines priority

Phase 2: 📸 Capture BEFORE Screenshot
         - Launches app on device
         - Captures current buggy state
         - Saves to screenshots/issue-{N}/before-fix.png

Phase 3: 🔧 Analyze & Apply Fix
         - Reads issue analysis
         - Generates fix code
         - Applies changes to files

Phase 4: 🔨 Build & Install
         - Builds APK
         - Installs on device

Phase 5: 📸 Capture AFTER Screenshot
         - Relaunches app
         - Captures fixed state
         - Saves to screenshots/issue-{N}/after-fix.png

Phase 6: 🧪 Run Test Automation
         - Runs unit tests
         - Generates coverage report
         - Parses results

Phase 7: 📊 Generate Charts
         - Creates test result pie chart
         - Creates coverage bar chart
         - Saves as PNG

Phase 8: 📝 Create Fix Report
         - Generates markdown report
         - Includes screenshots
         - Includes test results

Phase 9: 📤 Commit & Push to GitHub
         - Stages all changes
         - Commits with detailed message
         - Pushes to main branch

Phase 10: 🎯 Close Issue
          - Closes issue on GitHub
          - Adds detailed comment
          - Links to commit
```

---

## 🔄 Multiple Run Example (for complex issues)

### Run 1: Initial Analysis
```bash
./scripts/complete-agent-workflow.sh 3 57111FDCH007MJ
```

**Output might show:**
```
✅ Issue fetched
✅ Screenshots captured
⚠️  Fix applied (may need review)
⚠️  Tests: 12/15 passed
```

### Manual Review & Adjustment
```bash
# Review the generated fix
vim app/src/main/java/com/ai/codefixchallange/presentation/contacts/ContactsFragment.kt

# Make necessary adjustments
# Save changes
```

### Run 2: Test & Deploy
```bash
./scripts/complete-agent-workflow.sh 3 57111FDCH007MJ
```

**Output:**
```
ℹ️  Screenshots already exist (skipping)
ℹ️  Code already modified (skipping fix generation)
✅ Building updated code
✅ Tests: 15/15 passed
✅ Charts generated
✅ Committed and pushed
✅ Issue closed
```

---

## 🛠️ Prerequisites Check

Before running the agent, verify:

```bash
# 1. Check ADB
adb devices
# Should show at least one device

# 2. Check Python
python3 --version
# Should be Python 3.7+

# 3. Check Git
git status
# Should show you're in the repo

# 4. Check Gradle
./gradlew --version
# Should show Gradle version

# 5. Check scripts are executable
ls -la scripts/complete-agent-workflow.sh
# Should have 'x' permission
```

**If script not executable:**
```bash
chmod +x scripts/complete-agent-workflow.sh
chmod +x scripts/mcp-client.py
chmod +x scripts/screenshot-capture.sh
chmod +x scripts/test-runner.sh
chmod +x scripts/generate-test-charts.py
```

---

## 📍 Current Status Check

### Check Connected Devices
```bash
adb devices
```

### Check Open Issues on GitHub
```bash
# Visit in browser
open https://github.com/kondlada/CodeFixChallenge/issues

# Or use curl
curl -s "https://api.github.com/repos/kondlada/CodeFixChallenge/issues?state=open" | \
python3 -c "import sys, json; print(f\"{len([i for i in json.load(sys.stdin) if 'pull_request' not in i])} open issues\")"
```

### Check Git Status
```bash
cd /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange
git status
git log --oneline -5
```

---

## 🎯 Complete Example Workflow

### Scenario: Fix a new bug reported as Issue #4

```bash
# 1. Navigate to project
cd /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange

# 2. Check devices
adb devices
# Output: 57111FDCH007MJ  device

# 3. Check for open issues (optional)
curl -s "https://api.github.com/repos/kondlada/CodeFixChallenge/issues/4" | \
python3 -c "import sys, json; i=json.load(sys.stdin); print(f'#{i[\"number\"]}: {i[\"title\"]}')"
# Output: #4: Navigation crash on back button

# 4. Run agent to fix issue
./scripts/complete-agent-workflow.sh 4 57111FDCH007MJ

# 5. Wait for completion (typically 5-10 minutes)
# Agent will:
#   - Fetch issue details
#   - Capture before screenshot
#   - Apply fix
#   - Build and install
#   - Capture after screenshot
#   - Run tests
#   - Generate charts
#   - Create report
#   - Push to GitHub
#   - Close issue

# 6. Verify on GitHub
open https://github.com/kondlada/CodeFixChallenge/issues/4
# Should show issue is closed with detailed comment
```

---

## 📋 Quick Reference Card

### Single Command to Fix Issue
```bash
./scripts/complete-agent-workflow.sh <issue_number> [device_id]
```

### Examples
```bash
# Fix issue #3 on connected device
./scripts/complete-agent-workflow.sh 3

# Fix issue #3 on specific device
./scripts/complete-agent-workflow.sh 3 57111FDCH007MJ

# Fix issue #4 on emulator
./scripts/complete-agent-workflow.sh 4 emulator-5554
```

### Check Results
```bash
# View generated screenshots
open screenshots/issue-3/before-fix.png
open screenshots/issue-3/after-fix.png

# View fix report
open screenshots/issue-3/fix-report.md

# View test chart
open automation-results/test-chart-issue-3.png
```

---

## 🔧 Troubleshooting

### Issue: "No devices found"
**Solution:**
```bash
# Check USB debugging enabled on device
adb devices

# If not showing, reconnect device or restart adb
adb kill-server
adb start-server
adb devices
```

### Issue: "Permission denied"
**Solution:**
```bash
chmod +x scripts/*.sh scripts/*.py
```

### Issue: "gh CLI not available"
**Solution:**
```bash
# Install GitHub CLI
brew install gh

# Authenticate
gh auth login
```

### Issue: "matplotlib not found"
**Solution:**
```bash
# Install matplotlib (optional for charts)
pip3 install matplotlib
```

---

## ✅ Success Indicators

After running the agent, you should see:

1. ✅ `screenshots/issue-{N}/before-fix.png` exists
2. ✅ `screenshots/issue-{N}/after-fix.png` exists
3. ✅ `screenshots/issue-{N}/fix-report.md` created
4. ✅ `automation-results/test-chart-issue-{N}.png` generated
5. ✅ New commit on GitHub main branch
6. ✅ Issue closed on GitHub with detailed comment

---

## 🚀 Ready to Use!

**Main Command:**
```bash
cd /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange
./scripts/complete-agent-workflow.sh <issue_number> <device_id>
```

**That's it!** The agent handles everything automatically. 🎉

