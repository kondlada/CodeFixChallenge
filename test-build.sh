#!/bin/bash
cd /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange
echo "Starting Gradle build..."
./gradlew assembleDebug --no-daemon --console=plain 2>&1
echo "Build exit code: $?"

