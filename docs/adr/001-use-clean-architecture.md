# ADR 001: Use Clean Architecture

## Status
✅ **Accepted** - Implemented in project

## Context

We're building a complex contact management application that needs to:
- Support multiple features (contacts, messaging, future features)
- Be maintainable by multiple developers
- Have high test coverage
- Be independent of Android framework for business logic
- Allow easy modification without breaking other parts

The question: **What architectural pattern should we use?**

---

## Options Considered

### Option 1: No Specific Architecture (Activity/Fragment + Direct DB)
**Approach**: Put logic directly in Activities/Fragments, call database directly

**Pros**:
- Simple to start
- Less boilerplate
- Faster initial development

**Cons**:
- ❌ Hard to test (Android dependencies)
- ❌ Tight coupling
- ❌ Difficult to maintain as app grows
- ❌ Business logic mixed with UI
- ❌ Can't reuse logic across features

---

### Option 2: MVVM Only
**Approach**: Use ViewModel + Repository pattern

**Pros**:
- Separates UI from business logic
- Android-recommended
- Lifecycle-aware
- Testable ViewModels

**Cons**:
- ❌ Still coupled to Android (Repository in data layer)
- ❌ No clear business logic layer
- ❌ Repository can become God object
- ❌ Hard to enforce rules

---

### Option 3: Clean Architecture + MVVM ✅ **CHOSEN**
**Approach**: Three layers (Domain, Data, Presentation) with MVVM in presentation

**Pros**:
- ✅ Framework-independent business logic
- ✅ Clear separation of concerns
- ✅ Highly testable (domain layer is pure Kotlin)
- ✅ Scalable (easy to add features)
- ✅ Enforces dependency rules
- ✅ Use cases encapsulate business operations
- ✅ Easy to swap implementations

**Cons**:
- More files/classes needed
- Steeper learning curve
- Initial setup takes longer

---

## Decision

**We chose Clean Architecture with MVVM in the presentation layer.**

### Why?

1. **Testability**: Domain layer has 100% test coverage without Android dependencies
2. **Scalability**: Easy to add new features as separate modules
3. **Maintainability**: Clear where each piece of logic goes
4. **Team Size**: Multiple developers can work without stepping on each other
5. **Future-Proof**: Can change UI framework or database without touching business logic

### Architecture Layers:

```
┌─────────────────────────────────────┐
│      Presentation Layer             │
│  (UI, ViewModels, Fragments)        │
│  Framework: Android                 │
└─────────────────────────────────────┘
              ↕ ↕ ↕
┌─────────────────────────────────────┐
│        Domain Layer                 │
│  (Entities, Use Cases, Interfaces)  │
│  Framework: None (Pure Kotlin)      │
└─────────────────────────────────────┘
              ↕ ↕ ↕
┌─────────────────────────────────────┐
│         Data Layer                  │
│  (Repository Impl, Data Sources)    │
│  Framework: Room, ContentProvider   │
└─────────────────────────────────────┘
```

### Dependency Rule:
- **Inner layers don't know about outer layers**
- Domain depends on nothing
- Data depends on domain (implements interfaces)
- Presentation depends on domain (uses use cases)

---

## Consequences

### Positive Consequences ✅

1. **Testability**
   - Domain layer: 100% coverage, fast tests, no Android deps
   - Data layer: Can mock repositories easily
   - Presentation: Can mock use cases

2. **Maintainability**
   - Clear where to put new code
   - Changes isolated to specific layers
   - Easy to find and fix bugs

3. **Scalability**
   - Add features without affecting existing code
   - Multiple developers can work simultaneously
   - Easy to split into modules later

4. **Flexibility**
   - Can change UI (Compose, XML, etc.)
   - Can swap database (Room, Realm, etc.)
   - Can add remote API without changing domain

5. **Business Logic Clarity**
   - Use cases clearly define what app does
   - Models represent business concepts
   - Rules enforced at domain level

### Negative Consequences ❌

1. **More Boilerplate**
   - Need entities, models, mappers
   - More files/packages
   - Initial setup time

2. **Learning Curve**
   - Team needs to understand architecture
   - Need training/documentation
   - Requires discipline to maintain

3. **Over-Engineering Risk**
   - Could be overkill for very simple apps
   - Need to resist adding unnecessary layers

### Mitigation Strategies:

1. **Documentation**
   - Created ARCHITECTURE.md
   - Module-specific docs
   - Skills documentation

2. **Templates**
   - Provide templates for new features
   - Code generation scripts (future)

3. **Code Reviews**
   - Enforce architecture in PRs
   - Share knowledge

---

## Implementation Notes

### Package Structure:
```
com.ai.codefixchallange/
├── domain/
│   ├── model/          # Business entities
│   ├── repository/     # Interfaces
│   └── usecase/        # Business operations
├── data/
│   ├── local/          # Room database
│   ├── mapper/         # Entity ↔ Model
│   ├── repository/     # Implementations
│   └── source/         # Data sources
└── presentation/
    ├── contacts/       # Feature screens
    └── detail/
```

### Key Rules:
1. Domain layer has NO Android imports
2. Use cases are single responsibility
3. Repository interfaces in domain, implementations in data
4. ViewModels use use cases, not repositories directly
5. Mappers convert between layers

### Testing Strategy:
- Domain: Unit tests (fast, no Android)
- Data: Unit tests with mocks
- Presentation: ViewModel tests
- Integration: End-to-end tests

---

## Examples in Codebase

### Domain Layer Example:
```kotlin
// domain/usecase/GetContactsUseCase.kt
class GetContactsUseCase @Inject constructor(
    private val contactRepository: ContactRepository  // Interface, not impl
) {
    operator fun invoke(): Flow<List<Contact>> {
        return contactRepository.getContacts()
    }
}
```

### Data Layer Example:
```kotlin
// data/repository/ContactRepositoryImpl.kt
class ContactRepositoryImpl @Inject constructor(
    private val contactDao: ContactDao,
    private val contactDataSource: ContactDataSource
) : ContactRepository {  // Implements domain interface
    override fun getContacts(): Flow<List<Contact>> {
        return contactDao.getAllContacts()
            .map { it.toDomainList() }
    }
}
```

### Presentation Layer Example:
```kotlin
// presentation/contacts/ContactsViewModel.kt
@HiltViewModel
class ContactsViewModel @Inject constructor(
    private val getContactsUseCase: GetContactsUseCase  // Uses use case
) : ViewModel() {
    // Business logic through use case
}
```

---

## Alternatives Rejected

### Why not MVC?
- Business logic mixed with controllers
- Hard to test
- Not suitable for complex apps

### Why not MVP?
- Presenter tightly coupled to view interface
- More boilerplate than MVVM
- Less Android support

### Why not MVI?
- More complex state management
- Steeper learning curve
- Clean Architecture gives us similar benefits

---

## Date
2024-03-06

## Authors
- Development Team

## References
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Android Architecture Guide](https://developer.android.com/topic/architecture)
- [ARCHITECTURE.md](../../ARCHITECTURE.md)

## Related ADRs
- [ADR-002: Choose Hilt over Dagger](002-choose-hilt-over-dagger.md)
- [ADR-003: Use StateFlow over LiveData](003-use-stateflow-over-livedata.md)

