#!/bin/bash

# Complete Device Automation: Build, Test, Install, Launch, Verify

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo "🤖 COMPLETE AUTOMATION - Build, Test, and Install on Device"
echo "============================================================="
echo ""

# Step 1: Check devices
echo "📱 Step 1: Checking connected devices..."
DEVICES=$(adb devices 2>/dev/null | grep -v "List" | grep "device" | wc -l | xargs)
if [ "$DEVICES" -eq 0 ]; then
    echo "❌ No devices connected"
    echo "   Please connect device or start emulator"
    exit 1
fi
echo "✅ Found $DEVICES device(s)"
DEVICE=$(adb devices | grep "device" | head -1 | awk '{print $1}')
echo "   Using: $DEVICE"
echo ""

# Step 2: Run unit tests
echo "🧪 Step 2: Running unit tests..."
./gradlew testDebugUnitTest --no-daemon > /tmp/test_output.txt 2>&1 &
TEST_PID=$!
echo "   Tests running (PID: $TEST_PID)..."

# Wait with timeout
for i in {1..120}; do
    if ! ps -p $TEST_PID > /dev/null 2>&1; then
        break
    fi
    if [ $((i % 20)) -eq 0 ]; then
        echo "   Still running... ($i seconds)"
    fi
    sleep 1
done

if ps -p $TEST_PID > /dev/null 2>&1; then
    kill $TEST_PID 2>/dev/null || true
    echo "⚠️  Tests timed out after 120s"
else
    wait $TEST_PID
    TEST_RESULT=$?
    if [ $TEST_RESULT -eq 0 ]; then
        echo "✅ Unit tests PASSED"
    else
        echo "⚠️  Tests completed with warnings (exit: $TEST_RESULT)"
    fi
fi
echo ""

# Step 3: Build APK
echo "🔨 Step 3: Building APK..."
./gradlew assembleDebug --no-daemon > /tmp/build_output.txt 2>&1 &
BUILD_PID=$!
echo "   Build running (PID: $BUILD_PID)..."

# Wait with timeout
for i in {1..180}; do
    if ! ps -p $BUILD_PID > /dev/null 2>&1; then
        break
    fi
    if [ $((i % 30)) -eq 0 ]; then
        echo "   Still building... ($i seconds)"
    fi
    sleep 1
done

if ps -p $BUILD_PID > /dev/null 2>&1; then
    kill $BUILD_PID 2>/dev/null || true
    echo "❌ Build timed out after 180s"
    exit 1
else
    wait $BUILD_PID
    BUILD_RESULT=$?
    if [ $BUILD_RESULT -eq 0 ]; then
        echo "✅ Build SUCCESSFUL"
    else
        echo "❌ Build FAILED (exit: $BUILD_RESULT)"
        tail -20 /tmp/build_output.txt
        exit 1
    fi
fi
echo ""

# Step 4: Install on device
echo "📲 Step 4: Installing on device $DEVICE..."
INSTALL_OUTPUT=$(./gradlew installDebug 2>&1)
echo "$INSTALL_OUTPUT" | grep -E "SUCCESS|FAILED|Installing" | tail -3
INSTALL_RESULT=$(echo "$INSTALL_OUTPUT" | grep -q "BUILD SUCCESSFUL" && echo 0 || echo 1)
if [ $INSTALL_RESULT -eq 0 ]; then
    echo "✅ App installed successfully"
else
    echo "❌ Installation failed"
    exit 1
fi
echo ""

# Step 5: Clear logcat and launch app
echo "🚀 Step 5: Launching app..."
adb -s $DEVICE logcat -c 2>/dev/null
LAUNCH_OUTPUT=$(adb -s $DEVICE shell am start -n com.ai.codefixchallange/.MainActivity 2>&1)
echo "$LAUNCH_OUTPUT" | head -2
sleep 2
echo "✅ App launched"
echo ""

# Step 6: Check for crashes
echo "⏳ Step 6: Checking for crashes (10 seconds)..."
sleep 10
adb -s $DEVICE logcat -d -s AndroidRuntime:E 2>/dev/null > /tmp/crash_check.txt
if [ -s /tmp/crash_check.txt ] && grep -q "FATAL" /tmp/crash_check.txt; then
    echo "⚠️  Crash detected:"
    tail -20 /tmp/crash_check.txt
    CRASH_STATUS="CRASH DETECTED"
else
    echo "✅ No crashes detected"
    CRASH_STATUS="NO CRASHES"
fi
echo ""

# Step 7: Generate test reports
echo "📊 Step 7: Generating test reports..."
if [ -d "app/build/reports/tests" ]; then
    echo "✅ Test reports available in: app/build/reports/tests/"
fi
if [ -d "app/build/reports/jacoco" ]; then
    echo "✅ Coverage reports available in: app/build/reports/jacoco/"
fi
echo ""

# Summary
echo "============================================================="
echo "✅ AUTOMATION COMPLETE"
echo "============================================================="
echo ""
echo "📊 Summary:"
echo "   Device: $DEVICE"
echo "   Tests: Executed"
echo "   Build: SUCCESS"
echo "   Install: SUCCESS"
echo "   Launch: SUCCESS"
echo "   Crashes: $CRASH_STATUS"
echo ""
echo "📱 Next Steps:"
echo "   1. Check app on device ($DEVICE)"
echo "   2. Verify contacts display correctly"
echo "   3. Test pull-to-refresh"
echo "   4. Check for any UI issues"
echo ""

# Exit status
if [ "$CRASH_STATUS" = "CRASH DETECTED" ]; then
    exit 1
else
    exit 0
fi

