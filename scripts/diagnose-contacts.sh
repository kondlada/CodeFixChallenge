#!/bin/bash

# Diagnostic Script - Why Are Contacts Not Showing?

echo "🔍 DIAGNOSING CONTACTS ISSUE"
echo "============================"
echo ""

DEVICE="57111FDCH007MJ"
PACKAGE="com.ai.codefixchallange"

# 1. Check if app is installed
echo "1️⃣ Checking if app is installed..."
adb -s $DEVICE shell pm list packages | grep $PACKAGE
if [ $? -eq 0 ]; then
    echo "✅ App is installed"
else
    echo "❌ App NOT installed"
    exit 1
fi
echo ""

# 2. Check permissions
echo "2️⃣ Checking READ_CONTACTS permission..."
PERM_STATUS=$(adb -s $DEVICE shell dumpsys package $PACKAGE | grep "android.permission.READ_CONTACTS" | head -1)
echo "$PERM_STATUS"
if echo "$PERM_STATUS" | grep -q "granted=true"; then
    echo "✅ Permission GRANTED"
else
    echo "❌ Permission NOT GRANTED"
    echo ""
    echo "💡 Granting permission now..."
    adb -s $DEVICE shell pm grant $PACKAGE android.permission.READ_CONTACTS
    echo "✅ Permission granted"
fi
echo ""

# 3. Check device contacts
echo "3️⃣ Checking device contacts..."
CONTACT_COUNT=$(adb -s $DEVICE shell content query --uri content://com.android.contacts/contacts | wc -l)
echo "Device has $CONTACT_COUNT contact entries"
if [ $CONTACT_COUNT -lt 2 ]; then
    echo "⚠️  Device has very few or NO contacts!"
    echo "   Add some test contacts to the device"
fi
echo ""

# 4. Check app database
echo "4️⃣ Checking app's local database..."
DB_PATH="/data/data/$PACKAGE/databases/contacts.db"
adb -s $DEVICE shell "su 0 ls $DB_PATH 2>/dev/null || ls $DB_PATH 2>/dev/null" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Database exists"
    # Try to count contacts in DB
    DB_COUNT=$(adb -s $DEVICE shell "run-as $PACKAGE sqlite3 databases/contacts.db 'SELECT COUNT(*) FROM contacts;'" 2>/dev/null || echo "0")
    echo "   Contacts in DB: $DB_COUNT"
else
    echo "⚠️  Cannot access database (needs root or run-as)"
fi
echo ""

# 5. Clear logcat and launch app
echo "5️⃣ Launching app with logging..."
adb -s $DEVICE logcat -c
adb -s $DEVICE shell am start -n $PACKAGE/.MainActivity
sleep 3
echo ""

# 6. Check for errors
echo "6️⃣ Checking for errors..."
adb -s $DEVICE logcat -d -s "AndroidRuntime:E" | tail -10 > /tmp/errors.txt
if [ -s /tmp/errors.txt ]; then
    echo "❌ Errors found:"
    cat /tmp/errors.txt
else
    echo "✅ No fatal errors"
fi
echo ""

# 7. Check ContactsViewModel logs
echo "7️⃣ Checking ContactsViewModel state..."
adb -s $DEVICE logcat -d | grep -i "ContactsViewModel\|ContactsState\|syncContacts" | tail -10
echo ""

# 8. Summary
echo "==============================="
echo "📊 DIAGNOSIS SUMMARY"
echo "==============================="
echo ""
echo "App Installed: ✅"
echo "Permission: Check above"
echo "Device Contacts: $CONTACT_COUNT entries"
echo ""
echo "🔍 LIKELY ISSUES:"
echo "1. Permission not granted → Need to grant READ_CONTACTS"
echo "2. No contacts on device → Need to add test contacts"
echo "3. syncContacts() not called → Check ViewModel initialization"
echo ""
echo "📱 Next: Check the app UI and pull to refresh"

