#!/bin/bash

# Verify GitHub MCP Deployment and Test Results Attachment

echo "🔍 VERIFICATION: GitHub MCP and Test Results"
echo "=============================================="
echo ""

cd "$(dirname "$0")/.."

# Check 1: Verify workflows exist
echo "📋 Step 1: Checking workflow files..."

if [ -f ".github/workflows/github-mcp.yml" ]; then
    echo "  ✅ github-mcp.yml exists"
else
    echo "  ❌ github-mcp.yml MISSING"
    exit 1
fi

if [ -f ".github/workflows/attach-test-results.yml" ]; then
    echo "  ✅ attach-test-results.yml exists"
else
    echo "  ❌ attach-test-results.yml MISSING"
    exit 1
fi

echo ""

# Check 2: Verify workflows are on main branch
echo "📋 Step 2: Checking deployment to main branch..."

CURRENT_BRANCH=$(git branch --show-current)
echo "  Current branch: $CURRENT_BRANCH"

if git show origin/main:.github/workflows/github-mcp.yml >/dev/null 2>&1; then
    echo "  ✅ github-mcp.yml deployed to origin/main"
else
    echo "  ❌ github-mcp.yml NOT on origin/main"
    echo "  Run: git push origin main"
fi

if git show origin/main:.github/workflows/attach-test-results.yml >/dev/null 2>&1; then
    echo "  ✅ attach-test-results.yml deployed to origin/main"
else
    echo "  ⚠️  attach-test-results.yml NOT on origin/main"
    echo "  Run: git push origin main"
fi

echo ""

# Check 3: Verify gh CLI can access workflows
echo "📋 Step 3: Checking GitHub connection..."

if command -v gh &> /dev/null; then
    echo "  ✅ gh CLI installed"

    if gh auth status >/dev/null 2>&1; then
        echo "  ✅ gh CLI authenticated"

        # List workflows
        echo ""
        echo "  Available workflows:"
        gh workflow list 2>/dev/null | head -5 || echo "  Unable to list workflows"
    else
        echo "  ⚠️  gh CLI not authenticated"
        echo "  Run: gh auth login"
    fi
else
    echo "  ⚠️  gh CLI not installed"
    echo "  Install: brew install gh"
fi

echo ""

# Check 4: Verify agent scripts
echo "📋 Step 4: Checking agent scripts..."

if [ -x "scripts/agent-fix-issue.sh" ]; then
    echo "  ✅ agent-fix-issue.sh executable"
else
    echo "  ❌ agent-fix-issue.sh not executable"
    chmod +x scripts/agent-fix-issue.sh
fi

if [ -x "scripts/run-full-automation.sh" ]; then
    echo "  ✅ run-full-automation.sh executable"
else
    echo "  ❌ run-full-automation.sh not executable"
    chmod +x scripts/run-full-automation.sh
fi

echo ""

# Check 5: Test Results Directory
echo "📋 Step 5: Checking test reports setup..."

if [ -d "reports" ]; then
    echo "  ✅ reports/ directory exists"
else
    echo "  ℹ️  reports/ will be created on first test run"
    mkdir -p reports
fi

echo ""

# Summary
echo "=============================================="
echo "📊 VERIFICATION SUMMARY"
echo "=============================================="
echo ""

echo "✅ Workflow Files: Present"
echo "✅ Agent Scripts: Ready"
echo ""

echo "📡 GitHub MCP Server:"
echo "  - Workflow: github-mcp.yml"
echo "  - Triggers: issue opened/labeled"
echo "  - Purpose: Process and structure issue data"
echo ""

echo "📤 Test Results Attachment:"
echo "  - Workflow: attach-test-results.yml"
echo "  - Triggers: PR opened/updated"
echo "  - Attaches: Test results + coverage reports"
echo ""

echo "🤖 Agent Usage:"
echo "  ./scripts/agent-fix-issue.sh <issue_number>"
echo ""

echo "📊 Test Automation:"
echo "  ./scripts/run-full-automation.sh"
echo ""

# Check if on main
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "⚠️  IMPORTANT: You're on branch '$CURRENT_BRANCH'"
    echo "   Workflows only run when deployed to 'main'"
    echo ""
    echo "   To deploy:"
    echo "   1. git checkout main"
    echo "   2. git merge $CURRENT_BRANCH"
    echo "   3. git push origin main"
    echo ""
fi

echo "✅ Verification Complete!"

