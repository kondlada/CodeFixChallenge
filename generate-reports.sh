#!/bin/bash

# Test Report Generation Script for Contacts Manager App
# This script runs all tests and generates comprehensive reports

echo "🚀 Starting Test Execution and Report Generation..."
echo "=================================================="

# Navigate to project directory
cd "$(dirname "$0")" || exit

# Clean previous build
echo "🧹 Cleaning previous build..."
./gradlew clean

# Run unit tests with coverage
echo "🧪 Running unit tests with code coverage..."
./gradlew testDebugUnitTest jacocoTestReport

# Run instrumentation tests (if devices/emulators available)
echo "📱 Running instrumentation tests..."
./gradlew createDebugCoverageReport || echo "⚠️  No devices found for instrumentation tests"

# Generate HTML and XML reports
echo "📊 Generating test reports..."

# Create reports directory
REPORTS_DIR="build/reports/custom"
mkdir -p "$REPORTS_DIR"

# Copy JaCoCo HTML report
if [ -d "app/build/reports/jacoco/jacocoTestReport/html" ]; then
    cp -r app/build/reports/jacoco/jacocoTestReport/html "$REPORTS_DIR/coverage"
    echo "✅ Coverage report copied to $REPORTS_DIR/coverage"
fi

# Copy test results
if [ -d "app/build/reports/tests/testDebugUnitTest" ]; then
    cp -r app/build/reports/tests/testDebugUnitTest "$REPORTS_DIR/unit-tests"
    echo "✅ Unit test report copied to $REPORTS_DIR/unit-tests"
fi

# Generate summary
echo ""
echo "📈 Test Summary:"
echo "=================================================="
echo "Unit Tests: Check $REPORTS_DIR/unit-tests/index.html"
echo "Code Coverage: Check $REPORTS_DIR/coverage/index.html"
echo ""
echo "✨ Test execution completed!"
echo "=================================================="

# Open reports in browser (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🌐 Opening reports in browser..."
    open "$REPORTS_DIR/unit-tests/index.html"
    open "$REPORTS_DIR/coverage/index.html"
fi

