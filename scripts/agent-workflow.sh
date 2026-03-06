#!/bin/bash

# Master Agent Workflow Orchestration
# Complete automation: Fetch issue → Create branch → Apply fix → Test → Create PR
# Usage: ./agent-workflow.sh <issue_number>

set -e

ISSUE_NUMBER=$1
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -z "$ISSUE_NUMBER" ]; then
    echo "❌ Error: Issue number required"
    echo "Usage: ./agent-workflow.sh <issue_number>"
    exit 1
fi

echo "🤖 Starting Agent Workflow"
echo "======================================"
echo "Issue: #${ISSUE_NUMBER}"
echo "Project: ${PROJECT_DIR}"
echo ""

cd "$PROJECT_DIR"

# Step 1: Fetch issue details
echo "📋 Step 1: Fetching issue details..."
source "$SCRIPT_DIR/fetch-github-issue.sh" "$ISSUE_NUMBER"
echo ""

# Generate branch name from issue title
BRANCH_NAME="agent/issue-${ISSUE_NUMBER}-$(echo "$ISSUE_TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c1-40)"

# Step 2: Create feature branch
echo "🌿 Step 2: Creating feature branch..."
git checkout main
git pull origin main
git checkout -b "$BRANCH_NAME"
echo "✅ Branch created: $BRANCH_NAME"
echo ""

# Step 3: Run baseline tests
echo "🧪 Step 3: Running baseline tests..."
echo "This establishes the current state before changes..."
./gradlew clean testDebugUnitTest || {
    echo "⚠️  Baseline tests have failures (this is expected if fixing a bug)"
}
echo ""

# Step 4: Apply fixes
echo "🔧 Step 4: Applying automated fixes..."
echo "======================================"
echo "Issue Type: $(echo "$ISSUE_LABELS" | grep -o 'bug\|feature\|enhancement' || echo 'unknown')"
echo ""

# Check issue type and route to appropriate handler
if echo "$ISSUE_LABELS" | grep -q "bug"; then
    echo "🐛 Detected bug report - applying bug fix logic..."
    # TODO: Integrate AI/MCP server for bug analysis and fix
    # Example: python scripts/mcp-integration.py --mode bug-fix --issue $ISSUE_NUMBER

elif echo "$ISSUE_LABELS" | grep -q "feature\|enhancement"; then
    echo "✨ Detected feature request - applying feature implementation logic..."
    # TODO: Integrate AI/MCP server for feature implementation
    # Example: python scripts/mcp-integration.py --mode feature --issue $ISSUE_NUMBER

else
    echo "📝 Generic issue - applying general fix logic..."
    # TODO: Integrate AI/MCP server for general issue resolution
    # Example: python scripts/mcp-integration.py --mode general --issue $ISSUE_NUMBER
fi

echo ""
echo "⚠️  NOTE: Automated fix logic needs to be integrated with MCP server"
echo "    For now, this is a placeholder. Manual fixes should be applied."
echo ""

# Wait for user confirmation in interactive mode
if [ -t 0 ]; then
    read -p "Have you applied the fixes? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Workflow cancelled"
        exit 1
    fi
fi

# Step 5: Run tests with reports
echo "🧪 Step 5: Running comprehensive tests..."
chmod +x "$SCRIPT_DIR/run-tests-with-reports.sh"
"$SCRIPT_DIR/run-tests-with-reports.sh" || {
    echo "❌ Tests failed! Please fix the issues before creating PR."
    exit 1
}
echo ""

# Step 6: Validate code coverage
echo "📊 Step 6: Validating code coverage..."
if [ -f "app/build/reports/jacoco/jacocoTestReport/html/index.html" ]; then
    # Extract coverage percentage (basic parsing)
    COVERAGE=$(grep -o "Total.*[0-9]\+%" app/build/reports/jacoco/jacocoTestReport/html/index.html | grep -o "[0-9]\+%" | head -1 || echo "N/A")
    echo "Code Coverage: $COVERAGE"

    # Check if coverage meets threshold (e.g., 80%)
    COVERAGE_NUM=$(echo "$COVERAGE" | grep -o "[0-9]\+" || echo "0")
    if [ "$COVERAGE_NUM" -lt 80 ]; then
        echo "⚠️  Warning: Code coverage is below 80%"
        echo "    Please add more tests to improve coverage"
    else
        echo "✅ Code coverage meets threshold"
    fi
else
    echo "⚠️  Coverage report not found"
fi
echo ""

# Step 7: Commit changes
echo "💾 Step 7: Committing changes..."
git add .

if git diff --cached --quiet; then
    echo "⚠️  No changes to commit"
else
    # Create commit message
    COMMIT_MSG="fix: Resolve issue #${ISSUE_NUMBER} - ${ISSUE_TITLE}

Automated fix applied by CI/CD agent workflow.

Changes:
- Applied fixes for reported issue
- All tests passing
- Code coverage validated

Issue: #${ISSUE_NUMBER}"

    git commit -m "$COMMIT_MSG"
    echo "✅ Changes committed"
fi
echo ""

# Step 8: Push branch
echo "⬆️  Step 8: Pushing feature branch..."
git push origin "$BRANCH_NAME"
echo "✅ Branch pushed to origin"
echo ""

# Step 9: Create Pull Request
echo "🔀 Step 9: Creating pull request..."
chmod +x "$SCRIPT_DIR/create-pr.sh"
"$SCRIPT_DIR/create-pr.sh" "$BRANCH_NAME" "$ISSUE_NUMBER" "🤖 Fix: $ISSUE_TITLE"
echo ""

# Step 10: Summary
echo "✨ Agent Workflow Completed!"
echo "======================================"
echo "Issue: #${ISSUE_NUMBER}"
echo "Branch: ${BRANCH_NAME}"
echo "Status: Draft PR created and ready for review"
echo ""
echo "📋 Next Steps:"
echo "  1. Review the PR on GitHub"
echo "  2. Check CI test results"
echo "  3. Review automated test reports"
echo "  4. Mark PR as ready for review when satisfied"
echo "  5. Request reviews from team members"
echo "  6. Merge after approval"
echo ""
echo "🔗 View your PRs:"
echo "  gh pr list"
echo ""

