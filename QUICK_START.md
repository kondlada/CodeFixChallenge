# 🚀 Quick Start Guide - Contacts Manager App

## ⚡ 5-Minute Setup

Follow these steps to get the app running quickly!

### Step 1: Prerequisites ✓
Make sure you have:
- [ ] Android Studio (latest version)
- [ ] JDK 11 or higher
- [ ] Android device or emulator (Android 7.0+)

### Step 2: Clone & Open 📦
```bash
# Clone the repository
git clone <repository-url>
cd CodeFixChallange

# Open in Android Studio
# File -> Open -> Select CodeFixChallange folder
```

### Step 3: Sync & Build 🔧
1. Wait for Gradle sync to complete (automatic)
2. If sync fails, try: `Build -> Clean Project` then `Build -> Rebuild Project`

### Step 4: Run the App ▶️
1. Click the green Run button (or press `Shift + F10`)
2. Select your device/emulator
3. Wait for app to install and launch

### Step 5: Grant Permission 🔐
1. App will request READ_CONTACTS permission
2. Tap "Allow" to see your contacts
3. Contacts will load automatically

**🎉 Done! You should now see your contacts list!**

---

## 🧪 Running Tests

### Quick Test Run
```bash
./gradlew test
```

### With Coverage Report
```bash
./gradlew testDebugUnitTest jacocoTestReport
```

### View Coverage Report
```bash
open app/build/reports/jacoco/jacocoTestReport/html/index.html
```

---

## 📱 Using the App

### View Contacts
- Pull down to refresh
- Scroll through your contacts
- Search (coming soon)

### View Details
- Tap any contact to see details
- Use Call button to dial
- Use SMS button to send message
- Use Email button to send email

### Back Navigation
- Use back button or toolbar arrow
- Swipe from left edge (gesture navigation)

---

## 🐛 Troubleshooting

### Problem: Gradle Sync Failed
**Solution**: 
```bash
./gradlew clean
./gradlew build
```

### Problem: No Contacts Showing
**Solution**: 
- Check if permission was granted
- Ensure device has contacts
- Pull to refresh

### Problem: Tests Not Running
**Solution**:
```bash
./gradlew clean test
```

### Problem: Build Error
**Solution**:
- Invalidate Caches: `File -> Invalidate Caches -> Invalidate and Restart`
- Check JDK version: `File -> Project Structure -> SDK Location`

---

## 📚 Next Steps

1. **Read Documentation**
   - [README.md](README.md) - Project overview
   - [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture details
   - [SKILLS_DOCUMENT.md](SKILLS_DOCUMENT.md) - Learning guide

2. **Explore Code**
   - Start with `MainActivity.kt`
   - Check `ContactsFragment.kt`
   - Review `ContactsViewModel.kt`

3. **Run Tests**
   - See [TEST_REPORT.md](TEST_REPORT.md)
   - Try modifying tests
   - Add new tests

4. **Make Changes**
   - Add new features
   - Improve UI
   - Enhance functionality

---

## 🎯 Key Files to Know

| File | Purpose |
|------|---------|
| `MainActivity.kt` | Entry point |
| `ContactsFragment.kt` | Contacts list UI |
| `ContactsViewModel.kt` | Business logic |
| `ContactRepository.kt` | Data operations |
| `build.gradle.kts` | Dependencies |

---

## 💡 Tips

- 💾 **Save Often**: Auto-save is enabled
- 🔍 **Use Search**: `Shift + Shift` for global search
- 🐛 **Debug**: Set breakpoints with `Cmd + F8`
- 📝 **Format Code**: `Cmd + Alt + L`
- 🏃 **Run Tests**: Right-click test file -> Run

---

## 📞 Get Help

- 📖 Check documentation files
- 💬 Ask in issues
- 📧 Contact maintainers

---

**Ready to code! 🚀**

