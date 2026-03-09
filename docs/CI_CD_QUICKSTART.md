# 🚀 Quick Start: CI/CD Agent Workflow

## TL;DR - Get Started in 5 Minutes

### Prerequisites Check
```bash
# Check if tools are installed
gh --version        # GitHub CLI
jq --version        # JSON processor
python3 --version   # Python 3

# If missing on macOS:
brew install gh jq python3
gh auth login
```

### 🎯 Basic Usage

#### Option 1: Automated Everything (Recommended)
```bash
# One command to rule them all!
./scripts/agent-workflow.sh <issue_number>

# Example: Process issue #42
./scripts/agent-workflow.sh 42
```

This will:
1. ✅ Fetch issue from GitHub
2. ✅ Create feature branch
3. ✅ Run baseline tests
4. ✅ Prompt you to apply fixes
5. ✅ Run comprehensive tests
6. ✅ Create draft PR
7. ✅ Link PR to issue

#### Option 2: Use GitHub Actions
1. Go to your repo → **Actions** tab
2. Click **PR Automation - Agent Workflow**
3. Click **Run workflow**
4. Enter issue number
5. Click **Run workflow** button
6. Wait for automation to complete

#### Option 3: Test Locally First
```bash
# Run tests with reports
./scripts/run-tests-with-reports.sh

# View reports
open build/reports/test-automation/unit-tests/index.html
open build/reports/test-automation/coverage/index.html
```

---

## 📋 GitHub Setup (One-Time)

### Step 1: Create GitHub Token
1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Select scopes: `repo`, `workflow`, `read:org`
4. Copy token (save it securely!)

### Step 2: Add Token to Repository
1. Your repo → Settings → Secrets and variables → Actions
2. New repository secret
3. Name: `GH_TOKEN`
4. Value: paste your token
5. Add secret

### Step 3: Enable Branch Protection
1. Settings → Branches → Add rule
2. Branch name pattern: `main`
3. Enable:
   - ✅ Require pull request reviews (1 approval)
   - ✅ Require status checks (select: Build & Unit Tests)
   - ✅ Require branches to be up to date
4. Save changes

**Done!** 🎉 Your CI/CD is ready.

---

## 🎬 Example Workflow

### Scenario: Fix a Bug

```bash
# 1. Someone reports bug #42 on GitHub

# 2. Run agent workflow
./scripts/agent-workflow.sh 42

# Output:
# 🤖 Starting Agent Workflow
# ======================================
# Issue: #42
# 
# 📋 Step 1: Fetching issue details...
# ✅ Issue fetched: App crashes on empty contact list
# 
# 🌿 Step 2: Creating feature branch...
# ✅ Branch created: agent/issue-42-app-crashes-on-empty-contact-list
# 
# 🧪 Step 3: Running baseline tests...
# ...
# 
# 🔧 Step 4: Applying automated fixes...
# Have you applied the fixes? (y/n)

# 3. Apply your fix in the code editor
#    Then press 'y' and Enter

# 4. Agent continues:
# 🧪 Step 5: Running comprehensive tests...
# ✅ All tests passed
# 
# 📊 Step 6: Validating code coverage...
# Code Coverage: 87%
# ✅ Code coverage meets threshold
# 
# 💾 Step 7: Committing changes...
# ✅ Changes committed
# 
# ⬆️  Step 8: Pushing feature branch...
# ✅ Branch pushed to origin
# 
# 🔀 Step 9: Creating pull request...
# ✅ Draft PR created: #15
# 
# ✨ Agent Workflow Completed!

# 5. Review PR on GitHub
gh pr view 15 --web

# 6. Mark as ready and request reviews
gh pr ready 15
gh pr edit 15 --add-reviewer @teammate

# 7. After approval, merge
gh pr merge 15
```

---

## 🔧 Common Commands

### Test Commands
```bash
# Unit tests only
./gradlew testDebugUnitTest

# With coverage report
./gradlew testDebugUnitTest jacocoTestReport

# All tests with pretty reports
./generate-reports.sh

# Tests on emulator
./scripts/run-tests-with-reports.sh --use-emulator --api-level 33
```

### PR Commands
```bash
# View your PRs
gh pr list

# View specific PR
gh pr view 15

# Open PR in browser
gh pr view 15 --web

# Mark draft as ready
gh pr ready 15

# Add reviewers
gh pr edit 15 --add-reviewer @teammate

# Merge PR
gh pr merge 15
```

### Issue Commands
```bash
# List issues
gh issue list

# View issue details
gh issue view 42

# Create new issue
gh issue create --title "Bug: App crashes" --body "Description..."

# Close issue
gh issue close 42
```

---

## 📊 View Reports

### Local Reports
```bash
# After running tests, open reports:
open app/build/reports/tests/testDebugUnitTest/index.html
open app/build/reports/jacoco/jacocoTestReport/html/index.html
```

### CI Reports
1. Go to **Actions** tab
2. Click on workflow run
3. Scroll to **Artifacts**
4. Download and extract reports
5. Open `index.html` in browser

---

## 🐛 Quick Troubleshooting

### "gh: command not found"
```bash
# Install GitHub CLI
brew install gh
gh auth login
```

### "Permission denied" on scripts
```bash
chmod +x scripts/*.sh
```

### "Tests failed"
```bash
# Check what failed
./gradlew testDebugUnitTest --info

# View report
open app/build/reports/tests/testDebugUnitTest/index.html
```

### "Emulator not starting"
```bash
# Check Android SDK
echo $ANDROID_HOME

# List emulators
emulator -list-avds

# Create one if needed
avdmanager create avd -n test_device -k "system-images;android-33;google_apis;x86_64"
```

---

## 🎯 Next Steps

1. **Read full guide**: [CI_CD_SETUP.md](./CI_CD_SETUP.md)
2. **Integrate MCP server**: Edit `scripts/mcp-integration.py`
3. **Customize workflows**: Edit `.github/workflows/*.yml`
4. **Add team members**: Update `.github/CODEOWNERS`
5. **Monitor CI**: Check Actions tab regularly

---

## 💡 Pro Tips

### Speed Up CI
```bash
# Use Gradle cache in GitHub Actions (already configured)
# Use dependency caching (already configured)
# Run tests in parallel (configured for multiple API levels)
```

### Better PR Descriptions
Use the PR template! It's automatically loaded when you create a PR.

### Automate Everything
```bash
# Create alias in ~/.zshrc
alias fix-issue='~/path/to/scripts/agent-workflow.sh'

# Usage
fix-issue 42
```

### Monitor Everything
```bash
# Watch workflow in real-time
gh run watch

# Get notified when done
gh run watch && say "Tests complete"  # macOS
```

---

## 📚 More Info

- **Full CI/CD Guide**: [docs/CI_CD_SETUP.md](./CI_CD_SETUP.md)
- **Architecture**: [ARCHITECTURE.md](../ARCHITECTURE.md)
- **Contributing**: [PULL_REQUEST_TEMPLATE.md](../.github/PULL_REQUEST_TEMPLATE.md)
- **Documentation Strategy**: [docs/DOCUMENTATION_STRATEGY.md](./DOCUMENTATION_STRATEGY.md)

---

**Questions?** Create an issue with the `question` label.

**Found a bug?** Use the bug report template!

**Want a feature?** Use the feature request template!

