# Kotlin / Jetpack Compose KISS Guidelines

## Goal

Keep Android apps simple, idiomatic, and maintainable without introducing unnecessary architectural layers.

The default should be:

```text
Compose
   ↓
ViewModel
   ↓
Repository
   ↓
Room / DataStore / API

+ Coroutines / Flow
+ small pure domain functions where useful
+ Navigation only when needed
```

Avoid adding abstractions preemptively. Every additional layer, interface, wrapper, module, or model should solve a concrete problem that exists today.

---

## KISS Rules

### 1. Treat UI and Data as the default required layers

Start with:

```text
UI
↓
ViewModel
↓
Repository / Data source
```

Add a separate domain/use-case layer only when business logic is complex, shared, or clearly simplifies multiple ViewModels.

Do not introduce a domain layer just because an architecture diagram contains one.

---

### 2. Repositories are not DAO wrappers

A repository should represent a meaningful data/application boundary.

Prefer repositories grouped by responsibility or feature rather than automatically creating one repository per DAO or entity.

A repository may coordinate multiple DAOs, DataStore, remote APIs, caches, or transactions.

If a repository only forwards every call 1:1 to a DAO and adds no value, consider removing it.

---

### 3. DAOs should follow database access needs

Do not enforce:

```text
1 Entity = 1 DAO
```

A DAO may work with multiple entities if the queries belong together.

Entities describe stored data.

DAOs describe database operations.

Repositories describe application-facing data operations.

These do not need to have matching counts or structure.

---

### 4. Use ViewModels at screen/destination level

Do not create one ViewModel per small composable.

A ViewModel should primarily:

- expose screen-level UI state
- combine data needed by the screen
- react to meaningful UI actions
- launch lifecycle-aware coroutines
- call repositories or domain logic

Reusable UI components should usually receive state and callbacks directly.

---

### 5. Keep state as close to its consumer as possible

Local UI state belongs in Compose when only the local UI needs it.

Use `remember` / `rememberSaveable` for things such as:

- expanded/collapsed state
- local animation state
- temporary input state
- selection state local to one component

Hoist state only as far as required.

Do not move every piece of UI state into a ViewModel.

---

### 6. Keep Unidirectional Data Flow simple

Prefer:

```text
State ↓
UI
Events ↑
```

Do not introduce an MVI framework, reducer system, event bus, or command architecture unless the app actually benefits from it.

---

### 7. Prefer normal ViewModel methods over generic event systems

Prefer:

```kotlin
viewModel.deleteItem(id)
viewModel.completeItem(id)
```

over:

```kotlin
viewModel.onEvent(UiEvent.DeleteItem(id))
```

unless unified event handling solves a real problem.

---

### 8. Do not create trivial UseCase classes

Avoid use cases that only delegate:

```text
DeleteItemUseCase
    ↓
repository.deleteItem()
```

Create dedicated domain/use-case logic when it:

- contains meaningful business rules
- is reused by multiple ViewModels/features
- significantly simplifies callers
- is independently valuable to test

Small pure domain functions are often enough.

---

### 9. Do not create interfaces without a concrete reason

Avoid this by default:

```text
TodoRepository
TodoRepositoryImpl
```

when there is only one implementation.

Extract an interface later when there is an actual need, such as:

- multiple implementations
- a useful test boundary
- platform-specific implementations
- meaningful runtime substitution

Do not design for hypothetical future implementations.

---

### 10. Avoid model and mapper chains without semantic differences

Do not automatically create:

```text
Entity
↓
DataModel
↓
DomainModel
↓
UiModel
```

if all of them contain the same data.

Reuse models across layers when their meaning and shape are genuinely the same.

Introduce separate models only when persistence, domain, API, or UI representations materially differ.

Likewise, do not create mappers when there is nothing meaningful to map.

---

### 11. Use Room and DataStore for their intended jobs

Use **Room** for structured application data:

- relational data
- lists/collections
- queries
- transactions
- partial updates
- durable application state

Use **DataStore** for small settings/preferences:

- booleans
- simple user preferences
- small typed configuration values

Do not force one tool to replace the other.

---

### 12. Prefer Coroutines and Flow over custom async abstractions

Use the platform ecosystem first:

- `suspend`
- `CoroutineScope`
- `viewModelScope`
- `Flow`
- `StateFlow`

Avoid inventing additional observable/promise/resource layers unless they solve a concrete need.

---

### 13. Model errors only when callers need them

Do not wrap everything in generic containers such as:

```text
Result<Resource<DataState<T>>>
```

Use the simplest type that represents the actual contract.

If a screen only needs:

```kotlin
Flow<List<Item>>
```

then that may be enough.

Add explicit loading/error states only where they are meaningful.

---

### 14. Start with manual dependency injection

For small apps, constructor injection and a small application container are often sufficient.

Do not add Hilt or Koin just because they are common in tutorials.

Introduce a DI framework when:

- the dependency graph becomes difficult to wire manually
- scopes/lifetimes become complex
- testing setup becomes unnecessarily painful
- the framework removes more complexity than it adds

---

### 15. Prefer composition over base classes

Be suspicious of:

```text
BaseViewModel
BaseRepository
BaseScreen
BaseUseCase
```

Prefer:

- small functions
- composition
- extension functions
- focused classes

Use inheritance only when there is real shared behavior and a clear is-a relationship.

---

### 16. Do not put every Composable in its own file

A screen file may contain several small private composables.

Extract a composable into its own file when it:

- is reused
- becomes independently complex
- has a clear standalone responsibility
- benefits from isolated testing or previewing

File count is not architecture quality.

---

### 17. Keep the design system proportional to the app

A small design system is useful:

```text
theme/
- Color
- Typography
- Theme
- Dimensions
```

and genuinely reusable app-specific components.

Avoid wrapping every Compose primitive purely to enforce indirection.

Do not create wrappers around `Text`, `Row`, `Button`, etc. unless they encode meaningful shared behavior or styling.

---

### 18. Keep navigation direct while it is simple

Use the standard Navigation APIs directly while the navigation graph is small and understandable.

Avoid introducing abstractions such as:

```text
NavigationManager
NavigationService
RouteFactory
NavigatorCommand
```

until navigation complexity actually requires them.

---

### 19. Organize packages by cohesion, not Java-era class categories

Prefer code that changes together to live together.

Avoid excessive global buckets such as:

```text
controllers/
services/
interfaces/
implementations/
mappers/
utils/
```

Prefer shallow, feature- or responsibility-oriented packages.

Package names should describe what the code does, not merely what class type it is.

---

### 20. Default to a single Gradle module for small apps

Do not preemptively create:

```text
:core
:domain
:data
:feature:x
:feature:y
```

for a small application.

Additional Gradle modules are useful when they solve real problems such as:

- large team ownership boundaries
- independent build/test units
- reusable libraries
- significantly improved build performance
- strong feature isolation requirements

Packages are usually enough for smaller apps.

---

### 21. Keep Activities and Application classes thin

KISS does not mean putting everything into `MainActivity`.

Activities should primarily host UI and interact with Android lifecycle/platform boundaries.

Do not place persistent application state, database logic, or substantial business rules directly in Activities.

---

### 22. Require every abstraction to justify itself

Before adding a new:

- layer
- interface
- wrapper
- module
- mapper
- state holder
- base class
- framework

ask:

> What concrete duplication, coupling, lifecycle problem, testability problem, or complexity does this solve today?

If the answer is only:

- “best practice”
- “clean architecture”
- “we might need it later”

do not add it yet.

---

## Practical Default Architecture

For many small and medium-sized Android apps, a good default is:

```text
Compose UI
    ↓
Screen ViewModel
    ↓
Repository
    ↓
DAO / DataStore / API
    ↓
Room / persistent storage

Pure business rules can live beside this as small,
independent Kotlin functions/classes.
```

This already supports:

- separation of concerns
- lifecycle-aware state
- single source of truth
- unidirectional data flow
- testable business logic
- maintainable persistence boundaries

without requiring a large Clean Architecture stack.

---

## Warning Signs of Over-Abstraction

Be cautious when a small app starts accumulating:

```text
UseCase classes for one-line delegation
Repository interfaces with one implementation
RepositoryImpl suffixes everywhere
DataSource interfaces and implementations
DTO → Entity → Domain → UI model chains
Mapper classes with 1:1 field copies
BaseViewModel / BaseRepository / BaseUseCase
generic Resource wrappers around every value
one ViewModel per small component
one Gradle module per screen
custom navigation managers
custom event buses
DI frameworks for a handful of objects
```

Any of these can be valid in the right context.

None of them should be introduced automatically.

---

## Five Rules for Coding Agents

When an AI coding agent contributes to the project, use these as hard defaults:

1. **Prefer shallow architecture.**
2. **Do not introduce speculative abstractions.**
3. **Use ViewModels at screen/destination level, not component level.**
4. **Use repositories as meaningful data/application boundaries, not mandatory DAO wrappers.**
5. **Keep state as close to its consumer as possible.**

Additionally:

> Before introducing an abstraction, state in one sentence what concrete duplication, coupling, lifecycle problem, testability problem, or complexity it solves today. If you cannot, do not introduce it.

---

## Official References

### Android architecture

- **Guide to app architecture**  
  https://developer.android.com/topic/architecture

- **Architecture recommendations**  
  https://developer.android.com/topic/architecture/recommendations

- **UI layer**  
  https://developer.android.com/topic/architecture/ui-layer

- **Domain layer**  
  https://developer.android.com/topic/architecture/domain-layer

### Compose state

- **State and Jetpack Compose**  
  https://developer.android.com/develop/ui/compose/state

- **State hoisting in Compose**  
  https://developer.android.com/develop/ui/compose/state-hoisting

### ViewModel

- **ViewModel overview**  
  https://developer.android.com/topic/libraries/architecture/viewmodel

### Persistence

- **Room**  
  https://developer.android.com/training/data-storage/room

- **DataStore**  
  https://developer.android.com/topic/libraries/architecture/datastore

### Modularization

- **Guide to Android app modularization**  
  https://developer.android.com/topic/modularization

- **Common modularization patterns**  
  https://developer.android.com/topic/modularization/patterns

### Dependency injection

- **Dependency injection in Android**  
  https://developer.android.com/training/dependency-injection

- **Hilt**  
  https://developer.android.com/training/dependency-injection/hilt-android

### Kotlin

- **Kotlin coding conventions**  
  https://kotlinlang.org/docs/coding-conventions.html

---

## Guiding Principle

> Use the simplest architecture that cleanly solves the current requirements.

Good Android architecture should make the code easier to understand and change.

If the architecture itself becomes one of the hardest parts of understanding the application, it is probably too complex.
