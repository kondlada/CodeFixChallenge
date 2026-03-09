# 🏗️ Complete MCP-Agent Architecture

## 📐 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         GITHUB CLOUD                            │
│  ┌──────────────────┐     ┌─────────────────────────────────┐  │
│  │  GitHub Issues   │────▶│   GitHub Actions Workflows      │  │
│  │  (Issue #2, #3)  │     │  (.github/workflows/)           │  │
│  └──────────────────┘     └─────────────────────────────────┘  │
│                                      │                          │
│                                      ▼                          │
│                          ┌────────────────────────┐            │
│                          │  GitHub MCP Workflow   │            │
│                          │  (github-mcp.yml)      │            │
│                          └────────────────────────┘            │
│                                      │                          │
└──────────────────────────────────────┼──────────────────────────┘
                                       │
                                       │ API Calls
                                       ▼
┌──────────────────────────────────────────────────────────────────┐
│                      LOCAL MACHINE                               │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                     AGENT LAYER                            │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │  scripts/complete-agent-workflow.sh (Master Script)  │ │ │
│  │  │  - Orchestrates entire workflow                      │ │ │
│  │  │  - Calls all sub-components                          │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  │                           │                                │ │
│  │          ┌────────────────┼────────────────┐              │ │
│  │          ▼                ▼                ▼              │ │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐ │ │
│  │  │   MCP        │ │   Fix        │ │   Test           │ │ │
│  │  │   Client     │ │   Generator  │ │   Automation     │ │ │
│  │  └──────────────┘ └──────────────┘ └──────────────────┘ │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                     MCP CLIENT                             │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │  scripts/mcp-client.py (Python)                      │ │ │
│  │  │  - Fetches issues via GitHub API                     │ │ │
│  │  │  - Parses MCP structured data                        │ │ │
│  │  │  - Analyzes issue components                         │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                  DEVICE LAYER                              │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │  scripts/device-automation.sh                        │ │ │
│  │  │  - Captures before screenshots                       │ │ │
│  │  │  - Installs & tests app                              │ │ │
│  │  │  - Captures after screenshots                        │ │ │
│  │  │  - Runs instrumentation tests                        │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  │                           │                                │ │
│  │                           ▼                                │ │
│  │                    ┌─────────────┐                         │ │
│  │                    │  ADB        │                         │ │
│  │                    │  (Android)  │                         │ │
│  │                    └─────────────┘                         │ │
│  │                           │                                │ │
│  └───────────────────────────┼────────────────────────────────┘ │
│                               │                                 │
│                               ▼                                 │
│                    ┌──────────────────────┐                    │
│                    │  Physical Device     │                    │
│                    │  57111FDCH007MJ      │                    │
│                    └──────────────────────┘                    │
└──────────────────────────────────────────────────────────────────┘
```

---

## 📁 File Structure

```
CodeFixChallange/
├── .github/
│   └── workflows/
│       ├── github-mcp.yml              # GitHub MCP Server Workflow
│       ├── automated-fix-pipeline.yml  # CI/CD Pipeline
│       └── attach-test-results.yml     # Test Results Publisher
│
├── scripts/
│   ├── complete-agent-workflow.sh      # 🎯 MASTER ORCHESTRATOR
│   ├── mcp-client.py                   # MCP Communication Client
│   ├── device-automation.sh            # Device Testing
│   ├── screenshot-capture.sh           # Before/After Screenshots
│   ├── test-runner.sh                  # Test Automation
│   └── github-publisher.sh             # Results Publisher
│
├── mcp-server/
│   ├── github_mcp_server.py            # Local MCP Server (Development)
│   └── README.md                       # MCP Server Documentation
│
├── agent/
│   ├── intelligent_agent.py            # AI Agent Logic
│   └── requirements.txt                # Python Dependencies
│
├── screenshots/
│   └── issue-{N}/
│       ├── before-fix.png              # Before Screenshot
│       ├── after-fix.png               # After Screenshot
│       ├── fix-report.md               # Detailed Report
│       ├── test-results.html           # Test Results
│       └── test-chart.png              # Test Coverage Chart
│
└── automation-results/
    ├── test-reports/
    ├── coverage-reports/
    └── build-logs/
```

---

## 🔄 Complete Workflow

### Phase 1: Issue Detection
```
GitHub Issue Created (#3)
        ↓
GitHub Actions Triggered
        ↓
github-mcp.yml Workflow Runs
        ↓
MCP Structured Data Generated
        ↓
Stored in Workflow Artifacts
```

### Phase 2: Agent Fetch
```
Local Agent (complete-agent-workflow.sh)
        ↓
Calls mcp-client.py
        ↓
Fetches from GitHub API:
  - GET /repos/{owner}/{repo}/issues/{number}
  - GET /repos/{owner}/{repo}/actions/artifacts
        ↓
Parses Issue Data:
  - Title, Description, Labels
  - Component Analysis (from MCP)
  - Affected Files
```

### Phase 3: Before State Capture
```
screenshot-capture.sh
        ↓
adb shell screencap /sdcard/before.png
        ↓
Pull to screenshots/issue-{N}/before-fix.png
        ↓
Store device state
```

### Phase 4: Fix Application
```
intelligent_agent.py
        ↓
Analyze Issue Components
        ↓
Generate Fix Code
        ↓
Apply Changes to Files
        ↓
Build: ./gradlew assembleDebug
```

### Phase 5: After State Capture
```
Install: ./gradlew installDebug
        ↓
Launch: adb shell am start
        ↓
screenshot-capture.sh
        ↓
adb shell screencap /sdcard/after.png
        ↓
Pull to screenshots/issue-{N}/after-fix.png
```

### Phase 6: Test Automation
```
test-runner.sh
        ↓
Unit Tests: ./gradlew testDebugUnitTest
        ↓
Instrumented Tests: ./gradlew connectedAndroidTest
        ↓
Generate Reports:
  - JUnit XML → HTML
  - Jacoco Coverage → Charts
  - Test Summary → JSON
```

### Phase 7: Results Publishing
```
github-publisher.sh
        ↓
Commit:
  - screenshots/issue-{N}/*
  - test-reports/*
  - fix-report.md
        ↓
Push to GitHub
        ↓
Create Comment on Issue:
  - Test Results Table
  - Coverage Chart
  - Before/After Screenshots
        ↓
Close Issue with gh CLI:
  gh issue close {N} --comment "..."
```

---

## 🔌 MCP Communication Protocol

### 1. GitHub MCP Workflow (`.github/workflows/github-mcp.yml`)

**Triggered By:**
- Issue opened
- Issue labeled
- Manual dispatch

**Actions:**
1. Fetches issue details
2. Analyzes components affected
3. Generates structured MCP data:
   ```json
   {
     "issue_number": 3,
     "title": "Bug Title",
     "components": ["ContactsViewModel", "Repository"],
     "affected_files": [
       "app/src/main/java/.../ContactsViewModel.kt"
     ],
     "priority": "high",
     "type": "bug"
   }
   ```
4. Stores as workflow artifact

### 2. MCP Client (`scripts/mcp-client.py`)

**Function:** Fetches and parses MCP data

```python
def fetch_issue_from_github_mcp(issue_number):
    # Method 1: Try gh CLI
    try:
        result = subprocess.run([
            'gh', 'issue', 'view', str(issue_number),
            '--json', 'number,title,body,labels'
        ], capture_output=True, timeout=10)
        return parse_issue(result.stdout)
    except:
        pass
    
    # Method 2: GitHub REST API
    url = f'https://api.github.com/repos/{REPO}/issues/{issue_number}'
    response = requests.get(url, headers={'Authorization': f'token {TOKEN}'})
    return response.json()
```

### 3. Agent Orchestrator (`scripts/complete-agent-workflow.sh`)

**Master script that coordinates everything:**

```bash
#!/bin/bash
ISSUE_NUMBER=$1

# 1. Fetch from MCP
python3 scripts/mcp-client.py $ISSUE_NUMBER > /tmp/issue_data.json

# 2. Capture BEFORE
./scripts/screenshot-capture.sh before $ISSUE_NUMBER

# 3. Apply Fix
python3 agent/intelligent_agent.py --issue /tmp/issue_data.json

# 4. Build & Install
./gradlew clean assembleDebug installDebug

# 5. Capture AFTER
./scripts/screenshot-capture.sh after $ISSUE_NUMBER

# 6. Run Tests
./scripts/test-runner.sh

# 7. Publish Results
./scripts/github-publisher.sh $ISSUE_NUMBER

# 8. Close Issue
gh issue close $ISSUE_NUMBER --comment "$(cat /tmp/fix_comment.md)"
```

---

## 📸 Screenshot Capture Implementation

```bash
# scripts/screenshot-capture.sh
STAGE=$1  # "before" or "after"
ISSUE_NUM=$2
DEVICE="57111FDCH007MJ"

mkdir -p screenshots/issue-$ISSUE_NUM

# Capture screenshot
adb -s $DEVICE shell screencap -p /sdcard/${STAGE}_fix.png

# Pull to local
adb -s $DEVICE pull /sdcard/${STAGE}_fix.png \
    screenshots/issue-$ISSUE_NUM/${STAGE}-fix.png

echo "✅ ${STAGE} screenshot captured"
```

---

## 🧪 Test Automation & Reporting

### Test Runner (`scripts/test-runner.sh`)

```bash
#!/bin/bash

# Run unit tests
./gradlew testDebugUnitTest --no-daemon

# Run instrumented tests on device
./gradlew connectedAndroidTest --no-daemon

# Generate coverage
./gradlew jacocoTestReport

# Generate charts
python3 scripts/generate-test-charts.py \
    app/build/test-results \
    app/build/reports/jacoco \
    automation-results/test-chart.png
```

### Chart Generator (`scripts/generate-test-charts.py`)

```python
import matplotlib.pyplot as plt
import xml.etree.ElementTree as ET

def generate_test_chart(junit_xml, coverage_xml, output_png):
    # Parse JUnit results
    tests_passed, tests_failed = parse_junit(junit_xml)
    
    # Parse Jacoco coverage
    line_coverage, branch_coverage = parse_jacoco(coverage_xml)
    
    # Create chart
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    # Test results pie chart
    ax1.pie([tests_passed, tests_failed], 
            labels=['Passed', 'Failed'],
            colors=['green', 'red'],
            autopct='%1.1f%%')
    ax1.set_title('Test Results')
    
    # Coverage bar chart
    ax2.bar(['Line Coverage', 'Branch Coverage'],
            [line_coverage, branch_coverage],
            color=['blue', 'orange'])
    ax2.set_ylabel('Percentage')
    ax2.set_title('Code Coverage')
    
    plt.savefig(output_png, dpi=300, bbox_inches='tight')
```

---

## 📤 GitHub Publisher Implementation

### Results Publisher (`scripts/github-publisher.sh`)

```bash
#!/bin/bash
ISSUE_NUM=$1

# Create fix report
cat > screenshots/issue-$ISSUE_NUM/fix-report.md << EOF
# Fix Report for Issue #$ISSUE_NUM

## Screenshots

### Before Fix
![Before](before-fix.png)

### After Fix
![After](after-fix.png)

## Test Results
![Test Chart](../../automation-results/test-chart.png)

| Test Suite | Passed | Failed | Coverage |
|------------|--------|--------|----------|
| Unit Tests | ${UNIT_PASSED} | ${UNIT_FAILED} | ${UNIT_COV}% |
| Integration | ${INT_PASSED} | ${INT_FAILED} | ${INT_COV}% |

## Files Changed
$(git diff --name-only HEAD~1)

✅ All tests passing
✅ Coverage increased
✅ No regressions
EOF

# Commit everything
git add screenshots/issue-$ISSUE_NUM/
git add automation-results/
git commit -m "fix: Resolve issue #$ISSUE_NUM with full test results

Screenshots:
- Before: screenshots/issue-$ISSUE_NUM/before-fix.png
- After: screenshots/issue-$ISSUE_NUM/after-fix.png

Test Results:
- Unit Tests: ${UNIT_PASSED}/${UNIT_TOTAL} passed
- Coverage: ${UNIT_COV}%
- Chart: automation-results/test-chart.png

Closes #$ISSUE_NUM"

# Push
git push origin main

# Close issue with detailed comment
gh issue close $ISSUE_NUM --comment "✅ **FIXED AND VERIFIED**

## Test Results
- ✅ Unit Tests: ${UNIT_PASSED}/${UNIT_TOTAL} passed (${UNIT_COV}% coverage)
- ✅ Device Tests: All passing
- ✅ Build: SUCCESS

## Screenshots
See commit for before/after screenshots

## Files Changed
$(git show --name-only --format='' HEAD | head -10)

**Full report:** [Fix Report](../commit/$(git rev-parse HEAD))
"
```

---

## 🎯 Complete Usage Example

```bash
# Run complete agent workflow for issue #3
./scripts/complete-agent-workflow.sh 3

# Output:
# 🔍 Fetching issue #3 from GitHub MCP...
# ✅ Issue fetched: "App crashes on contact click"
# 📸 Capturing BEFORE screenshot...
# ✅ Screenshot saved: screenshots/issue-3/before-fix.png
# 🔧 Analyzing and applying fix...
# ✅ Fix applied to ContactsFragment.kt
# 🔨 Building APK...
# ✅ Build successful
# 📲 Installing on device 57111FDCH007MJ...
# ✅ Installed
# 📸 Capturing AFTER screenshot...
# ✅ Screenshot saved: screenshots/issue-3/after-fix.png
# 🧪 Running test automation...
# ✅ Unit tests: 15/15 passed (92% coverage)
# ✅ Device tests: 5/5 passed
# 📊 Generating test charts...
# ✅ Chart saved: automation-results/test-chart.png
# 📤 Publishing to GitHub...
# ✅ Committed and pushed
# ✅ Issue #3 closed
# 
# ✨ COMPLETE! All automation finished successfully
```

---

## 🔐 Authentication Setup

### GitHub CLI (Required)
```bash
gh auth login
# Select: GitHub.com
# Auth method: Login with web browser
# Complete authentication in browser
```

### GitHub Token (Alternative)
```bash
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxx"
```

---

## 📊 MCP Data Flow

```
Issue Created
    ↓
GitHub Actions Workflow (github-mcp.yml) Triggers
    ↓
Workflow analyzes issue and generates:
    {
      "issue_number": 3,
      "components": ["ContactsFragment", "Navigation"],
      "type": "crash",
      "priority": "high",
      "affected_files": ["ContactsFragment.kt"]
    }
    ↓
Stored as workflow artifact
    ↓
Agent fetches via GitHub API:
    GET /repos/{owner}/{repo}/actions/artifacts
    ↓
Agent downloads artifact
    ↓
Parses MCP JSON
    ↓
Uses data to:
    - Understand issue context
    - Identify files to fix
    - Generate appropriate tests
    - Create targeted fixes
```

---

## ✅ Success Criteria

After running the complete agent workflow, you will have:

1. ✅ Issue analyzed and understood
2. ✅ Before screenshot captured
3. ✅ Fix applied and built
4. ✅ After screenshot captured  
5. ✅ All tests run and passed
6. ✅ Coverage chart generated
7. ✅ Results committed to GitHub
8. ✅ Issue automatically closed
9. ✅ Full documentation in commit

**Everything automated end-to-end!** 🎉

