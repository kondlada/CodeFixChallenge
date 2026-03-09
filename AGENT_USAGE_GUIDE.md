# 🤖 Agent Usage Guide - How to Check for Errors and Fix Issues

## Quick Reference

### Option 1: Run the Full Agent Workflow (Recommended)
```bash
# For a specific GitHub issue:
./scripts/start-agent.sh <issue_number>

# Example:
./scripts/start-agent.sh 42
```

### Option 2: Validate Your Setup First
```bash
# Check if everything is configured correctly:
./scripts/validate-setup.sh
```

### Option 3: Run Tests with Reports
```bash
# Run all tests and generate reports:
./scripts/run-tests-with-reports.sh

# Run with emulator:
./scripts/run-tests-with-reports.sh --use-emulator --api-level 33
```

### Option 4: Manual Build and Error Check
```bash
# Check for compilation errors:
./gradlew build

# Run unit tests:
./gradlew testDebugUnitTest

# Run with coverage:
./gradlew testDebugUnitTest jacocoTestReport
```

---

## Detailed Usage Instructions

### 🎯 Using the Intelligent Agent

The intelligent agent automates the entire workflow from issue to PR:

#### Prerequisites:
1. **GitHub CLI** must be installed:
   ```bash
   brew install gh
   ```

2. **Authenticate with GitHub**:
   ```bash
   gh auth login
   ```

3. **Python 3.8+** for the agent:
   ```bash
   python3 --version
   ```

#### Run the Agent:
```bash
# Navigate to project root
cd /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange

# Run the agent for a specific issue
./scripts/start-agent.sh 42
```

#### What the Agent Does:
1. ✅ Fetches the GitHub issue details
2. ✅ Analyzes the codebase
3. ✅ Creates a feature branch
4. ✅ Implements the fix/feature
5. ✅ Runs tests
6. ✅ Commits changes
7. ✅ Creates a Pull Request
8. ✅ Generates reports

---

### 🔍 Validate Setup

Before running the agent, validate your setup:

```bash
./scripts/validate-setup.sh
```

This checks:
- ✅ All required files exist
- ✅ Scripts are executable
- ✅ Required tools are installed (git, gh, gradle)
- ✅ GitHub workflows are configured
- ✅ Documentation is in place

**Fix any ❌ errors or ⚠️ warnings before proceeding.**

---

### 🧪 Running Tests

#### Basic Test Run:
```bash
# Run all unit tests
./gradlew testDebugUnitTest

# Run all tests (unit + instrumented)
./gradlew test connectedAndroidTest
```

#### With Coverage Reports:
```bash
# Run tests with coverage
./gradlew testDebugUnitTest jacocoTestReport

# View HTML coverage report
open app/build/reports/jacoco/jacocoTestReport/html/index.html
```

#### Using the Test Automation Script:
```bash
# Run comprehensive tests with reports
./scripts/run-tests-with-reports.sh

# With emulator (will create and start one if needed)
./scripts/run-tests-with-reports.sh --use-emulator --api-level 33

# Custom device name
./scripts/run-tests-with-reports.sh --use-emulator --device-name my_test_device
```

---

### 🔧 Manual Error Checking

#### Check for Compilation Errors:
```bash
# Clean build
./gradlew clean

# Build without running tests
./gradlew assembleDebug

# Full build with tests
./gradlew build
```

#### Check for Lint Issues:
```bash
# Run lint checks
./gradlew lint

# View lint report
open app/build/reports/lint-results-debug.html
```

#### Check for Code Quality Issues:
```bash
# Run all checks
./gradlew check

# Run specific checks
./gradlew lintDebug
./gradlew testDebugUnitTest
```

---

### 🐛 Common Issues and Fixes

#### Issue: Build Fails with "Duplicate META-INF files"
**Fix**: Already fixed in your build.gradle.kts with:
```kotlin
packagingOptions {
    resources.excludes.addAll(listOf(
        "META-INF/LICENSE.md",
        "META-INF/LICENSE",
        // ... other exclusions
    ))
}
```

#### Issue: "gradlew command not found"
**Fix**:
```bash
chmod +x gradlew
./gradlew --version
```

#### Issue: Scripts not executable
**Fix**:
```bash
chmod +x scripts/*.sh
```

#### Issue: GitHub CLI not authenticated
**Fix**:
```bash
gh auth login
# Follow the prompts
```

#### Issue: MCP Server won't start
**Fix**:
```bash
# Install Python dependencies
cd mcp-server
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

### 📊 Viewing Reports

After running tests, reports are available at:

- **Test Results**: `app/build/reports/tests/testDebugUnitTest/index.html`
- **Coverage Report**: `app/build/reports/jacoco/jacocoTestReport/html/index.html`
- **Lint Report**: `app/build/reports/lint-results-debug.html`
- **Build Report**: `build/reports/problems/problems-report.html`

Open in browser:
```bash
# Test results
open app/build/reports/tests/testDebugUnitTest/index.html

# Coverage
open app/build/reports/jacoco/jacocoTestReport/html/index.html

# Lint
open app/build/reports/lint-results-debug.html
```

---

### 🎬 Complete Workflow Example

Here's a complete example of using the agent to fix an issue:

```bash
# 1. Validate setup
./scripts/validate-setup.sh

# 2. Create a GitHub issue (or use existing)
# Go to GitHub and create issue #45: "Fix contact sorting"

# 3. Run the agent
./scripts/start-agent.sh 45

# 4. The agent will:
#    - Fetch issue details
#    - Create branch "fix/issue-45-fix-contact-sorting"
#    - Analyze code
#    - Implement fix
#    - Run tests
#    - Commit changes
#    - Create PR

# 5. Review the PR on GitHub
gh pr view

# 6. Check test reports locally
open app/build/reports/jacoco/jacocoTestReport/html/index.html

# 7. If all looks good, merge the PR
gh pr merge
```

---

### 🛠️ Advanced Usage

#### Run Agent Without GitHub Issue (Manual Mode):
```bash
# Run the Python agent directly
cd agent
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python3 intelligent_agent.py --manual --description "Fix sorting bug"
```

#### Run Specific Test Classes:
```bash
# Run specific test
./gradlew test --tests "ContactsViewModelTest"

# Run tests matching pattern
./gradlew test --tests "*ViewModel*"
```

#### Generate Multiple Reports:
```bash
# Run all checks and generate reports
./gradlew clean build jacocoTestReport lint

# Then view all reports
./generate-reports.sh
```

---

### 📝 Logs and Debugging

#### View Agent Logs:
```bash
# MCP Server logs
tail -f /tmp/mcp-server.log

# Agent logs
tail -f /tmp/agent.log
```

#### Enable Debug Mode:
```bash
# For Gradle
./gradlew build --debug

# For Agent (edit start-agent.sh and add):
export LOG_LEVEL=DEBUG
```

---

## Quick Troubleshooting Commands

```bash
# Kill all Gradle daemons
./gradlew --stop

# Clean everything
./gradlew clean
rm -rf ~/.gradle/caches/

# Reset Git state
git reset --hard HEAD
git clean -fd

# Check system dependencies
which java && java -version
which gradle || ./gradlew --version
which gh && gh --version
which python3 && python3 --version

# Verify Gradle wrapper
./gradlew --version

# Test network connectivity
curl -I https://api.github.com
```

---

## Summary

**For most use cases, use:**
```bash
./scripts/start-agent.sh <issue_number>
```

**For quick error checking:**
```bash
./gradlew build
```

**For comprehensive validation:**
```bash
./scripts/validate-setup.sh
./scripts/run-tests-with-reports.sh
```

---

## Need Help?

- Check [QUICK_START.md](QUICK_START.md) for basic setup
- Check [CI_CD_SETUP.md](docs/CI_CD_SETUP.md) for CI/CD details
- Check [ARCHITECTURE.md](ARCHITECTURE.md) for code structure
- Run `./scripts/validate-setup.sh` to diagnose issues


