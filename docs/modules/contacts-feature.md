# Contacts Feature Module

## 📦 Module Overview

**Package**: `com.ai.codefixchallange.presentation.contacts`  
**Purpose**: Display device contacts in a list and handle user interactions  
**Type**: Feature Module (Presentation Layer)

---

## 🎯 Responsibilities

1. Display contacts from device in RecyclerView
2. Handle READ_CONTACTS permission requests
3. Provide pull-to-refresh functionality
4. Navigate to contact detail screen
5. Show loading, error, and empty states

---

## 🏗️ Architecture

### Components

#### 1. **ContactsFragment**
**Purpose**: UI controller for contacts list  
**File**: `presentation/contacts/ContactsFragment.kt`

**Responsibilities**:
- Display RecyclerView with contacts
- Handle permission requests
- Observe ViewModel state
- Navigate to detail screen

**Key Methods**:
```kotlin
setupRecyclerView()      // Initialize RecyclerView
observeState()           // Collect StateFlow
requestContactPermission() // Handle permissions
```

#### 2. **ContactsViewModel**
**Purpose**: Business logic for contacts list  
**File**: `presentation/contacts/ContactsViewModel.kt`

**State Management**:
```kotlin
sealed class ContactsState {
    object Loading
    data class Success(val contacts: List<Contact>)
    data class Error(val message: String)
    object PermissionRequired
}
```

**Key Methods**:
```kotlin
checkPermissionAndLoadContacts()
syncContacts()
retry()
```

#### 3. **ContactsAdapter**
**Purpose**: RecyclerView adapter with DiffUtil  
**File**: `presentation/contacts/ContactsAdapter.kt`

**Features**:
- Efficient list updates via DiffUtil
- Click listener for navigation
- ViewHolder pattern

---

## 📊 Data Flow

```
User Action (Pull Refresh)
    ↓
ContactsFragment.onRefreshListener()
    ↓
ContactsViewModel.syncContacts()
    ↓
ContactRepositoryImpl.syncContacts()
    ↓
ContactDataSource.fetchContacts() → ContentProvider
    ↓
Room Database (Cache)
    ↓
StateFlow<ContactsState> updates
    ↓
Fragment observes and updates UI
```

---

## 🔗 Dependencies

### Domain Layer
- `GetContactsUseCase` - Fetch contacts use case
- `Contact` model - Domain model

### Data Layer  
- `ContactRepositoryImpl` - For sync operations
- Injected via Hilt

### Android Framework
- `Navigation Component` - For fragment navigation
- `RecyclerView` - For list display
- `SwipeRefreshLayout` - For pull-to-refresh

---

## 🎨 UI Components

### Layout Files
- `fragment_contacts.xml` - Main container
- `item_contact.xml` - Contact list item

### States Displayed
1. **Loading** - ProgressBar visible
2. **Success** - RecyclerView with contacts
3. **Error** - Error message with retry button
4. **Permission Required** - Permission rationale
5. **Empty** - No contacts message

---

## 🔌 Integration Points

### Navigation
**From**: Main navigation graph  
**To**: ContactDetailFragment

```kotlin
val action = ContactsFragmentDirections
    .actionContactsFragmentToContactDetailFragment(contactId)
findNavController().navigate(action)
```

### Permission Handling
Uses `ActivityResultContracts.RequestPermission()`

```kotlin
private val requestPermissionLauncher = 
    registerForActivityResult(RequestPermission()) { isGranted ->
        // Handle result
    }
```

---

## 🧪 Testing

### Unit Tests
**File**: `test/.../ContactsViewModelTest.kt`

**Test Coverage**:
- ✅ Load contacts when permission granted
- ✅ Show permission required when denied
- ✅ Sync contacts successfully
- ✅ Handle sync errors
- ✅ Retry functionality
- ✅ State transitions

**Coverage**: 90%+

---

## 📚 Skills & Patterns Used

This module demonstrates:

- **[MVVM Pattern](../skills/mvvm-pattern.md)** - ViewModel with StateFlow
- **[Navigation Component](../skills/navigation-component.md)** - Safe Args navigation
- **[RecyclerView + DiffUtil](../skills/recyclerview-diffutil.md)** - Efficient lists
- **[StateFlow](../skills/kotlin-coroutines.md)** - Reactive state management
- **[Dependency Injection](../skills/dependency-injection.md)** - Hilt integration
- **[Permission Handling](../skills/permissions.md)** - Runtime permissions

---

## 🔄 Future Enhancements

Potential improvements (not yet implemented):
- [ ] Search functionality
- [ ] Contact filtering
- [ ] Multiple selection mode
- [ ] Favorites marking
- [ ] Alphabetical section headers

---

## 📝 Notes for Developers

### Adding a new field to Contact display:
1. Update `item_contact.xml` layout
2. Update `ContactViewHolder.bind()` method
3. Tests should still pass (covered by ViewModel tests)

### Changing the list behavior:
1. Modify `ContactsAdapter` 
2. Update `ContactDiffCallback` if comparing logic changes
3. No ViewModel changes needed (separation of concerns)

### Adding new state:
1. Add sealed class state in `ContactsState.kt`
2. Handle in `ContactsViewModel`
3. Update `observeState()` in Fragment
4. Add corresponding UI in layout

---

## 🐛 Common Issues

**Issue**: Contacts not loading  
**Check**: Permission granted? Call `syncContacts()` after permission

**Issue**: List not updating  
**Check**: DiffUtil callback implemented correctly?

**Issue**: Navigation not working  
**Check**: SafeArgs plugin enabled in build.gradle

---

**Last Updated**: 2024-03-06  
**Module Version**: 1.0.0  
**Maintainer**: Development Team

