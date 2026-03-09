#!/bin/bash

# Start Agent Workflow Script
# Starts MCP server and runs intelligent agent for complete automation
# Now includes automatic testing and validation

set -e

ISSUE_NUMBER=$1
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MCP_PORT=8000
MCP_LOG="/tmp/mcp-server.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [ -z "$ISSUE_NUMBER" ]; then
    echo -e "${RED}❌ Error: Issue number required${NC}"
    echo "Usage: ./start-agent.sh <issue_number>"
    echo ""
    echo "Example:"
    echo "  ./start-agent.sh 42"
    exit 1
fi

echo -e "${BLUE}🚀 Starting Intelligent Agent Workflow${NC}"
echo "========================================"
echo -e "Issue: ${GREEN}#${ISSUE_NUMBER}${NC}"
echo "Project: ${PROJECT_DIR}"
echo ""

# Step 0: Check for connected devices (required for testing)
echo -e "${BLUE}📱 Checking for connected devices...${NC}"
DEVICE_COUNT=$(adb devices | grep -v "List" | grep "device" | wc -l | xargs)

if [ "$DEVICE_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No device connected${NC}"
    echo "The agent needs a device to run tests."
    echo ""
    echo "Please start an emulator or connect a device, then run again."
    exit 1
fi

echo -e "${GREEN}✅ Found $DEVICE_COUNT device(s)${NC}"
adb devices
echo ""

# Auto-select device (prefer emulator for testing)
SELECTED_DEVICE=$(adb devices | grep "emulator" | head -1 | awk '{print $1}')
if [ -z "$SELECTED_DEVICE" ]; then
    # No emulator, use first available device
    SELECTED_DEVICE=$(adb devices | grep -v "List" | grep "device" | head -1 | awk '{print $1}')
fi

export ANDROID_SERIAL="$SELECTED_DEVICE"
echo -e "${GREEN}✅ Using device: $SELECTED_DEVICE${NC}"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) not installed${NC}"
    echo "Install with: brew install gh"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}⚠️  GitHub CLI not authenticated${NC}"
    echo "Run: gh auth login"
    exit 1
fi

# Setup MCP server environment if needed
if [ ! -d "${PROJECT_DIR}/mcp-server/venv" ]; then
    echo -e "${BLUE}📦 Setting up MCP server environment...${NC}"
    cd "${PROJECT_DIR}/mcp-server"
    python3 -m venv venv
    source venv/bin/activate
    pip install --quiet -r requirements.txt
    deactivate
    echo -e "${GREEN}✅ MCP server environment ready${NC}"
    echo ""
fi

# Setup agent environment if needed
if [ ! -d "${PROJECT_DIR}/agent/venv" ]; then
    echo -e "${BLUE}📦 Setting up agent environment...${NC}"
    cd "${PROJECT_DIR}/agent"
    python3 -m venv venv
    source venv/bin/activate
    pip install --quiet -r requirements.txt
    deactivate
    echo -e "${GREEN}✅ Agent environment ready${NC}"
    echo ""
fi

# Check if MCP server is already running
if curl -s "http://localhost:${MCP_PORT}/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ MCP server already running${NC}"
    MCP_PID=""
else
    # Start MCP server in background
    echo -e "${BLUE}🖥️  Starting MCP server...${NC}"
    cd "${PROJECT_DIR}/mcp-server"
    source venv/bin/activate
    python github_mcp_server.py > "${MCP_LOG}" 2>&1 &
    MCP_PID=$!
    deactivate

    # Wait for server to start
    echo -e "${BLUE}⏳ Waiting for MCP server to start...${NC}"
    MAX_ATTEMPTS=10
    ATTEMPT=0

    while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
        if curl -s "http://localhost:${MCP_PORT}/health" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ MCP server running (PID: $MCP_PID)${NC}"
            break
        fi
        ATTEMPT=$((ATTEMPT + 1))
        sleep 1
        echo -n "."
    done
    echo ""

    if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
        echo -e "${RED}❌ MCP server failed to start${NC}"
        echo "Check logs: $MCP_LOG"
        if [ -n "$MCP_PID" ]; then
            kill $MCP_PID 2>/dev/null || true
        fi
        exit 1
    fi
fi

echo ""

# Cleanup function
cleanup() {
    if [ -n "$MCP_PID" ]; then
        echo ""
        echo -e "${BLUE}🛑 Stopping MCP server...${NC}"
        kill $MCP_PID 2>/dev/null || true
        wait $MCP_PID 2>/dev/null || true
        echo -e "${GREEN}✅ MCP server stopped${NC}"
    fi
}

# Trap to ensure cleanup on script exit
if [ -n "$MCP_PID" ]; then
    trap cleanup EXIT INT TERM
fi

# Run intelligent agent
echo -e "${BLUE}🤖 Starting Intelligent Agent...${NC}"
echo ""

cd "${PROJECT_DIR}/agent"
source venv/bin/activate
python intelligent_agent.py --issue ${ISSUE_NUMBER} --mcp-url "http://localhost:${MCP_PORT}"
AGENT_EXIT_CODE=$?
deactivate

echo ""

if [ $AGENT_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Agent completed successfully!${NC}"
    echo ""

    # Step: Run automated tests and validation
    echo -e "${BLUE}🧪 Running automated tests and validation...${NC}"
    echo "========================================"
    echo ""

    cd "${PROJECT_DIR}"

    # Build the project
    echo -e "${BLUE}🔨 Building project...${NC}"
    ./gradlew clean assembleDebug

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Build failed after agent changes${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Build successful${NC}"
    echo ""

    # Run unit tests
    echo -e "${BLUE}🧪 Running unit tests...${NC}"
    ./gradlew testDebugUnitTest --continue

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Unit tests failed${NC}"
        echo "Test report: file://${PROJECT_DIR}/app/build/reports/tests/testDebugUnitTest/index.html"
        exit 1
    fi
    echo -e "${GREEN}✅ Unit tests passed${NC}"
    echo ""

    # Install app on device
    echo -e "${BLUE}📦 Installing app on device...${NC}"
    ./gradlew installDebug

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Installation failed${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ App installed${NC}"
    echo ""

    # Launch app and check for crashes
    echo -e "${BLUE}🚀 Testing app launch...${NC}"
    adb -s $ANDROID_SERIAL logcat -c
    adb -s $ANDROID_SERIAL shell am start -n com.ai.codefixchallange/.MainActivity

    sleep 5

    CRASHES=$(adb -s $ANDROID_SERIAL logcat -d | grep -c "FATAL.*codefixchallange" || true)

    if [ "$CRASHES" -gt 0 ]; then
        echo -e "${RED}❌ App crashed during launch!${NC}"
        echo ""
        adb -s $ANDROID_SERIAL logcat -d | grep -A 30 "FATAL.*codefixchallange" | tail -40
        echo ""
        echo -e "${RED}Agent's fix caused a crash. Manual intervention needed.${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ App launches successfully, no crashes${NC}"
    echo ""

    # Run instrumented tests if available
    echo -e "${BLUE}🧪 Running instrumented tests...${NC}"
    ./gradlew connectedDebugAndroidTest --continue || {
        echo -e "${YELLOW}⚠️  Some instrumented tests failed or were skipped${NC}"
        echo "Test report: file://${PROJECT_DIR}/app/build/reports/androidTests/connected/debug/index.html"
    }
    echo ""

    # Generate coverage report
    echo -e "${BLUE}📊 Generating coverage report...${NC}"
    ./gradlew jacocoTestReport || true
    echo -e "${GREEN}✅ Coverage report generated${NC}"
    echo ""

    echo "========================================"
    echo -e "${GREEN}✨ All validations passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Review the PR on GitHub"
    echo "  2. Check test reports:"
    echo "     - Unit tests: file://${PROJECT_DIR}/app/build/reports/tests/testDebugUnitTest/index.html"
    echo "     - Coverage: file://${PROJECT_DIR}/app/build/reports/jacoco/jacocoTestReport/html/index.html"
    echo "  3. Mark PR as ready for review"
    echo "  4. Request reviews from team"
    echo "  5. Merge after approval"
else
    echo -e "${RED}❌ Agent workflow failed!${NC}"
    echo "Check the output above for errors"
fi

echo ""
echo "MCP server logs: ${MCP_LOG}"

exit $AGENT_EXIT_CODE

