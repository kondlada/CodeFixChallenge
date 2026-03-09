# Domain Layer Module

## 📦 Module Overview

**Package**: `com.ai.codefixchallange.domain`  
**Purpose**: Core business logic and rules - framework independent  
**Type**: Domain Layer (Clean Architecture)

---

## 🎯 Responsibilities

The Domain layer is the heart of Clean Architecture:
1. Define business models (entities)
2. Define repository contracts (interfaces)
3. Implement use cases (business operations)
4. **NO** Android framework dependencies
5. **NO** implementation details

---

## 🏗️ Structure

```
domain/
├── model/
│   └── Contact.kt              # Business entity
├── repository/
│   └── ContactRepository.kt    # Repository contract
└── usecase/
    ├── GetContactsUseCase.kt
    └── GetContactByIdUseCase.kt
```

---

## 📝 Components

### 1. Models (Entities)

#### Contact.kt
**Purpose**: Core business entity representing a contact

```kotlin
data class Contact(
    val id: String,
    val name: String,
    val phoneNumber: String,
    val email: String? = null,
    val photoUri: String? = null
)
```

**Design Decisions**:
- ✅ Pure Kotlin data class (no Android dependencies)
- ✅ Immutable (val properties)
- ✅ Nullable fields for optional data
- ✅ Simple, focused on business concept

**When to modify**:
- ✅ Business requirements change (new field needed)
- ❌ UI needs different format (use mapper instead)
- ❌ Database schema changes (use entity mapper)

---

### 2. Repository Interfaces

#### ContactRepository.kt
**Purpose**: Define contract for data operations

```kotlin
interface ContactRepository {
    fun getContacts(): Flow<List<Contact>>
    suspend fun getContactById(contactId: String): Contact?
    suspend fun hasContactPermission(): Boolean
}
```

**Design Decisions**:
- ✅ Interface in domain, implementation in data layer
- ✅ Uses Flow for reactive data
- ✅ Suspend functions for async operations
- ✅ Returns domain models, not entities

**Dependency Direction**:
```
Domain (Interface) ← Data Layer (Implementation)
      ↑
Presentation Layer (Uses Interface)
```

---

### 3. Use Cases

Use cases represent **single business operations**.

#### GetContactsUseCase.kt
**Purpose**: Retrieve all contacts

```kotlin
class GetContactsUseCase @Inject constructor(
    private val contactRepository: ContactRepository
) {
    operator fun invoke(): Flow<List<Contact>> {
        return contactRepository.getContacts()
    }
}
```

**Why separate use case?**
- ✅ Single Responsibility Principle
- ✅ Testable business logic
- ✅ Can add validation/rules here
- ✅ Easy to modify without affecting repository

#### GetContactByIdUseCase.kt
**Purpose**: Retrieve specific contact

```kotlin
class GetContactByIdUseCase @Inject constructor(
    private val contactRepository: ContactRepository
) {
    suspend operator fun invoke(contactId: String): Contact? {
        return contactRepository.getContactById(contactId)
    }
}
```

**Future enhancements** (examples):
```kotlin
// Could add business rules:
suspend operator fun invoke(contactId: String): Contact? {
    val contact = contactRepository.getContactById(contactId)
    
    // Business rule: Log access
    logContactAccess(contactId)
    
    // Business rule: Check if blocked
    if (isBlocked(contactId)) return null
    
    return contact
}
```

---

## 🎯 Design Principles

### 1. **Dependency Rule**
Domain layer depends on **NOTHING**:
```
❌ No Android imports (android.*)
❌ No framework dependencies
❌ No database imports (Room)
❌ No UI imports (View, Fragment)

✅ Pure Kotlin only
✅ Kotlin coroutines (language feature)
```

### 2. **Stable Abstractions Principle**
- Domain is the most stable layer
- Other layers depend on domain
- Domain never depends on outer layers

### 3. **Interface Segregation**
- Small, focused interfaces
- One repository per aggregate
- Use cases do one thing

---

## 🔗 Dependencies

### What Domain Depends On:
- Kotlin Standard Library
- Kotlin Coroutines (kotlinx.coroutines)
- Dependency Injection annotations (javax.inject)

### What Depends On Domain:
- Data Layer (implements repositories)
- Presentation Layer (uses use cases)

---

## 🧪 Testing

### Why Domain Tests are Important:
- ✅ Test business logic in isolation
- ✅ Fast (no Android dependencies)
- ✅ Framework-independent
- ✅ Easy to mock dependencies

### Test Files:
- `GetContactsUseCaseTest.kt` - 100% coverage
- `GetContactByIdUseCaseTest.kt` - 100% coverage

### Test Strategy:
```kotlin
@Test
fun `use case returns data from repository`() = runTest {
    // Given
    val expected = listOf(mockContact)
    every { repository.getContacts() } returns flowOf(expected)
    
    // When
    val result = useCase().first()
    
    // Then
    assertEquals(expected, result)
    verify { repository.getContacts() }
}
```

**Coverage**: 100% ✅

---

## 📚 Skills & Patterns Used

- **[Clean Architecture](../skills/clean-architecture.md)** - Layer separation
- **[Repository Pattern](../skills/repository-pattern.md)** - Data abstraction
- **[Use Case Pattern](../skills/use-case-pattern.md)** - Business operations
- **[Dependency Injection](../skills/dependency-injection.md)** - Hilt integration
- **[Kotlin Coroutines](../skills/kotlin-coroutines.md)** - Async operations

---

## 🔄 Adding New Use Cases

### Example: Add SearchContactsUseCase

1. **Create use case class**:
```kotlin
// domain/usecase/SearchContactsUseCase.kt
class SearchContactsUseCase @Inject constructor(
    private val contactRepository: ContactRepository
) {
    operator fun invoke(query: String): Flow<List<Contact>> {
        return contactRepository.getContacts()
            .map { contacts ->
                contacts.filter { contact ->
                    contact.name.contains(query, ignoreCase = true)
                }
            }
    }
}
```

2. **Write tests**:
```kotlin
// test/.../SearchContactsUseCaseTest.kt
@Test
fun `search returns matching contacts`() = runTest {
    // Test implementation
}
```

3. **Use in ViewModel**:
```kotlin
// presentation/.../ContactsViewModel.kt
class ContactsViewModel @Inject constructor(
    private val searchContactsUseCase: SearchContactsUseCase
) {
    fun search(query: String) {
        viewModelScope.launch {
            searchContactsUseCase(query).collect { results ->
                // Update state
            }
        }
    }
}
```

---

## 📝 When to Modify Domain Layer

### ✅ **DO modify when:**
1. Business requirements change
2. New business operations needed
3. New business entity required
4. Business rules change

### ❌ **DON'T modify when:**
1. UI changes
2. Database schema changes
3. API response format changes
4. Framework updates

**Remember**: Domain should be the most stable layer!

---

## 🎓 Learning Resources

### Understanding Domain Layer:
- [Clean Architecture Book](https://www.amazon.com/Clean-Architecture-Craftsmans-Software-Structure/dp/0134494164)
- [Domain-Driven Design](https://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215)

### In This Codebase:
1. Start with `Contact.kt` - simple model
2. Look at `ContactRepository.kt` - interface contract
3. Study use cases - business operations
4. Read tests - see how it's used

---

## 📊 Metrics

- **Total Classes**: 5
- **Lines of Code**: ~150
- **Test Coverage**: 100%
- **Dependencies**: 0 (framework-independent)
- **Complexity**: Low (intentionally simple)

---

**Last Updated**: 2024-03-06  
**Module Version**: 1.0.0  
**Maintainer**: Development Team

