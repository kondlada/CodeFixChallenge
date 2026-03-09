# 🚀 Pre-Push Automation & Testing Guide

## Overview

This project now has **automated pre-push validation** that ensures code quality before pushing to the repository.

## What Happens Before Each Push

When you try to push code, the system will **automatically**:

1. ✅ **Build the project** - Ensures code compiles
2. ✅ **Run unit tests** - Validates business logic
3. ✅ **Install app on device** - Tests installation
4. ✅ **Run instrumented tests** - Tests on real device/emulator
5. ✅ **Launch app** - Checks for immediate crashes
6. ✅ **Generate coverage report** - Measures test coverage
7. ✅ **Create Pull Request** - Instead of direct push to main

**If any step fails, the push is aborted!**

## Quick Start

### Running Tests Manually

```bash
# Run all tests and validation
./pre-push-validation.sh
```

### Running the App

```bash
# Build, install, and launch app
./run-app.sh
```

## Detailed Workflows

### 1️⃣ Making Changes & Testing

```bash
# Make your code changes
vim app/src/main/java/...

# Test your changes
./run-app.sh

# If multiple devices connected, select one:
# 1. 57111FDCH007MJ (Physical Device)
# 2. emulator-5554 (Emulator)
# Enter device number: 2
```

### 2️⃣ Committing Changes

```bash
# Stage your changes
git add .

# Commit with descriptive message
git commit -m "feat: Add new contact sorting feature"
```

### 3️⃣ Pushing Changes (With Auto-Validation)

```bash
# Try to push
git push origin your-branch

# The pre-push hook will automatically:
# 1. Run all tests
# 2. Check for crashes
# 3. Only allow push if everything passes
```

### 4️⃣ Creating Pull Request

The `pre-push-validation.sh` script will:
- Create a feature branch if you're on main
- Push your branch
- Create a PR automatically (if gh CLI is installed)

```bash
# Run the validation and PR creation
./pre-push-validation.sh
```

## Scripts Provided

### `pre-push-validation.sh` (Main Validation Script)

**What it does:**
- Checks for uncommitted changes
- Verifies device is connected
- Builds the project
- Runs unit tests
- Installs app on device
- Runs instrumented tests
- Launches app and checks for crashes
- Generates test coverage
- Creates Pull Request

**Usage:**
```bash
./pre-push-validation.sh
```

### `run-app.sh` (Quick App Testing)

**What it does:**
- Detects connected devices
- Lets you select which device to use
- Builds the app
- Installs on selected device
- Launches the app
- Checks for crashes

**Usage:**
```bash
./run-app.sh

# With multiple devices:
# 1. 57111FDCH007MJ (Physical Device)
# 2. emulator-5554 (Emulator)
# Enter device number: 1
```

### `.git/hooks/pre-push` (Git Hook - Auto-runs)

**What it does:**
- Automatically runs `pre-push-validation.sh` when you `git push`
- Aborts push if validation fails
- Can be bypassed with `git push --no-verify` (not recommended)

**This runs automatically - you don't need to call it!**

## Device Requirements

### Minimum: One Device Connected

The scripts require at least one of:
- 📱 Physical Android device connected via USB
- 💻 Android emulator running

Check with:
```bash
adb devices
```

Should show:
```
List of devices attached
57111FDCH007MJ  device        # Physical device
emulator-5554   device        # Emulator
```

### Multiple Devices

If you have multiple devices:
- Scripts will prompt you to select one
- Selection is remembered for that session
- You can choose different device next time

## Test Reports

After running tests, reports are available at:

### Unit Test Report
```
app/build/reports/tests/testDebugUnitTest/index.html
```

### Instrumented Test Report
```
app/build/reports/androidTests/connected/debug/index.html
```

### Coverage Report
```
app/build/reports/jacoco/jacocoTestReport/html/index.html
```

**Open in browser:**
```bash
open app/build/reports/tests/testDebugUnitTest/index.html
```

## Common Scenarios

### Scenario 1: Quick Local Testing

```bash
# Just test the app quickly
./run-app.sh
```

### Scenario 2: Full Validation Before PR

```bash
# Run full test suite and create PR
./pre-push-validation.sh
```

### Scenario 3: Fix Found After Testing

```bash
# Tests failed? Fix the issue
vim app/src/.../MyClass.kt

# Test again
./run-app.sh

# When ready, run full validation
./pre-push-validation.sh
```

### Scenario 4: Emergency Bypass (Not Recommended)

```bash
# Skip validation (use only in emergencies!)
git push --no-verify origin your-branch
```

## Troubleshooting

### No Devices Found

**Error:**
```
❌ No emulator or device connected
```

**Fix:**
```bash
# Start an emulator
emulator -list-avds  # See available
emulator -avd Pixel_5_API_34 &  # Start one

# Or connect physical device via USB
# Enable USB debugging on device
```

### Tests Failing

**Error:**
```
❌ Unit tests failed
```

**Fix:**
1. Check test report (URL shown in output)
2. Fix failing tests
3. Run `./gradlew testDebugUnitTest` to verify
4. Try validation again

### App Crashes on Launch

**Error:**
```
❌ App crashed during launch!
```

**Fix:**
1. Check crash log (shown in output)
2. Fix the crash
3. Test with `./run-app.sh`
4. Run validation again

### Build Failures

**Error:**
```
❌ Build failed
```

**Fix:**
1. Check build output for errors
2. Fix compilation errors
3. Run `./gradlew clean build`
4. Try validation again

## Best Practices

### ✅ DO:
- Run `./run-app.sh` frequently during development
- Run `./pre-push-validation.sh` before creating PR
- Fix issues found by tests immediately
- Keep test coverage high
- Create feature branches for changes

### ❌ DON'T:
- Skip validation with `--no-verify` regularly
- Push directly to main branch
- Ignore test failures
- Commit untested code
- Bypass the automation

## CI/CD Integration

The pre-push validation matches what will run in CI/CD:
- Same tests
- Same checks
- Same requirements

**If validation passes locally, CI/CD will likely pass too!**

## Configuration

### Customizing Validation

Edit `pre-push-validation.sh` to:
- Add more test types
- Add lint checks
- Add code formatting checks
- Customize device selection

### Disabling Auto-Validation

To disable the git hook:
```bash
rm .git/hooks/pre-push
```

To re-enable:
```bash
chmod +x .git/hooks/pre-push
```

## Benefits

### For Developers:
- ✅ Catch issues before push
- ✅ No surprises in CI/CD
- ✅ Confidence in code quality
- ✅ Faster feedback loop

### For Team:
- ✅ Higher code quality
- ✅ Fewer broken builds
- ✅ Reduced review time
- ✅ Better collaboration

### For Project:
- ✅ Stable codebase
- ✅ Good test coverage
- ✅ Professional workflow
- ✅ Easier maintenance

## Examples

### Example 1: New Feature

```bash
# Create feature branch
git checkout -b feature/contact-sorting

# Make changes
vim app/src/.../ContactsViewModel.kt

# Test locally
./run-app.sh

# Commit
git add .
git commit -m "feat: Add contact sorting by name"

# Validate and create PR
./pre-push-validation.sh

# Review PR on GitHub and merge
```

### Example 2: Bug Fix

```bash
# Create bugfix branch
git checkout -b fix/crash-on-launch

# Fix the bug
vim app/src/.../MainActivity.kt

# Test the fix
./run-app.sh

# Verify no crash
# App should launch successfully

# Commit
git add .
git commit -m "fix: Resolve crash on app launch"

# Validate and push
./pre-push-validation.sh
```

## Summary

**Before pushing any code:**
1. ✅ Code must compile
2. ✅ Unit tests must pass
3. ✅ Instrumented tests must pass
4. ✅ App must launch without crashes
5. ✅ Changes go through PR, not direct push

**This ensures:**
- High code quality
- Working features
- No regressions
- Professional development process

---

**For more information, see:**
- `pre-push-validation.sh` - Main validation script
- `run-app.sh` - Quick testing script
- `.git/hooks/pre-push` - Auto-validation hook


