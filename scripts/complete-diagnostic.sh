#!/bin/bash

# Complete diagnostic and fix verification

echo "🔍 COMPLETE DIAGNOSTIC AND VERIFICATION"
echo "========================================"
echo ""

DEVICE="57111FDCH007MJ"
PACKAGE="com.ai.codefixchallange"

# 1. Check app installation
echo "1️⃣ Checking app installation..."
if adb -s $DEVICE shell pm list packages | grep -q $PACKAGE; then
    echo "✅ App is installed"
    APP_PATH=$(adb -s $DEVICE shell pm path $PACKAGE | cut -d: -f2)
    echo "   Path: $APP_PATH"
else
    echo "❌ App NOT installed"
    exit 1
fi
echo ""

# 2. Check permission
echo "2️⃣ Checking READ_CONTACTS permission..."
PERM=$(adb -s $DEVICE shell dumpsys package $PACKAGE | grep "android.permission.READ_CONTACTS" | grep "granted=true")
if [ -n "$PERM" ]; then
    echo "✅ Permission GRANTED"
else
    echo "⚠️  Permission NOT granted - granting now..."
    adb -s $DEVICE shell pm grant $PACKAGE android.permission.READ_CONTACTS
    echo "✅ Permission granted"
fi
echo ""

# 3. Clear app data for fresh start
echo "3️⃣ Clearing app data for fresh start..."
adb -s $DEVICE shell pm clear $PACKAGE
echo "✅ App data cleared"
echo ""

# 4. Re-grant permission after clear
echo "4️⃣ Re-granting permission after clear..."
adb -s $DEVICE shell pm grant $PACKAGE android.permission.READ_CONTACTS
echo "✅ Permission re-granted"
echo ""

# 5. Launch app
echo "5️⃣ Launching app..."
adb -s $DEVICE logcat -c
adb -s $DEVICE shell am start -n $PACKAGE/.MainActivity
sleep 5
echo "✅ App launched"
echo ""

# 6. Check for crashes
echo "6️⃣ Checking for crashes..."
CRASH=$(adb -s $DEVICE logcat -d | grep "FATAL EXCEPTION" | head -5)
if [ -n "$CRASH" ]; then
    echo "❌ CRASH DETECTED:"
    echo "$CRASH"
    echo ""
    echo "Full crash log:"
    adb -s $DEVICE logcat -d | grep -A 30 "FATAL EXCEPTION" | head -50
    exit 1
else
    echo "✅ No crashes detected"
fi
echo ""

# 7. Check logs for contacts sync
echo "7️⃣ Checking app logs..."
adb -s $DEVICE logcat -d | grep -i "contacts\|sync\|permission" | tail -20
echo ""

# 8. Check if contacts in database
echo "8️⃣ Checking database (requires root or debuggable)..."
COUNT=$(adb -s $DEVICE shell "run-as $PACKAGE sqlite3 databases/contacts.db 'SELECT COUNT(*) FROM contacts;'" 2>/dev/null || echo "Unable to access")
echo "   Contacts in DB: $COUNT"
echo ""

# 9. Take screenshot
echo "9️⃣ Taking screenshot..."
adb -s $DEVICE shell screencap -p /sdcard/verification.png
adb -s $DEVICE pull /sdcard/verification.png /tmp/verification.png 2>/dev/null
if [ -f /tmp/verification.png ]; then
    echo "✅ Screenshot saved: /tmp/verification.png"
    echo "   Open it to verify contacts are displayed"
else
    echo "⚠️  Screenshot failed"
fi
echo ""

echo "========================================"
echo "✅ DIAGNOSTIC COMPLETE"
echo "========================================"
echo ""
echo "Please check:"
echo "1. Device $DEVICE - is app running?"
echo "2. Are contacts visible?"
echo "3. Screenshot at /tmp/verification.png"
echo ""

