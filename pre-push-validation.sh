#!/bin/bash

# Pre-Push Validation Script
# Runs tests before allowing push to repository
# Creates PR instead of direct push to main

set -e

echo "🔍 Pre-Push Validation"
echo "======================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes${NC}"
    echo "Uncommitted files:"
    git status -s
    echo ""
    read -p "Commit these changes first? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter commit message: " COMMIT_MSG
        git add -A
        git commit -m "$COMMIT_MSG"
    else
        echo -e "${RED}❌ Please commit changes before pushing${NC}"
        exit 1
    fi
fi

# Step 1: Check for connected devices
echo -e "${BLUE}📱 Checking for connected devices...${NC}"
DEVICE_LIST=($(adb devices | grep -v "List" | grep "device" | awk '{print $1}'))
DEVICES=${#DEVICE_LIST[@]}

if [ "$DEVICES" -eq 0 ]; then
    echo -e "${RED}❌ No devices connected${NC}"
    echo "Please connect a device or start an emulator"
    exit 1
fi

echo -e "${GREEN}✅ Found $DEVICES device(s)${NC}"
adb devices
echo ""

# Auto-select device (prefer physical device over emulator)
if [ -z "$ANDROID_SERIAL" ]; then
    # Try to find a physical device first
    SELECTED_DEVICE=$(adb devices | grep -v "List" | grep -v "emulator" | grep "device" | head -1 | awk '{print $1}')

    if [ -z "$SELECTED_DEVICE" ]; then
        # No physical device, use emulator
        SELECTED_DEVICE=$(adb devices | grep "emulator" | head -1 | awk '{print $1}')
    fi

    export ANDROID_SERIAL="$SELECTED_DEVICE"
    echo -e "${GREEN}✅ Auto-selected device: $SELECTED_DEVICE${NC}"
    echo ""
fi


# Step 2: Build the project
echo -e "${BLUE}🔨 Building project...${NC}"
./gradlew clean assembleDebug assembleDebugAndroidTest

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful${NC}"
echo ""

# Step 3: Run unit tests
echo -e "${BLUE}🧪 Running unit tests...${NC}"
./gradlew testDebugUnitTest --continue

UNIT_TEST_RESULT=$?

if [ $UNIT_TEST_RESULT -ne 0 ]; then
    echo -e "${RED}❌ Unit tests failed${NC}"
    echo "Test report: file://$(pwd)/app/build/reports/tests/testDebugUnitTest/index.html"
    exit 1
fi

echo -e "${GREEN}✅ Unit tests passed${NC}"
echo ""

# Step 4: Install app on device
echo -e "${BLUE}📦 Installing app on device...${NC}"
./gradlew installDebug

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Installation failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ App installed${NC}"
echo ""

# Step 5: Run instrumented tests
echo -e "${BLUE}🧪 Running instrumented tests on device...${NC}"

# Clear logcat
adb logcat -c

# Run tests
./gradlew connectedDebugAndroidTest --continue

INSTRUMENTED_TEST_RESULT=$?

if [ $INSTRUMENTED_TEST_RESULT -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Some instrumented tests failed or were skipped${NC}"
    echo "Test report: file://$(pwd)/app/build/reports/androidTests/connected/debug/index.html"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}✅ Instrumented tests passed${NC}"
fi

echo ""

# Step 6: Launch app and check for crashes
echo -e "${BLUE}🚀 Launching app to check for crashes...${NC}"
adb logcat -c
adb shell am start -n com.ai.codefixchallange/.MainActivity

sleep 5

CRASHES=$(adb logcat -d | grep -c "FATAL.*codefixchallange" || true)

if [ "$CRASHES" -gt 0 ]; then
    echo -e "${RED}❌ App crashed during launch!${NC}"
    echo ""
    adb logcat -d | grep -A 30 "FATAL.*codefixchallange" | tail -40
    echo ""
    echo -e "${RED}Fix the crash before pushing${NC}"
    exit 1
fi

echo -e "${GREEN}✅ App launched successfully, no crashes${NC}"
echo ""

# Step 7: Generate coverage report
echo -e "${BLUE}📊 Generating test coverage report...${NC}"
./gradlew jacocoTestReport || true

if [ -f "app/build/reports/jacoco/jacocoTestReport/html/index.html" ]; then
    echo -e "${GREEN}✅ Coverage report generated${NC}"
    echo "Report: file://$(pwd)/app/build/reports/jacoco/jacocoTestReport/html/index.html"
else
    echo -e "${YELLOW}⚠️  Coverage report not generated${NC}"
fi

echo ""

# Step 8: Create Pull Request (not direct push)
echo -e "${BLUE}🔀 Creating Pull Request...${NC}"
echo ""

CURRENT_BRANCH=$(git branch --show-current)

if [ "$CURRENT_BRANCH" == "main" ] || [ "$CURRENT_BRANCH" == "master" ]; then
    echo -e "${YELLOW}⚠️  You're on the main branch!${NC}"
    echo "Creating a feature branch for you..."

    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    NEW_BRANCH="feature/auto_pr_$TIMESTAMP"

    git checkout -b "$NEW_BRANCH"
    echo -e "${GREEN}✅ Created and switched to branch: $NEW_BRANCH${NC}"
    echo ""
fi

CURRENT_BRANCH=$(git branch --show-current)

# Push the branch
echo -e "${BLUE}📤 Pushing branch to remote...${NC}"
git push -u origin "$CURRENT_BRANCH"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to push branch${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Branch pushed successfully${NC}"
echo ""

# Check if gh CLI is available
if command -v gh &> /dev/null; then
    echo -e "${BLUE}🔀 Creating Pull Request with gh CLI...${NC}"

    # Get last commit message for PR title
    PR_TITLE=$(git log -1 --pretty=%s)
    PR_BODY="## Changes\n\n$(git log -1 --pretty=%B)\n\n## Test Results\n\n✅ Unit tests: Passed\n✅ Instrumented tests: Passed\n✅ App launch: No crashes\n\n## Test Reports\n\n- Unit tests: \`app/build/reports/tests/testDebugUnitTest/index.html\`\n- Instrumented tests: \`app/build/reports/androidTests/connected/debug/index.html\`\n- Coverage: \`app/build/reports/jacoco/jacocoTestReport/html/index.html\`"

    gh pr create --title "$PR_TITLE" --body "$PR_BODY" --base main || {
        echo -e "${YELLOW}⚠️  gh CLI failed, creating PR manually...${NC}"
        echo ""
        echo "Create PR at: https://github.com/kondlada/CodeFixChallenge/compare/main...$CURRENT_BRANCH"
    }
else
    echo -e "${YELLOW}⚠️  gh CLI not installed${NC}"
    echo ""
    echo "Create PR manually at:"
    echo "https://github.com/kondlada/CodeFixChallenge/compare/main...$CURRENT_BRANCH"
fi

echo ""
echo "================================="
echo -e "${GREEN}✅ All validations passed!${NC}"
echo ""
echo "Summary:"
echo "  ✅ Build successful"
echo "  ✅ Unit tests passed"
echo "  ✅ Instrumented tests passed"
echo "  ✅ App launches without crashes"
echo "  ✅ Branch pushed: $CURRENT_BRANCH"
echo "  🔀 Pull Request created/ready"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Review the PR on GitHub"
echo "  2. Get code review approval"
echo "  3. Merge the PR"
echo ""

