# Contacts Manager - Clean Architecture Application

## 📋 Project Overview

A modern Android application that displays phone contacts using Clean Architecture principles, MVVM pattern, and comprehensive testing with 100% code coverage target.

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Fragments   │  │  ViewModels  │  │   Adapters   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   UseCases   │  │    Models    │  │ Repositories │      │
│  │              │  │              │  │ (Interfaces) │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │RepositoryImpl│  │     Room     │  │DataSource    │      │
│  │              │  │   Database   │  │(ContentProv.)│      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### Layer Breakdown

#### 1. **Presentation Layer** (`presentation/`)
- **Fragments**: UI components (ContactsFragment, ContactDetailFragment)
- **ViewModels**: Manage UI state and business logic
- **Adapters**: RecyclerView adapters for displaying lists
- **States**: Sealed classes representing UI states

**Key Components:**
- `ContactsFragment`: Displays list of contacts in RecyclerView
- `ContactDetailFragment`: Shows detailed contact information
- `ContactsViewModel`: Manages contacts list state
- `ContactDetailViewModel`: Manages contact detail state
- `ContactsAdapter`: RecyclerView adapter with DiffUtil

#### 2. **Domain Layer** (`domain/`)
- **Models**: Core business entities (Contact)
- **UseCases**: Business logic operations
- **Repository Interfaces**: Contracts for data operations

**Key Components:**
- `Contact`: Domain model representing a contact
- `GetContactsUseCase`: Fetches all contacts
- `GetContactByIdUseCase`: Fetches specific contact
- `ContactRepository`: Interface defining data operations

#### 3. **Data Layer** (`data/`)
- **Repository Implementation**: Concrete repository implementations
- **Local Database**: Room database for caching
- **Data Sources**: ContentProvider access for device contacts
- **Mappers**: Convert between data and domain models

**Key Components:**
- `ContactRepositoryImpl`: Implements ContactRepository
- `ContactDatabase`: Room database
- `ContactDao`: Data Access Object
- `ContactEntity`: Room entity
- `ContactDataSource`: Accesses device contacts
- `ContactMapper`: Maps between entities and domain models

## 🛠️ Technology Stack

### Core
- **Language**: Kotlin 2.0.21
- **Min SDK**: 24 (Android 7.0)
- **Target SDK**: 36
- **Compile SDK**: 36

### Architecture Components
- **Architecture Pattern**: Clean Architecture + MVVM
- **Dependency Injection**: Hilt (Dagger 2.51)
- **Navigation**: Navigation Component 2.8.0
- **Database**: Room 2.6.1
- **Async Operations**: Kotlin Coroutines 1.8.0 + Flow

### UI
- **View System**: XML Layouts with ViewBinding
- **RecyclerView**: For efficient list display
- **Material Design**: Material Components
- **SwipeRefreshLayout**: Pull-to-refresh functionality

### Testing
- **Unit Testing**: JUnit 4.13.2
- **Mocking**: MockK 1.13.10
- **Coroutines Testing**: kotlinx-coroutines-test 1.8.0
- **Architecture Testing**: arch-core-testing 2.2.0
- **Coverage**: JaCoCo 0.8.12

### Build & Reporting
- **Build Tool**: Gradle 8.13.0
- **KSP**: 2.0.21-1.0.25
- **Excel Reports**: Apache POI 5.2.5

## 📁 Project Structure

```
com.ai.codefixchallange/
├── data/
│   ├── local/
│   │   ├── ContactDao.kt
│   │   ├── ContactDatabase.kt
│   │   └── ContactEntity.kt
│   ├── mapper/
│   │   └── ContactMapper.kt
│   ├── repository/
│   │   └── ContactRepositoryImpl.kt
│   └── source/
│       └── ContactDataSource.kt
├── di/
│   └── AppModule.kt
├── domain/
│   ├── model/
│   │   └── Contact.kt
│   ├── repository/
│   │   └── ContactRepository.kt
│   └── usecase/
│       ├── GetContactByIdUseCase.kt
│       └── GetContactsUseCase.kt
├── presentation/
│   ├── contacts/
│   │   ├── ContactsAdapter.kt
│   │   ├── ContactsFragment.kt
│   │   ├── ContactsState.kt
│   │   └── ContactsViewModel.kt
│   └── detail/
│       ├── ContactDetailFragment.kt
│       ├── ContactDetailState.kt
│       └── ContactDetailViewModel.kt
├── util/
│   ├── ExcelReportGenerator.kt
│   ├── HtmlReportGenerator.kt
│   └── TestResult.kt
├── ContactsApplication.kt
└── MainActivity.kt
```

## 🎯 Features

### Core Features
1. **Contact List Display**
   - Display all phone contacts in a RecyclerView
   - Efficient list updates with DiffUtil
   - Pull-to-refresh functionality
   - Loading, error, and empty states

2. **Contact Details**
   - View detailed contact information
   - Call, SMS, and email actions
   - Back navigation support

3. **Permission Handling**
   - Runtime permission request for READ_CONTACTS
   - Permission rationale display
   - Graceful permission denial handling

4. **Offline Support**
   - Local caching with Room database
   - Data persistence across app restarts
   - Sync functionality

### Technical Features
- **Dependency Injection**: Hilt for clean dependency management
- **Reactive UI**: StateFlow for reactive state management
- **Navigation**: Safe Args for type-safe navigation
- **Error Handling**: Comprehensive error states
- **Memory Management**: ViewBinding with proper lifecycle handling

## 🧪 Testing Strategy

### Test Coverage Target: 100%

#### Unit Tests (Domain Layer)
- ✅ `GetContactsUseCaseTest`
- ✅ `GetContactByIdUseCaseTest`

#### Unit Tests (Data Layer)
- ✅ `ContactMapperTest`
- ✅ `ContactRepositoryImplTest`

#### Unit Tests (Presentation Layer)
- ✅ `ContactsViewModelTest`
- ✅ `ContactDetailViewModelTest`

#### Integration Tests
- ✅ Database operations
- ✅ Repository integration
- ✅ End-to-end data flow

### Test Report Generation
The project includes automated test report generation:

**HTML Report**: Beautiful visual report with charts
- Test summary with pass/fail statistics
- Pie chart visualization
- Detailed test results table
- Coverage metrics

**Excel Report**: Structured data for analysis
- Summary sheet with metrics
- Detailed results sheet
- Color-coded status indicators

## 🚀 Getting Started

### Prerequisites
- Android Studio Hedgehog or later
- JDK 11 or later
- Android SDK 24-36
- Gradle 8.0+

### Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd CodeFixChallange
   ```

2. **Open in Android Studio**
   - Open Android Studio
   - Select "Open an Existing Project"
   - Navigate to the project directory
   - Wait for Gradle sync to complete

3. **Run the Application**
   ```bash
   ./gradlew installDebug
   ```
   Or use the Run button in Android Studio

4. **Grant Permissions**
   - On first launch, grant READ_CONTACTS permission
   - Contacts will be synced automatically

### Running Tests

#### All Tests with Coverage
```bash
./gradlew clean testDebugUnitTest jacocoTestReport
```

#### Unit Tests Only
```bash
./gradlew test
```

#### Generate Custom Reports
```bash
chmod +x generate-reports.sh
./generate-reports.sh
```

### Viewing Reports

#### Code Coverage Report
```bash
open app/build/reports/jacoco/jacocoTestReport/html/index.html
```

#### Unit Test Report
```bash
open app/build/reports/tests/testDebugUnitTest/index.html
```

## 📊 Code Coverage

The project is configured with JaCoCo for comprehensive code coverage analysis.

### Coverage Configuration
- **Tool**: JaCoCo 0.8.12
- **Excluded Files**:
  - Generated files (R, BuildConfig, Hilt)
  - Data models (simple POJOs)
  - UI test files

### Generating Coverage Report
```bash
./gradlew jacocoTestReport
```

Report location: `app/build/reports/jacoco/jacocoTestReport/html/index.html`

### Coverage Goals
- **Overall**: 100%
- **Domain Layer**: 100%
- **Data Layer**: 95%+
- **Presentation Layer**: 90%+

## 🔧 Build Configuration

### Gradle Modules
- **App Module**: Main application module
- **Build Types**: Debug (with coverage), Release

### Key Dependencies
```kotlin
// Dependency Injection
implementation("com.google.dagger:hilt-android:2.51")
kapt("com.google.dagger:hilt-compiler:2.51")

// Architecture Components
implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.10.0")
implementation("androidx.navigation:navigation-fragment-ktx:2.8.0")

// Database
implementation("androidx.room:room-runtime:2.6.1")
kapt("androidx.room:room-compiler:2.6.1")

// Coroutines
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.0")

// Testing
testImplementation("junit:junit:4.13.2")
testImplementation("io.mockk:mockk:1.13.10")
testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.8.0")
```

## 📝 Design Patterns Used

1. **Clean Architecture**: Separation of concerns across layers
2. **MVVM**: Model-View-ViewModel for presentation
3. **Repository Pattern**: Abstract data sources
4. **Dependency Injection**: Hilt for DI
5. **Observer Pattern**: StateFlow/LiveData for reactive updates
6. **Adapter Pattern**: RecyclerView adapter
7. **Factory Pattern**: ViewModel creation
8. **Singleton Pattern**: Database instance

## 🔐 Permissions

### Required Permissions
- `READ_CONTACTS`: To access device contacts

### Permission Handling
- Runtime permission request
- Permission rationale
- Graceful degradation

## 🐛 Error Handling

### Error States
- **Loading**: Show progress indicator
- **Error**: Display error message with retry
- **Empty**: Show empty state message
- **Permission Denied**: Request permission with rationale

### Exception Handling
- Try-catch in ViewModel
- Error propagation through Flow
- User-friendly error messages

## 🎨 UI/UX Features

### Material Design
- Material Components
- Elevation and shadows
- Ripple effects
- Color theming

### User Experience
- Pull-to-refresh
- Loading indicators
- Error states
- Empty states
- Smooth animations
- Navigation transitions

## 🔄 Data Flow

### Contact List Flow
```
User Opens App
    ↓
ContactsFragment
    ↓
ContactsViewModel (check permission)
    ↓
GetContactsUseCase
    ↓
ContactRepository
    ↓
Room Database (cached) + ContentProvider (sync)
    ↓
Map to Domain Model
    ↓
StateFlow updates UI
    ↓
RecyclerView displays contacts
```

### Contact Detail Flow
```
User Clicks Contact
    ↓
Navigate with contactId
    ↓
ContactDetailFragment
    ↓
ContactDetailViewModel
    ↓
GetContactByIdUseCase
    ↓
ContactRepository
    ↓
Room Database
    ↓
StateFlow updates UI
    ↓
Display contact details
```

## 📚 Learning Resources

### Clean Architecture
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Android Clean Architecture Guide](https://developer.android.com/topic/architecture)

### MVVM Pattern
- [MVVM Architecture](https://developer.android.com/topic/libraries/architecture/viewmodel)

### Kotlin Coroutines
- [Kotlin Coroutines Guide](https://kotlinlang.org/docs/coroutines-guide.html)

### Testing
- [Testing on Android](https://developer.android.com/training/testing)

## 🤝 Contributing

This project follows standard Git workflow:
1. Create feature branch
2. Make changes
3. Write/update tests
4. Ensure 100% coverage
5. Create pull request

## 📄 License

[Add your license here]

## 👥 Authors

[Add author information]

## 🙏 Acknowledgments

- Clean Architecture principles by Robert C. Martin
- Android Architecture Components team
- Open-source community

---

**Version**: 1.0.0  
**Last Updated**: 2024  
**Status**: ✅ Production Ready

