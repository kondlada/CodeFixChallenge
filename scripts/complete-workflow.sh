#!/bin/bash

# Complete Agent Workflow with Automated Testing
# This script handles the full lifecycle:
# 1. Fetch GitHub issue
# 2. Analyze and fix the issue
# 3. Run all tests automatically
# 4. Create PR with test results

set -e

ISSUE_NUMBER=$1
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$ISSUE_NUMBER" ]; then
    echo -e "${RED}❌ Error: Issue number required${NC}"
    echo "Usage: ./scripts/agent-workflow.sh <issue_number>"
    echo ""
    echo "Example:"
    echo "  ./scripts/agent-workflow.sh 42"
    echo ""
    echo "This will:"
    echo "  1. Fetch issue #42 from GitHub"
    echo "  2. Analyze and implement fix"
    echo "  3. Run all tests automatically"
    echo "  4. Create PR if tests pass"
    exit 1
fi

echo -e "${BLUE}🤖 Complete Agent Workflow${NC}"
echo "================================"
echo -e "Issue: ${GREEN}#${ISSUE_NUMBER}${NC}"
echo ""

# Step 1: Check prerequisites
echo -e "${BLUE}🔍 Checking prerequisites...${NC}"

# Check for adb
if ! command -v adb &> /dev/null; then
    echo -e "${RED}❌ adb not found${NC}"
    echo "Install Android SDK tools"
    exit 1
fi

# Check for device
DEVICE_COUNT=$(adb devices | grep -v "List" | grep "device" | wc -l | xargs)
if [ "$DEVICE_COUNT" -eq 0 ]; then
    echo -e "${RED}❌ No device connected${NC}"
    echo "Please start an emulator or connect a device"
    exit 1
fi

echo -e "${GREEN}✅ Found $DEVICE_COUNT device(s)${NC}"

# Auto-select device
SELECTED_DEVICE=$(adb devices | grep "emulator" | head -1 | awk '{print $1}')
if [ -z "$SELECTED_DEVICE" ]; then
    SELECTED_DEVICE=$(adb devices | grep -v "List" | grep "device" | head -1 | awk '{print $1}')
fi

export ANDROID_SERIAL="$SELECTED_DEVICE"
echo -e "${GREEN}✅ Using device: $SELECTED_DEVICE${NC}"
echo ""

# Step 2: Fetch and analyze issue
echo -e "${BLUE}📥 Fetching GitHub issue #${ISSUE_NUMBER}...${NC}"

if command -v gh &> /dev/null && gh auth status &> /dev/null; then
    ISSUE_DATA=$(gh issue view $ISSUE_NUMBER --json title,body,number,url 2>/dev/null || echo "")

    if [ -z "$ISSUE_DATA" ]; then
        echo -e "${RED}❌ Could not fetch issue #${ISSUE_NUMBER}${NC}"
        exit 1
    fi

    ISSUE_TITLE=$(echo "$ISSUE_DATA" | grep -o '"title":"[^"]*"' | cut -d'"' -f4)
    ISSUE_URL=$(echo "$ISSUE_DATA" | grep -o '"url":"[^"]*"' | cut -d'"' -f4)

    echo -e "${GREEN}✅ Issue: $ISSUE_TITLE${NC}"
    echo -e "   URL: $ISSUE_URL"
    echo ""
else
    echo -e "${YELLOW}⚠️  gh CLI not available, using API...${NC}"

    REPO_URL=$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/')
    ISSUE_URL="https://api.github.com/repos/$REPO_URL/issues/$ISSUE_NUMBER"

    ISSUE_TITLE=$(curl -s "$ISSUE_URL" | grep -o '"title":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -z "$ISSUE_TITLE" ]; then
        echo -e "${RED}❌ Could not fetch issue${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Issue: $ISSUE_TITLE${NC}"
    echo ""
fi

# Step 3: Run the main agent script
echo -e "${BLUE}🤖 Running intelligent agent...${NC}"
echo ""

cd "$PROJECT_DIR"

# Check if agent script exists
if [ -f "scripts/start-agent.sh" ]; then
    ./scripts/start-agent.sh $ISSUE_NUMBER
    AGENT_RESULT=$?
else
    echo -e "${YELLOW}⚠️  Agent script not found, running manual workflow...${NC}"
    AGENT_RESULT=1
fi

if [ $AGENT_RESULT -eq 0 ]; then
    echo ""
    echo "================================"
    echo -e "${GREEN}✨ Complete workflow successful!${NC}"
    echo ""
    echo "Summary:"
    echo "  ✅ Issue #${ISSUE_NUMBER} analyzed"
    echo "  ✅ Fix implemented"
    echo "  ✅ All tests passed"
    echo "  ✅ App launches successfully"
    echo "  ✅ Pull Request created"
    echo ""
    echo "Next steps:"
    echo "  1. Review PR on GitHub"
    echo "  2. Check test reports"
    echo "  3. Request code review"
    echo "  4. Merge after approval"
    echo ""
else
    echo ""
    echo "================================"
    echo -e "${RED}❌ Workflow had issues${NC}"
    echo ""
    echo "The agent encountered problems. This could mean:"
    echo "  - Issue analysis failed"
    echo "  - Fix implementation had errors"
    echo "  - Tests failed after fix"
    echo "  - App crashes with the fix"
    echo ""
    echo "Check the output above for details."
    echo ""
fi

exit $AGENT_RESULT

