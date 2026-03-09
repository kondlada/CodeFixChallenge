# 🚀 QUICK START - Agent Command

## ✅ THE COMMAND:

```bash
cd /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange
./scripts/complete-agent-workflow.sh <issue_number> 57111FDCH007MJ
```

---

## 📋 WHAT IT DOES:

**One command runs everything:**
1. Fetches issue from GitHub
2. Captures BEFORE screenshot
3. Analyzes and suggests fixes
4. Builds and installs app
5. Captures AFTER screenshot
6. Runs all tests
7. Generates charts
8. Creates detailed report
9. Commits and pushes to GitHub
10. Closes the issue

---

## 💡 EXAMPLES:

```bash
# Fix issue #2
./scripts/complete-agent-workflow.sh 2 57111FDCH007MJ

# Fix issue #3
./scripts/complete-agent-workflow.sh 3 57111FDCH007MJ

# Fix issue #4
./scripts/complete-agent-workflow.sh 4 57111FDCH007MJ
```

---

## ⚠️ BEFORE RUNNING:

### 1. Check device connected:
```bash
adb devices
# Should show: 57111FDCH007MJ  device
```

### 2. Check open issues exist:
```
https://github.com/kondlada/CodeFixChallenge/issues
```

### 3. Be in project directory:
```bash
pwd
# Should be: /Users/karthikkondlada/AndroidStudioProjects/CodeFixChallange
```

---

## 📊 WHAT YOU'LL SEE:

```
🤖 COMPLETE AGENT WORKFLOW
Phase 1: ✅ Fetching issue
Phase 2: ✅ Before screenshot
Phase 3: ✅ Fix recommendations
Phase 4: ✅ Building APK
Phase 5: ✅ After screenshot
Phase 6: ✅ Running tests
Phase 7: ✅ Generating charts
Phase 8: ✅ Creating report
Phase 9: ✅ Pushing to GitHub
Phase 10: ✅ Closing issue

✨ ALL AUTOMATION COMPLETE!
```

---

## 🎯 THAT'S IT!

**Just run:**
```bash
./scripts/complete-agent-workflow.sh <issue_number> 57111FDCH007MJ
```

**And the agent does everything!** 🎉

