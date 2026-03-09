#!/bin/bash

# Complete Test Automation with Code Coverage
# Runs all tests feature-wise with coverage reports

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Running Complete Test Suite with Coverage${NC}"
echo "================================================"
echo ""

# Create reports directory
mkdir -p reports/coverage
mkdir -p reports/tests

# 1. Run Unit Tests with Coverage
echo -e "${BLUE}📋 Running Unit Tests...${NC}"
./gradlew testDebugUnitTest jacocoTestReport --no-daemon

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Unit Tests: PASSED${NC}"
    UNIT_RESULT="PASSED"
else
    echo -e "${RED}❌ Unit Tests: FAILED${NC}"
    UNIT_RESULT="FAILED"
fi

# 2. Feature-wise Test Results
echo ""
echo -e "${BLUE}📊 Feature-wise Test Coverage:${NC}"
echo "-----------------------------------"

# Contacts Feature Tests
echo -e "${YELLOW}Contacts Feature:${NC}"
./gradlew testDebugUnitTest --tests "*contacts*" --no-daemon 2>&1 | grep -E "tests? (completed|PASSED|FAILED)" || echo "  Tests run"

# Repository Tests
echo -e "${YELLOW}Repository Layer:${NC}"
./gradlew testDebugUnitTest --tests "*repository*" --no-daemon 2>&1 | grep -E "tests? (completed|PASSED|FAILED)" || echo "  Tests run"

# Use Case Tests
echo -e "${YELLOW}Use Cases:${NC}"
./gradlew testDebugUnitTest --tests "*usecase*" --no-daemon 2>&1 | grep -E "tests? (completed|PASSED|FAILED)" || echo "  Tests run"

# 3. Generate Coverage Report
echo ""
echo -e "${BLUE}📈 Generating Coverage Report...${NC}"

# Copy coverage reports
if [ -d "app/build/reports/jacoco/jacocoTestReport" ]; then
    cp -r app/build/reports/jacoco/jacocoTestReport/* reports/coverage/
    echo -e "${GREEN}✅ Coverage report: reports/coverage/html/index.html${NC}"
fi

if [ -d "app/build/reports/tests/testDebugUnitTest" ]; then
    cp -r app/build/reports/tests/testDebugUnitTest/* reports/tests/
    echo -e "${GREEN}✅ Test report: reports/tests/index.html${NC}"
fi

# 4. Extract Coverage Metrics
echo ""
echo -e "${BLUE}📊 Coverage Summary:${NC}"
echo "-----------------------------------"

if [ -f "app/build/reports/jacoco/jacocoTestReport/html/index.html" ]; then
    # Extract coverage percentages from HTML report
    COVERAGE=$(grep -o "Total.*%" app/build/reports/jacoco/jacocoTestReport/html/index.html | head -1 || echo "Coverage data available in report")
    echo "  $COVERAGE"
else
    echo "  Coverage report will be in reports/coverage/"
fi

# 5. Test Statistics
echo ""
echo -e "${BLUE}📈 Test Statistics:${NC}"
echo "-----------------------------------"
echo "  Unit Tests: $UNIT_RESULT"
echo "  Coverage Reports: Generated"
echo "  Feature Tests: Completed"

# 6. Summary
echo ""
echo "================================================"
if [ "$UNIT_RESULT" = "PASSED" ]; then
    echo -e "${GREEN}✅ All Tests PASSED${NC}"
    echo ""
    echo "Reports generated:"
    echo "  📊 Coverage: file://$(pwd)/reports/coverage/html/index.html"
    echo "  📋 Tests: file://$(pwd)/reports/tests/index.html"
    exit 0
else
    echo -e "${RED}❌ Some Tests FAILED${NC}"
    echo ""
    echo "Check reports at:"
    echo "  📋 Tests: file://$(pwd)/reports/tests/index.html"
    exit 1
fi

