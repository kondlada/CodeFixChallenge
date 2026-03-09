#!/bin/bash

# Simple Device Automation - No Hanging

echo "🤖 Simple Device Automation"
echo "============================"
echo ""

cd "$(dirname "$0")/.."

# Check device
echo "📱 Checking device..."
DEVICE=$(adb devices | grep "device" | grep -v "List" | head -1 | awk '{print $1}')
if [ -z "$DEVICE" ]; then
    echo "❌ No device found"
    exit 1
fi
echo "✅ Device: $DEVICE"
echo ""

# Build
echo "🔨 Building APK (this may take a few minutes)..."
./gradlew assembleDebug --no-daemon > /tmp/build.log 2>&1 &
BUILD_PID=$!

# Show progress
for i in {1..180}; do
    if ! ps -p $BUILD_PID > /dev/null 2>&1; then
        break
    fi
    if [ $((i % 30)) -eq 0 ]; then
        echo "   Still building... ($i seconds)"
    fi
    sleep 1
done

wait $BUILD_PID
BUILD_EXIT=$?

if [ $BUILD_EXIT -ne 0 ]; then
    echo "❌ Build failed"
    tail -20 /tmp/build.log
    exit 1
fi
echo "✅ Build successful"
echo ""

# Install
echo "📲 Installing..."
./gradlew installDebug > /tmp/install.log 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Installed"
else
    echo "❌ Install failed"
    cat /tmp/install.log
    exit 1
fi
echo ""

# Launch
echo "🚀 Launching app..."
adb -s $DEVICE logcat -c 2>/dev/null
adb -s $DEVICE shell am start -n com.ai.codefixchallange/.MainActivity > /tmp/launch.log 2>&1
echo "✅ App launched"
echo ""

# Check crashes
echo "⏳ Checking for crashes (10 seconds)..."
sleep 10
adb -s $DEVICE logcat -d -s AndroidRuntime:E 2>/dev/null | grep "FATAL" > /tmp/crashes.txt
if [ -s /tmp/crashes.txt ]; then
    echo "⚠️  Crash detected:"
    head -10 /tmp/crashes.txt
else
    echo "✅ No crashes"
fi
echo ""

echo "✅ Done! Check app on $DEVICE"

