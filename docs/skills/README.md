# Skills Documentation Index

This directory contains documentation about **how specific technologies and patterns are used** in this project.

## 📚 Purpose

Skills docs explain:
- ✅ HOW we use a technology
- ✅ Patterns and examples from OUR codebase
- ✅ Best practices WE follow
- ✅ Where to find examples in code

Skills docs DO NOT explain:
- ❌ General tutorials (use official docs for that)
- ❌ Every implementation detail
- ❌ Bug fixes or changes

---

## 🎯 Available Skills

### Architecture & Patterns
- **[Clean Architecture](clean-architecture.md)** - Layer separation and dependency rules
- **[MVVM Pattern](mvvm-pattern.md)** - Model-View-ViewModel implementation
- **[Repository Pattern](repository-pattern.md)** - Data abstraction strategy
- **[Use Case Pattern](use-case-pattern.md)** - Business logic encapsulation

### Dependency Injection
- **[Dependency Injection with Hilt](dependency-injection.md)** - DI setup and usage

### Asynchronous Programming
- **[Kotlin Coroutines](kotlin-coroutines.md)** - Async operations with coroutines
- **[Flow & StateFlow](flow-and-stateflow.md)** - Reactive data streams

### Android Components
- **[Navigation Component](navigation-component.md)** - Fragment navigation
- **[RecyclerView with DiffUtil](recyclerview-diffutil.md)** - Efficient lists
- **[ViewBinding](viewbinding.md)** - Type-safe view access
- **[Room Database](room-database.md)** - Local data persistence

### Platform Features
- **[Runtime Permissions](permissions.md)** - Permission handling
- **[Content Providers](content-providers.md)** - Accessing device data

### Testing
- **[Testing Strategy](testing-strategy.md)** - How we test
- **[Unit Testing](unit-testing.md)** - Testing business logic
- **[ViewModel Testing](viewmodel-testing.md)** - Testing presentation logic

---

## 🔍 How to Use These Docs

### Example: "I need to add a new screen"

**Path**: 
1. Read [MVVM Pattern](mvvm-pattern.md) - Understand ViewModel
2. Read [Navigation Component](navigation-component.md) - Add navigation
3. Check [contacts-feature.md](../modules/contacts-feature.md) - See existing example

### Example: "I need to fetch data from API"

**Path**:
1. Read [Repository Pattern](repository-pattern.md) - Data abstraction
2. Read [Kotlin Coroutines](kotlin-coroutines.md) - Async calls
3. Read [Clean Architecture](clean-architecture.md) - Where to put code

### Example: "I need to add a database table"

**Path**:
1. Read [Room Database](room-database.md) - Database setup
2. Read [Repository Pattern](repository-pattern.md) - Integrate with repo
3. Check [data-layer.md](../modules/data-layer.md) - See existing setup

---

## 📝 Format of Skills Docs

Each skill document follows this structure:

```markdown
# Skill Name

## Overview
Brief explanation of what it is

## How We Use It
Our specific approach

## Code Examples
Real examples from this codebase with file paths

## Patterns We Follow
Conventions and patterns

## Where Used
List of modules/files using this

## Common Scenarios
How to accomplish common tasks

## Troubleshooting
Common issues and solutions
```

---

## 🔄 When to Update

### ✅ Update when:
- Major pattern/approach changes
- New technology added
- Best practices evolve
- Significant refactoring completed

### ❌ Don't update for:
- Bug fixes
- Minor refactoring
- Experimenting (update after deciding)
- Implementation details

---

## 🎓 Learning Path

### For New Developers:

**Week 1**: Foundation
1. [Clean Architecture](clean-architecture.md)
2. [MVVM Pattern](mvvm-pattern.md)
3. [Dependency Injection](dependency-injection.md)

**Week 2**: Android Specifics
1. [Navigation Component](navigation-component.md)
2. [RecyclerView with DiffUtil](recyclerview-diffutil.md)
3. [ViewBinding](viewbinding.md)

**Week 3**: Advanced
1. [Kotlin Coroutines](kotlin-coroutines.md)
2. [Flow & StateFlow](flow-and-stateflow.md)
3. [Testing Strategy](testing-strategy.md)

---

## 📚 External Resources

While our docs focus on OUR usage, here are official resources:

- [Android Developers](https://developer.android.com/)
- [Kotlin Documentation](https://kotlinlang.org/docs/home.html)
- [Clean Architecture Blog](https://blog.cleancoder.com/)

---

**Last Updated**: 2024-03-06  
**Skills Count**: 15+  
**Status**: Living Documentation

