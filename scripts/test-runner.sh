#!/bin/bash

# Test Runner - Executes all test suites
# Generates reports and coverage data

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo "🧪 RUNNING TEST AUTOMATION"
echo "=========================="
echo ""

# Clean previous results
rm -rf app/build/test-results 2>/dev/null
rm -rf app/build/reports 2>/dev/null

echo "1️⃣ Running Unit Tests..."
./gradlew testDebugUnitTest --no-daemon 2>&1 | tail -20

UNIT_RESULT=${PIPESTATUS[0]}

if [ $UNIT_RESULT -eq 0 ]; then
    echo "✅ Unit tests PASSED"
else
    echo "⚠️  Unit tests completed with exit code: $UNIT_RESULT"
fi

echo ""

echo "2️⃣ Generating Coverage Report..."
./gradlew jacocoTestReport --no-daemon 2>&1 | tail -10

if [ -d "app/build/reports/jacoco" ]; then
    echo "✅ Coverage report generated"
    echo "   Location: app/build/reports/jacoco/jacocoTestReport/html/index.html"
else
    echo "⚠️  Coverage report not generated"
fi

echo ""

echo "3️⃣ Test Summary:"
echo "=================="

# Parse JUnit XML results
if [ -d "app/build/test-results/testDebugUnitTest" ]; then
    TESTS=$(find app/build/test-results/testDebugUnitTest -name "*.xml" -exec grep -h 'testsuite' {} \; | grep -o 'tests="[0-9]*"' | cut -d'"' -f2 | awk '{s+=$1} END {print s}')
    FAILURES=$(find app/build/test-results/testDebugUnitTest -name "*.xml" -exec grep -h 'testsuite' {} \; | grep -o 'failures="[0-9]*"' | cut -d'"' -f2 | awk '{s+=$1} END {print s}')
    SKIPPED=$(find app/build/test-results/testDebugUnitTest -name "*.xml" -exec grep -h 'testsuite' {} \; | grep -o 'skipped="[0-9]*"' | cut -d'"' -f2 | awk '{s+=$1} END {print s}')

    TESTS=${TESTS:-0}
    FAILURES=${FAILURES:-0}
    SKIPPED=${SKIPPED:-0}
    PASSED=$((TESTS - FAILURES - SKIPPED))

    echo "  Total Tests: $TESTS"
    echo "  Passed: $PASSED"
    echo "  Failed: $FAILURES"
    echo "  Skipped: $SKIPPED"

    if [ $TESTS -gt 0 ]; then
        PASS_RATE=$((PASSED * 100 / TESTS))
        echo "  Pass Rate: $PASS_RATE%"
    fi
fi

echo ""

echo "4️⃣ Coverage Summary:"
echo "====================="

# Parse Jacoco coverage
if [ -f "app/build/reports/jacoco/jacocoTestReport/jacocoTestReport.xml" ]; then
    LINE_COV=$(grep -o 'type="LINE".*covered="[0-9]*".*missed="[0-9]*"' app/build/reports/jacoco/jacocoTestReport/jacocoTestReport.xml | head -1 | grep -o 'covered="[0-9]*"' | cut -d'"' -f2)
    LINE_MISS=$(grep -o 'type="LINE".*covered="[0-9]*".*missed="[0-9]*"' app/build/reports/jacoco/jacocoTestReport/jacocoTestReport.xml | head -1 | grep -o 'missed="[0-9]*"' | cut -d'"' -f2)

    if [ -n "$LINE_COV" ] && [ -n "$LINE_MISS" ]; then
        TOTAL=$((LINE_COV + LINE_MISS))
        if [ $TOTAL -gt 0 ]; then
            COV_PERCENT=$((LINE_COV * 100 / TOTAL))
            echo "  Line Coverage: $COV_PERCENT% ($LINE_COV/$TOTAL lines)"
        fi
    fi
fi

echo ""
echo "✅ Test automation complete"
exit 0

