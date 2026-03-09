#!/bin/bash
echo "Testing Gradle build configuration..."
cd /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange
./gradlew tasks --no-daemon 2>&1 | head -5
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Build configuration is valid!"
    echo "Now testing assembleDebug..."
    ./gradlew assembleDebug --no-daemon
else
    echo "❌ Build configuration has errors"
    exit 1
fi

