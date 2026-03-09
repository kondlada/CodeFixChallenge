# 🚀 Quick Command Reference - Agent & Error Checking

## ⚡ Most Common Commands

### Check for Build Errors
```bash
./gradlew build
```

### Run Agent for GitHub Issue
```bash
./scripts/start-agent.sh <issue_number>
```

### Validate Everything
```bash
./scripts/validate-setup.sh
```

### Run Tests with Reports
```bash
./scripts/run-tests-with-reports.sh
```

---

## 🎯 Quick Workflow

```bash
# 1. Check for errors
./gradlew clean build

# 2. Run tests
./gradlew testDebugUnitTest

# 3. View coverage
./gradlew jacocoTestReport
open app/build/reports/jacoco/jacocoTestReport/html/index.html

# 4. Run agent for issue
./scripts/start-agent.sh 42
```

---

## 🐛 Quick Fixes

### Build Fails?
```bash
./gradlew clean
./gradlew build --no-daemon
```

### Gradle Issues?
```bash
./gradlew --stop
rm -rf ~/.gradle/caches/
./gradlew build
```

### Scripts Not Working?
```bash
chmod +x scripts/*.sh
chmod +x gradlew
```

---

## 📖 Full Documentation

See [AGENT_USAGE_GUIDE.md](AGENT_USAGE_GUIDE.md) for complete instructions.


