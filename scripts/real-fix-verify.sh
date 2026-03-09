#!/bin/bash

# REAL Fix and Verification - Actually Check Contacts Display

echo "🔧 REAL FIX: Verify Contacts Actually Work"
echo "==========================================="
echo ""

DEVICE="57111FDCH007MJ"
PACKAGE="com.ai.codefixchallange"

# Step 1: Grant permission
echo "1️⃣ Granting READ_CONTACTS permission..."
adb -s $DEVICE shell pm grant $PACKAGE android.permission.READ_CONTACTS 2>&1
sleep 1
echo "✅ Permission granted"
echo ""

# Step 2: Check if device has contacts
echo "2️⃣ Checking device contacts..."
CONTACT_COUNT=$(adb -s $DEVICE shell content query --uri content://com.android.contacts/contacts 2>/dev/null | grep "Row:" | wc -l)
echo "   Device has $CONTACT_COUNT contacts"

if [ $CONTACT_COUNT -eq 0 ]; then
    echo "⚠️  No contacts on device!"
    echo ""
    echo "📝 Adding test contacts..."

    # Add test contacts
    for i in {1..5}; do
        adb -s $DEVICE shell am start -a android.intent.action.INSERT \
            -t vnd.android.cursor.dir/contact \
            -e name "Test Contact $i" \
            -e phone "555000000$i" >/dev/null 2>&1
        sleep 0.5
    done

    echo "✅ Please manually save the test contacts on the device"
    echo "   Then press ENTER to continue..."
    read
else
    echo "✅ Device has contacts"
fi
echo ""

# Step 3: Relaunch app
echo "3️⃣ Relaunching app..."
adb -s $DEVICE shell am force-stop $PACKAGE
sleep 1
adb -s $DEVICE logcat -c
adb -s $DEVICE shell am start -n $PACKAGE/.MainActivity
sleep 3
echo "✅ App launched"
echo ""

# Step 4: Check app logs
echo "4️⃣ Checking app state..."
LOG_OUTPUT=$(adb -s $DEVICE logcat -d | grep -i "ContactsState\|Success\|contacts.size" | tail -10)
if echo "$LOG_OUTPUT" | grep -q "Success"; then
    echo "✅ ContactsState.Success detected"
fi
echo ""

# Step 5: Check UI hierarchy
echo "5️⃣ Checking UI elements..."
UI_DUMP=$(adb -s $DEVICE shell uiautomator dump /dev/tty 2>/dev/null)
if echo "$UI_DUMP" | grep -q "RecyclerView"; then
    echo "✅ RecyclerView found in UI"
fi
if echo "$UI_DUMP" | grep -q "No contacts"; then
    echo "⚠️  'No contacts' text found - contacts NOT showing!"
else
    echo "✅ No 'No contacts' error message"
fi
echo ""

# Step 6: Take screenshot
echo "6️⃣ Taking screenshot for manual verification..."
adb -s $DEVICE shell screencap -p /sdcard/contacts_screenshot.png
adb -s $DEVICE pull /sdcard/contacts_screenshot.png /tmp/contacts_screenshot.png 2>/dev/null
if [ -f /tmp/contacts_screenshot.png ]; then
    echo "✅ Screenshot saved to: /tmp/contacts_screenshot.png"
    echo "   Open it to verify contacts are displayed"
else
    echo "⚠️  Screenshot failed"
fi
echo ""

# Step 7: Manual verification prompt
echo "==========================================="
echo "📱 MANUAL VERIFICATION REQUIRED"
echo "==========================================="
echo ""
echo "Please check on device $DEVICE:"
echo ""
echo "1. Is the app open? (should be)"
echo "2. Do you see a list of contacts? (yes/no)"
echo "3. Can you pull down to refresh? (try it)"
echo "4. After refresh, do contacts appear? (yes/no)"
echo ""
echo "Enter 'yes' if contacts are NOW showing: "
read USER_RESPONSE

if [ "$USER_RESPONSE" = "yes" ] || [ "$USER_RESPONSE" = "y" ]; then
    echo ""
    echo "✅ SUCCESS! Contacts are displaying"
    echo ""
    echo "The fix works! Issue resolved."
    exit 0
else
    echo ""
    echo "❌ FAILED: Contacts still not showing"
    echo ""
    echo "🔍 Possible remaining issues:"
    echo "1. Permission not persisted"
    echo "2. Sync not triggered"
    echo "3. Database empty"
    echo "4. UI bug still exists"
    echo ""
    echo "Check logs:"
    adb -s $DEVICE logcat -d | grep -i "ContactsViewModel" | tail -20
    exit 1
fi

