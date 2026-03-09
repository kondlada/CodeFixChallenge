#!/bin/bash

# Screenshot Capture Script
# Captures before/after screenshots for issue fixes

STAGE=$1      # "before" or "after"
ISSUE_NUM=$2
DEVICE=$3

if [ -z "$STAGE" ] || [ -z "$ISSUE_NUM" ] || [ -z "$DEVICE" ]; then
    echo "Usage: $0 <before|after> <issue_number> <device_id>"
    exit 1
fi

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

SCREENSHOT_DIR="screenshots/issue-$ISSUE_NUM"
mkdir -p "$SCREENSHOT_DIR"

echo "📸 Capturing $STAGE screenshot for issue #$ISSUE_NUM on $DEVICE..."

# Check device connection
if ! adb devices | grep -q "$DEVICE"; then
    echo "❌ Device $DEVICE not connected"
    echo "Available devices:"
    adb devices
    exit 1
fi

# Capture screenshot
adb -s $DEVICE shell screencap -p /sdcard/${STAGE}_fix.png

if [ $? -ne 0 ]; then
    echo "❌ Failed to capture screenshot"
    exit 1
fi

# Pull to local
adb -s $DEVICE pull /sdcard/${STAGE}_fix.png "$SCREENSHOT_DIR/${STAGE}-fix.png" 2>/dev/null

if [ ! -f "$SCREENSHOT_DIR/${STAGE}-fix.png" ]; then
    echo "❌ Failed to pull screenshot"
    exit 1
fi

# Clean up device
adb -s $DEVICE shell rm /sdcard/${STAGE}_fix.png

echo "✅ Screenshot saved: $SCREENSHOT_DIR/${STAGE}-fix.png"

# Get screenshot info
SIZE=$(ls -lh "$SCREENSHOT_DIR/${STAGE}-fix.png" | awk '{print $5}')
echo "   Size: $SIZE"

exit 0

