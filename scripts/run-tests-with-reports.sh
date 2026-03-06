#!/bin/bash

# Enhanced Test Automation with Reports
# Supports emulator management and device testing
# Usage: ./run-tests-with-reports.sh [--use-emulator] [--api-level 33]

set -e

# Default configuration
USE_EMULATOR=false
API_LEVEL=33
DEVICE_NAME="test_device"
REPORTS_DIR="build/reports/test-automation"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --use-emulator)
            USE_EMULATOR=true
            shift
            ;;
        --api-level)
            API_LEVEL="$2"
            shift 2
            ;;
        --device-name)
            DEVICE_NAME="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "🚀 Starting Comprehensive Test Automation"
echo "=========================================="
echo "Configuration:"
echo "  Use Emulator: ${USE_EMULATOR}"
echo "  API Level: ${API_LEVEL}"
echo "  Device Name: ${DEVICE_NAME}"
echo ""

# Navigate to project directory
cd "$(dirname "$0")/.." || exit

# Clean previous build
echo "🧹 Cleaning previous build..."
./gradlew clean

# Create reports directory
mkdir -p "$REPORTS_DIR"

# Check for connected devices
echo ""
echo "📱 Checking for connected devices..."
DEVICE_COUNT=$(adb devices | grep -w "device" | wc -l)
echo "Found $DEVICE_COUNT connected device(s)"

# Function to start emulator
start_emulator() {
    echo ""
    echo "🚀 Starting emulator..."

    # Check if emulator exists
    if ! emulator -list-avds | grep -q "$DEVICE_NAME"; then
        echo "⚠️  Emulator '$DEVICE_NAME' not found"
        echo "Available emulators:"
        emulator -list-avds
        echo ""
        echo "Creating emulator with API level $API_LEVEL..."

        # Create emulator (requires Android SDK)
        echo "no" | avdmanager create avd \
            --name "$DEVICE_NAME" \
            --package "system-images;android-${API_LEVEL};google_apis;x86_64" \
            --device "pixel" \
            --force || echo "⚠️  Could not create emulator"
    fi

    # Start emulator in background
    echo "Starting emulator..."
    emulator -avd "$DEVICE_NAME" -no-window -no-audio -no-boot-anim &
    EMULATOR_PID=$!

    # Wait for emulator to boot
    echo "⏳ Waiting for emulator to boot..."
    adb wait-for-device

    # Wait for boot complete
    while [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]; do
        echo "  Waiting for boot to complete..."
        sleep 5
    done

    echo "✅ Emulator ready!"
    sleep 5  # Additional wait for stability
}

# Function to stop emulator
stop_emulator() {
    if [ -n "$EMULATOR_PID" ]; then
        echo ""
        echo "🛑 Stopping emulator..."
        adb -s emulator-5554 emu kill 2>/dev/null || true
        kill $EMULATOR_PID 2>/dev/null || true
        sleep 3
        echo "✅ Emulator stopped"
    fi
}

# Trap to ensure emulator stops on script exit
trap stop_emulator EXIT

# Start emulator if requested and no devices connected
if [ "$USE_EMULATOR" = true ] && [ "$DEVICE_COUNT" -eq 0 ]; then
    start_emulator
fi

# Run unit tests
echo ""
echo "🧪 Running unit tests with code coverage..."
./gradlew testDebugUnitTest jacocoTestReport

# Check for connected devices/emulators for instrumentation tests
DEVICE_COUNT=$(adb devices | grep -w "device" | wc -l)
if [ "$DEVICE_COUNT" -gt 0 ]; then
    echo ""
    echo "📱 Running instrumentation tests on device..."
    ./gradlew connectedDebugAndroidTest createDebugCoverageReport || {
        echo "⚠️  Instrumentation tests failed, continuing..."
    }
else
    echo ""
    echo "⚠️  No devices available for instrumentation tests"
    echo "    Run with --use-emulator to start an emulator"
fi

# Generate reports
echo ""
echo "📊 Generating comprehensive test reports..."

# Copy test results
echo "Copying test results..."
if [ -d "app/build/reports/tests/testDebugUnitTest" ]; then
    cp -r app/build/reports/tests/testDebugUnitTest "$REPORTS_DIR/unit-tests"
    echo "  ✅ Unit test report: $REPORTS_DIR/unit-tests/index.html"
fi

if [ -d "app/build/reports/androidTests/connected" ]; then
    cp -r app/build/reports/androidTests/connected "$REPORTS_DIR/instrumentation-tests"
    echo "  ✅ Instrumentation test report: $REPORTS_DIR/instrumentation-tests/index.html"
fi

# Copy coverage reports
if [ -d "app/build/reports/jacoco/jacocoTestReport/html" ]; then
    cp -r app/build/reports/jacoco/jacocoTestReport/html "$REPORTS_DIR/coverage"
    echo "  ✅ Coverage report: $REPORTS_DIR/coverage/index.html"
fi

if [ -d "app/build/reports/coverage/androidTest/debug" ]; then
    cp -r app/build/reports/coverage/androidTest/debug "$REPORTS_DIR/coverage-instrumentation"
    echo "  ✅ Instrumentation coverage: $REPORTS_DIR/coverage-instrumentation/index.html"
fi

# Generate summary report
echo ""
echo "📈 Generating summary report..."

SUMMARY_FILE="$REPORTS_DIR/summary.txt"
cat > "$SUMMARY_FILE" <<EOF
Test Automation Summary
========================
Generated: $(date)

Configuration:
- API Level: $API_LEVEL
- Used Emulator: $USE_EMULATOR
- Device Count: $DEVICE_COUNT

Reports Available:
EOF

if [ -d "$REPORTS_DIR/unit-tests" ]; then
    echo "- Unit Tests: unit-tests/index.html" >> "$SUMMARY_FILE"
fi

if [ -d "$REPORTS_DIR/instrumentation-tests" ]; then
    echo "- Instrumentation Tests: instrumentation-tests/index.html" >> "$SUMMARY_FILE"
fi

if [ -d "$REPORTS_DIR/coverage" ]; then
    echo "- Code Coverage: coverage/index.html" >> "$SUMMARY_FILE"
fi

echo ""
cat "$SUMMARY_FILE"

echo ""
echo "✨ Test execution completed!"
echo "=========================================="
echo "📁 Reports location: $REPORTS_DIR"
echo ""
echo "To view reports:"
echo "  open $REPORTS_DIR/unit-tests/index.html"
echo "  open $REPORTS_DIR/coverage/index.html"
echo ""

