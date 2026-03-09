# 🚀 CI/CD & Agent Workflow Setup Guide

## 📋 Overview

This document describes the complete CI/CD pipeline and automated agent workflow for the Contacts Manager project. The system provides industry-level automation for fetching GitHub issues, applying fixes, running tests, and creating pull requests.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Repository                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Issues     │  │     PRs      │  │   Actions    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                          ↕ ↕ ↕
┌─────────────────────────────────────────────────────────────┐
│              GitHub Actions CI/CD Workflows                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  CI Workflow (ci.yml)                                │   │
│  │  - Build & Unit Tests                                │   │
│  │  - Instrumentation Tests (Multiple API levels)       │   │
│  │  - Code Quality Checks                               │   │
│  │  - Coverage Reports                                  │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  PR Automation Workflow (pr-automation.yml)          │   │
│  │  - Fetch Issue → Create Branch → Apply Fix          │   │
│  │  - Run Tests → Create PR → Attach Reports           │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Code Quality Workflow (code-quality.yml)            │   │
│  │  - ktlint → detekt → Android Lint                    │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          ↕ ↕ ↕
┌─────────────────────────────────────────────────────────────┐
│                   Automation Scripts                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  agent-workflow.sh - Master orchestration            │   │
│  │  fetch-github-issue.sh - Issue retrieval             │   │
│  │  create-pr.sh - PR creation                          │   │
│  │  run-tests-with-reports.sh - Test execution          │   │
│  │  mcp-integration.py - MCP server integration         │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          ↕ ↕ ↕
┌─────────────────────────────────────────────────────────────┐
│                  MCP Server (Optional)                       │
│  - AI-powered code analysis                                  │
│  - Automated fix generation                                  │
│  - Feature implementation                                    │
└─────────────────────────────────────────────────────────────┘
```

## 📁 File Structure

```
.github/
├── workflows/
│   ├── ci.yml                    # Main CI pipeline
│   ├── pr-automation.yml         # Automated PR creation
│   └── code-quality.yml          # Code quality checks
├── ISSUE_TEMPLATE/
│   ├── bug_report.md             # Bug report template
│   └── feature_request.md        # Feature request template
├── PULL_REQUEST_TEMPLATE.md      # PR template
└── CODEOWNERS                    # Auto-assign reviewers

scripts/
├── agent-workflow.sh             # Master workflow orchestrator
├── fetch-github-issue.sh         # Fetch issue from GitHub
├── create-pr.sh                  # Create pull request
├── run-tests-with-reports.sh    # Run tests with reports
└── mcp-integration.py            # MCP server integration

.editorconfig                     # Code style configuration
```

## 🔧 Setup Instructions

### 1. GitHub Repository Settings

#### Enable GitHub Actions
1. Go to repository **Settings** → **Actions** → **General**
2. Under "Actions permissions", select **Allow all actions and reusable workflows**
3. Save changes

#### Configure Branch Protection Rules
1. Go to **Settings** → **Branches**
2. Add rule for `main` branch:
   - ✅ Require pull request reviews before merging (1 approval)
   - ✅ Require status checks to pass before merging
   - Select required checks:
     - `Build & Unit Tests`
     - `Code Quality Checks`
   - ✅ Require branches to be up to date before merging
   - ✅ Include administrators
3. Save changes

#### Create GitHub Personal Access Token (PAT)
1. Go to **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **Generate new token (classic)**
3. Configure token:
   - **Name**: `CI/CD Agent Token`
   - **Expiration**: 90 days (or custom)
   - **Scopes**:
     - ✅ `repo` (Full control of private repositories)
     - ✅ `workflow` (Update GitHub Action workflows)
     - ✅ `read:org` (Read org and team membership)
4. Generate token and **COPY IT** (you won't see it again!)

#### Add Token to Repository Secrets
1. Go to repository **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Name: `GH_TOKEN`
4. Value: Paste your PAT
5. Add secret

### 2. Local Setup

#### Install Required Tools

**macOS:**
```bash
# Install GitHub CLI
brew install gh

# Authenticate GitHub CLI
gh auth login

# Install jq (JSON processor)
brew install jq

# Install Python 3 (if not already installed)
brew install python3
```

**Linux:**
```bash
# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh jq python3 -y

# Authenticate
gh auth login
```

#### Make Scripts Executable
```bash
cd /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange
chmod +x scripts/*.sh
chmod +x generate-reports.sh
```

### 3. CODEOWNERS Configuration

The `.github/CODEOWNERS` file automatically assigns reviewers to PRs based on changed files. Update it with your team members:

```
# Example
* @kondlada

# Add team members for specific areas
/app/src/main/java/com/ai/codefixchallange/presentation/ @kondlada @team-member
/app/src/main/java/com/ai/codefixchallange/domain/ @kondlada @senior-dev
```

## 🤖 Usage

### Option 1: Automated Workflow (Recommended)

Use the master agent workflow script:

```bash
# Fetch issue, apply fix, run tests, create PR
./scripts/agent-workflow.sh <issue_number>

# Example
./scripts/agent-workflow.sh 42
```

**What it does:**
1. ✅ Fetches issue #42 from GitHub
2. ✅ Creates feature branch `agent/issue-42-...`
3. ✅ Runs baseline tests
4. ✅ Applies automated fixes (placeholder - integrate MCP server)
5. ✅ Runs comprehensive tests with coverage
6. ✅ Commits changes
7. ✅ Pushes branch
8. ✅ Creates draft PR
9. ✅ Links PR to issue

### Option 2: GitHub Actions Workflow Dispatch

Trigger automation from GitHub UI:

1. Go to **Actions** tab
2. Select **PR Automation - Agent Workflow**
3. Click **Run workflow**
4. Enter issue number
5. Click **Run workflow**

GitHub Actions will:
- Fetch the issue
- Create branch
- Apply fixes
- Run tests on emulators (API 24, 28, 33)
- Create draft PR with test reports

### Option 3: Manual Step-by-Step

For more control, run individual scripts:

```bash
# 1. Fetch issue details
./scripts/fetch-github-issue.sh 42

# 2. Create feature branch manually
git checkout -b fix/issue-42-description

# 3. Make your changes
# ... edit files ...

# 4. Run tests with reports
./scripts/run-tests-with-reports.sh

# 5. Commit changes
git add .
git commit -m "fix: Resolve issue #42"

# 6. Push branch
git push origin fix/issue-42-description

# 7. Create PR
./scripts/create-pr.sh fix/issue-42-description 42 "Fix: Description"
```

## 📊 Testing & Reports

### Run Tests Locally

**Unit tests only:**
```bash
./gradlew testDebugUnitTest
```

**Unit tests with coverage:**
```bash
./gradlew testDebugUnitTest jacocoTestReport
open app/build/reports/jacoco/jacocoTestReport/html/index.html
```

**All tests with reports:**
```bash
./generate-reports.sh
```

**Tests with emulator management:**
```bash
./scripts/run-tests-with-reports.sh --use-emulator --api-level 33
```

### CI Test Reports

After CI runs, test reports are available as artifacts:
1. Go to **Actions** tab
2. Click on the workflow run
3. Scroll to **Artifacts** section
4. Download reports:
   - `test-results` - Unit test HTML reports
   - `coverage-reports` - JaCoCo coverage reports
   - `lint-reports` - Code quality reports

## 🔍 Code Quality

### ktlint (Kotlin Code Style)

```bash
# Check code style
./gradlew ktlintCheck

# Auto-format code
./gradlew ktlintFormat
```

Configuration: `.editorconfig`

### detekt (Static Analysis)

```bash
# Run static analysis
./gradlew detekt
```

Report: `app/build/reports/detekt/detekt.html`

### Android Lint

```bash
# Run Android Lint
./gradlew lintDebug
```

Report: `app/build/reports/lint-results-debug.html`

## 🔄 Workflow Scenarios

### Scenario 1: Bug Fix

1. **User reports bug** via GitHub issue using bug template
2. **Agent workflow triggered**:
   ```bash
   ./scripts/agent-workflow.sh <issue_number>
   ```
3. **Agent analyzes issue** and determines it's a bug
4. **Fixes applied** (manual or via MCP server)
5. **Tests run** to verify fix
6. **PR created** as draft
7. **Human reviews** PR and approves
8. **CI runs** on PR (tests on multiple API levels)
9. **Merge** after approval and passing CI

### Scenario 2: Feature Request

1. **User requests feature** via GitHub issue using feature template
2. **Agent workflow triggered**
3. **Agent analyzes** and identifies affected layers
4. **Implementation strategy** generated
5. **Feature implemented** (following Clean Architecture)
6. **Tests added** for new feature
7. **Documentation updated** (module docs, skills docs)
8. **PR created** with comprehensive description
9. **Team reviews** architecture and implementation
10. **Merge** after approval

### Scenario 3: Multiple Issues in Batch

```bash
# Process multiple issues
for issue in 42 43 44; do
  ./scripts/agent-workflow.sh $issue
done
```

## 🔐 Security & Permissions

### Repository Permissions

The agent requires:
- ✅ **Read** access to repository code
- ✅ **Write** access to create branches
- ✅ **Write** access to create PRs
- ✅ **Read** access to issues

### Best Practices

1. **Never commit secrets** to repository
2. **Use GitHub Secrets** for tokens and API keys
3. **Review agent-created PRs** before merging
4. **Limit token scope** to minimum required
5. **Rotate tokens** every 90 days
6. **Enable branch protection** to require reviews

## 🎯 Integration with MCP Server

### Current Status

The `scripts/mcp-integration.py` provides a **placeholder** implementation. To integrate with an actual MCP server:

### Option A: REST API Integration

```python
# In mcp-integration.py
import requests

def apply_fix(self) -> bool:
    response = requests.post(
        'https://your-mcp-server.com/api/fix',
        json={
            'issue': self.issue_data,
            'project': 'contacts-manager',
            'language': 'kotlin',
            'framework': 'android'
        },
        headers={'Authorization': f'Bearer {MCP_TOKEN}'}
    )
    
    if response.ok:
        changes = response.json()['changes']
        for file_path, content in changes.items():
            self._write_file(file_path, content)
        return True
    return False
```

### Option B: GitHub Copilot API Integration

```python
# Use GitHub Copilot API for code generation
from github_copilot import CopilotAPI

copilot = CopilotAPI(token=os.getenv('GITHUB_TOKEN'))
suggestions = copilot.get_suggestions(
    context=issue_body,
    files=affected_files
)
```

### Option C: Custom AI Model

```python
# Integrate with custom AI model
from openai import OpenAI

client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
response = client.chat.completions.create(
    model="gpt-4",
    messages=[
        {"role": "system", "content": "You are an Android developer..."},
        {"role": "user", "content": f"Fix this issue: {issue_body}"}
    ]
)
```

## 📈 Monitoring & Observability

### GitHub Actions Monitoring

View workflow status:
```bash
# List recent workflow runs
gh run list

# View specific run
gh run view <run_id>

# Watch real-time logs
gh run watch
```

### Test Coverage Tracking

Coverage is tracked in:
- JaCoCo HTML reports (local and CI)
- PR comments (automated)
- CI artifacts

Target: **≥80% code coverage** for all changes

### Performance Metrics

Track CI performance:
- Build time
- Test execution time
- Code quality check time
- Total pipeline time

Target: **< 30 minutes** for full pipeline

## 🐛 Troubleshooting

### Common Issues

#### 1. GitHub CLI Authentication Failed
```bash
# Re-authenticate
gh auth logout
gh auth login
```

#### 2. Permission Denied on Scripts
```bash
# Make executable
chmod +x scripts/*.sh
```

#### 3. Emulator Won't Start
```bash
# Check Android SDK
echo $ANDROID_HOME

# List available emulators
emulator -list-avds

# Create new emulator
avdmanager create avd -n test_device -k "system-images;android-33;google_apis;x86_64"
```

#### 4. Tests Failing in CI but Passing Locally
- Check API level compatibility
- Review CI logs for environment differences
- Verify all dependencies are in build.gradle.kts

#### 5. PR Creation Failed
```bash
# Check GitHub token
gh auth status

# Verify remote
git remote -v

# Check branch exists on remote
git branch -r
```

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Android Testing Guide](https://developer.android.com/training/testing)
- [JaCoCo Documentation](https://www.jacoco.org/jacoco/trunk/doc/)
- [Clean Architecture Guide](../ARCHITECTURE.md)

## 🎉 Success Metrics

Track these metrics to measure CI/CD effectiveness:

- **Deployment Frequency**: How often code is deployed
- **Lead Time**: Time from commit to production
- **Change Failure Rate**: % of changes causing failures
- **Mean Time to Recovery**: Time to fix failures
- **Code Coverage**: % of code covered by tests
- **Test Pass Rate**: % of tests passing

---

**Need help?** Create an issue with the `question` label or contact the team.

**Want to improve this?** PRs welcome! Follow the PR template and ensure tests pass.

