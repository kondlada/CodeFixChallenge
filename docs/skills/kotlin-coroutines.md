# Kotlin Coroutines in This Project

## 📚 Overview

Kotlin Coroutines is our standard for all asynchronous operations. We use coroutines throughout the app for:
- Database operations
- Network calls (future)
- Content Provider access
- Long-running calculations

**Why Coroutines?**
- ✅ Sequential-looking async code
- ✅ Built-in cancellation support
- ✅ Structured concurrency
- ✅ Better than callbacks/RxJava for our use case

---

## 🎯 How We Use Coroutines

### 1. **In ViewModels** - `viewModelScope`

**Location**: All ViewModel classes in `presentation/` layer

**Pattern**:
```kotlin
// See: presentation/contacts/ContactsViewModel.kt
class ContactsViewModel @Inject constructor(
    private val getContactsUseCase: GetContactsUseCase
) : ViewModel() {
    
    fun syncContacts() {
        viewModelScope.launch {  // ← Automatically cancelled when ViewModel cleared
            try {
                contactRepository.syncContacts()
            } catch (e: Exception) {
                _state.value = ContactsState.Error(e.message ?: "Error")
            }
        }
    }
}
```

**Why `viewModelScope`?**
- Automatically cancelled when ViewModel is cleared
- Runs on Main dispatcher by default
- Perfect for UI-related async work

---

### 2. **In Repositories** - `withContext(Dispatchers.IO)`

**Location**: `data/repository/ContactRepositoryImpl.kt`

**Pattern**:
```kotlin
// See: data/repository/ContactRepositoryImpl.kt
suspend fun syncContacts() {
    // No need for withContext here, called from ViewModel's viewModelScope
    val contacts = contactDataSource.fetchContacts()
    contactDao.insertContacts(contacts.toEntityList())
}
```

**Location**: `data/source/ContactDataSource.kt`

**Pattern**:
```kotlin
// See: data/source/ContactDataSource.kt
suspend fun fetchContacts(): List<Contact> = withContext(Dispatchers.IO) {
    // Heavy operation - use IO dispatcher
    val cursor = contentResolver.query(...)
    // Parse cursor...
    return@withContext contacts
}
```

**Why `withContext(Dispatchers.IO)`?**
- Switches to IO dispatcher for blocking operations
- Returns to original dispatcher after
- Use for: database, file I/O, ContentProvider

---

### 3. **In Use Cases** - Simple `suspend` functions

**Location**: `domain/usecase/*.kt`

**Pattern**:
```kotlin
// See: domain/usecase/GetContactByIdUseCase.kt
class GetContactByIdUseCase @Inject constructor(
    private val contactRepository: ContactRepository
) {
    suspend operator fun invoke(contactId: String): Contact? {
        return contactRepository.getContactById(contactId)
    }
}
```

**No dispatcher switching needed:**
- Use cases just call repository
- Repository handles dispatcher switching
- Keep use cases simple

---

### 4. **With Flow** - Reactive streams

**Location**: Throughout `data/` and `domain/` layers

**Pattern**:
```kotlin
// See: domain/repository/ContactRepository.kt (interface)
interface ContactRepository {
    fun getContacts(): Flow<List<Contact>>  // ← Returns Flow, not suspend
}

// See: data/repository/ContactRepositoryImpl.kt (implementation)
override fun getContacts(): Flow<List<Contact>> {
    return contactDao.getAllContacts()
        .map { entities -> entities.toDomainList() }
}

// See: presentation/contacts/ContactsViewModel.kt (consumer)
init {
    viewModelScope.launch {
        getContactsUseCase()
            .catch { e -> 
                _state.value = ContactsState.Error(e.message ?: "Error")
            }
            .collect { contacts ->
                _state.value = ContactsState.Success(contacts)
            }
    }
}
```

**When to use Flow:**
- ✅ Reactive data (database queries)
- ✅ Multiple values over time
- ✅ Need operators (map, filter, etc.)

**When to use suspend:**
- ✅ One-shot operations
- ✅ Simple async calls
- ✅ Single return value

---

## 🎨 Patterns We Follow

### Pattern 1: **Repository calls are suspend functions**

```kotlin
// ✅ GOOD
interface ContactRepository {
    suspend fun getContactById(id: String): Contact?
    fun getContacts(): Flow<List<Contact>>  // Flow, not suspend
}

// ❌ BAD - Don't do this
interface ContactRepository {
    fun getContactById(id: String): Contact?  // Not suspend - blocks!
}
```

### Pattern 2: **ViewModels use viewModelScope**

```kotlin
// ✅ GOOD
class MyViewModel @Inject constructor(...) : ViewModel() {
    fun doSomething() {
        viewModelScope.launch {
            // Async work
        }
    }
}

// ❌ BAD - Don't create own scope
class MyViewModel @Inject constructor(...) : ViewModel() {
    private val scope = CoroutineScope(Dispatchers.Main)  // Manual scope - memory leak!
}
```

### Pattern 3: **Use withContext for blocking operations**

```kotlin
// ✅ GOOD
suspend fun heavyOperation() = withContext(Dispatchers.IO) {
    // Blocking operation
    Thread.sleep(1000)  // Example
}

// ❌ BAD - Blocking on Main thread
suspend fun heavyOperation() {
    Thread.sleep(1000)  // Blocks UI!
}
```

### Pattern 4: **Handle exceptions in ViewModel**

```kotlin
// ✅ GOOD
viewModelScope.launch {
    try {
        val result = repository.getData()
        _state.value = Success(result)
    } catch (e: Exception) {
        _state.value = Error(e.message)
    }
}

// ❌ BAD - Uncaught exception crashes app
viewModelScope.launch {
    val result = repository.getData()  // Might throw!
    _state.value = Success(result)
}
```

---

## 📍 Where Used in Codebase

### Data Layer:
- `data/source/ContactDataSource.kt` - `withContext(Dispatchers.IO)` for ContentProvider
- `data/repository/ContactRepositoryImpl.kt` - suspend functions

### Domain Layer:
- `domain/usecase/GetContactsUseCase.kt` - operator invoke
- `domain/usecase/GetContactByIdUseCase.kt` - suspend operator invoke

### Presentation Layer:
- `presentation/contacts/ContactsViewModel.kt` - viewModelScope.launch
- `presentation/detail/ContactDetailViewModel.kt` - viewModelScope.launch

---

## 🛠️ Common Scenarios

### Scenario 1: Add new API call

```kotlin
// 1. Define in repository (data layer)
interface MyRepository {
    suspend fun fetchData(): Result<Data>
}

// 2. Implement with IO dispatcher
class MyRepositoryImpl : MyRepository {
    override suspend fun fetchData() = withContext(Dispatchers.IO) {
        // API call
    }
}

// 3. Use in ViewModel
class MyViewModel @Inject constructor(
    private val repository: MyRepository
) : ViewModel() {
    fun loadData() {
        viewModelScope.launch {
            try {
                val data = repository.fetchData()
                // Update state
            } catch (e: Exception) {
                // Handle error
            }
        }
    }
}
```

### Scenario 2: Chain multiple async calls

```kotlin
viewModelScope.launch {
    try {
        val user = userRepository.getUser()
        val contacts = contactRepository.getContacts(user.id)
        val filtered = filterContacts(contacts)  // Suspend function
        _state.value = Success(filtered)
    } catch (e: Exception) {
        _state.value = Error(e.message)
    }
}
```

### Scenario 3: Parallel execution

```kotlin
viewModelScope.launch {
    val deferredUser = async { userRepository.getUser() }
    val deferredSettings = async { settingsRepository.getSettings() }
    
    val user = deferredUser.await()
    val settings = deferredSettings.await()
    
    // Use both results
}
```

---

## 🐛 Common Issues & Solutions

### Issue 1: **App crashes on rotation**

**Problem**: Coroutine continues after ViewModel is cleared

**Solution**: Always use `viewModelScope`
```kotlin
// ✅ GOOD - Auto-cancelled
viewModelScope.launch { ... }

// ❌ BAD - Leaks
GlobalScope.launch { ... }
```

### Issue 2: **UI freezes during operation**

**Problem**: Blocking operation on Main thread

**Solution**: Use IO dispatcher
```kotlin
suspend fun blockingWork() = withContext(Dispatchers.IO) {
    // Heavy work here
}
```

### Issue 3: **Job never completes**

**Problem**: Forgot to use suspend function

**Solution**: Make function suspend
```kotlin
// ❌ BAD
fun getData(): Data {
    val result = repository.getData()  // Compile error if getData is suspend
    return result
}

// ✅ GOOD
suspend fun getData(): Data {
    return repository.getData()
}
```

---

## 🧪 Testing Coroutines

**Location**: All test files in `test/` directory

**Pattern**:
```kotlin
// See: test/.../ContactsViewModelTest.kt
@OptIn(ExperimentalCoroutinesApi::class)
class ContactsViewModelTest {
    
    private val testDispatcher = StandardTestDispatcher()
    
    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)
    }
    
    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }
    
    @Test
    fun `test async operation`() = runTest {
        // Given
        val expected = ...
        
        // When
        viewModel.doSomething()
        advanceUntilIdle()  // Wait for coroutines
        
        // Then
        assertEquals(expected, viewModel.state.value)
    }
}
```

**Key testing tools:**
- `runTest` - Test coroutine scope
- `StandardTestDispatcher` - Test dispatcher
- `advanceUntilIdle()` - Execute all pending coroutines

---

## 📚 Resources

### Official Docs:
- [Kotlin Coroutines Guide](https://kotlinlang.org/docs/coroutines-guide.html)
- [Android Coroutines Best Practices](https://developer.android.com/kotlin/coroutines)

### In This Codebase:
- Start with: `presentation/contacts/ContactsViewModel.kt`
- Then: `data/repository/ContactRepositoryImpl.kt`
- Advanced: `data/source/ContactDataSource.kt`

---

## ✅ Checklist for Using Coroutines

When adding async code:
- [ ] Used `viewModelScope` in ViewModel?
- [ ] Used `withContext(Dispatchers.IO)` for blocking operations?
- [ ] Handled exceptions with try-catch?
- [ ] Functions marked as `suspend`?
- [ ] Tests use `runTest` and `advanceUntilIdle()`?
- [ ] No `GlobalScope` or manual scope creation?

---

**Last Updated**: 2024-03-06  
**Related Skills**: [Flow & StateFlow](flow-and-stateflow.md), [Repository Pattern](repository-pattern.md)  
**Maintainer**: Development Team

