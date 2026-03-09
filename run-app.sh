 #!/bin/bash

# Quick App Launch Script
# This helps you run the app on your emulator

set -e

echo "🚀 CodeFixChallenge App Launcher"
echo "================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo -e "${RED}❌ adb not found. Please install Android SDK${NC}"
    exit 1
fi

# Check for connected devices
echo -e "${BLUE}📱 Checking for connected devices...${NC}"
DEVICE_LIST=($(adb devices | grep -v "List" | grep "device" | awk '{print $1}'))
DEVICES=${#DEVICE_LIST[@]}

if [ $DEVICES -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No emulator or device connected${NC}"
    echo ""
    echo "Please do ONE of the following:"
    echo ""
    echo "Option 1: Start emulator from Android Studio"
    echo "  - Open Android Studio"
    echo "  - Click Device Manager (phone icon)"
    echo "  - Click Play button next to an emulator"
    echo "  - Wait for it to boot (30-60 seconds)"
    echo "  - Then run this script again"
    echo ""
    echo "Option 2: Start from terminal"
    echo "  - Run: emulator -list-avds"
    echo "  - Copy an AVD name"
    echo "  - Run: emulator -avd <name> &"
    echo "  - Wait for boot"
    echo "  - Then run this script again"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Found $DEVICES device(s)${NC}"
adb devices
echo ""

# Select device if multiple
if [ $DEVICES -gt 1 ]; then
    echo -e "${YELLOW}Multiple devices found. Select one:${NC}"
    for i in "${!DEVICE_LIST[@]}"; do
        DEVICE_NAME="${DEVICE_LIST[$i]}"
        if [[ $DEVICE_NAME == emulator-* ]]; then
            echo "  $((i+1)). $DEVICE_NAME (Emulator)"
        else
            echo "  $((i+1)). $DEVICE_NAME (Physical Device)"
        fi
    done
    echo ""
    read -p "Enter device number (1-$DEVICES) [default: 1]: " DEVICE_CHOICE
    DEVICE_CHOICE=${DEVICE_CHOICE:-1}

    if [ "$DEVICE_CHOICE" -lt 1 ] || [ "$DEVICE_CHOICE" -gt "$DEVICES" ]; then
        echo -e "${RED}❌ Invalid choice${NC}"
        exit 1
    fi

    SELECTED_DEVICE="${DEVICE_LIST[$((DEVICE_CHOICE-1))]}"
    export ANDROID_SERIAL="$SELECTED_DEVICE"
    echo -e "${GREEN}✅ Selected: $SELECTED_DEVICE${NC}"
    echo ""
elif [ $DEVICES -eq 1 ]; then
    SELECTED_DEVICE="${DEVICE_LIST[0]}"
    export ANDROID_SERIAL="$SELECTED_DEVICE"
    echo -e "${GREEN}✅ Using: $SELECTED_DEVICE${NC}"
    echo ""
fi

# Build the app
echo -e "${BLUE}🔨 Building the app...${NC}"
./gradlew assembleDebug

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful${NC}"
echo ""

# Install the app
echo -e "${BLUE}📦 Installing app...${NC}"
./gradlew installDebug

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Installation failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ App installed${NC}"
echo ""

# Launch the app
echo -e "${BLUE}🚀 Launching app...${NC}"
adb shell am start -n com.ai.codefixchallange/.MainActivity

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to launch app${NC}"
    exit 1
fi

echo -e "${GREEN}✅ App launched!${NC}"
echo ""

# Wait a bit and check for crashes
echo -e "${BLUE}🔍 Checking for crashes...${NC}"
sleep 3

CRASHES=$(adb logcat -d | grep -c "FATAL.*codefixchallange" || true)

if [ $CRASHES -gt 0 ]; then
    echo -e "${RED}❌ App crashed! Getting crash log...${NC}"
    echo ""
    adb logcat -d | grep -A 30 "FATAL.*codefixchallange" | tail -40
    echo ""
    echo -e "${YELLOW}💡 Tip: Share the above crash log for analysis${NC}"
    exit 1
else
    echo -e "${GREEN}✅ No crashes detected!${NC}"
    echo -e "${GREEN}🎉 App is running successfully!${NC}"
    echo ""
    echo "To monitor logs in real-time, run:"
    echo "  adb logcat | grep codefixchallange"
fi

echo ""
echo "================================="
echo -e "${GREEN}✅ Done!${NC}"

