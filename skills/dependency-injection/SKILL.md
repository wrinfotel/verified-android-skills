---
name: dependency-injection
description: >
  Hilt dependency-injection discipline for Android: constructor injection
  first, field injection only in entry points, @HiltViewModel with an
  @Inject constructor, module annotations, and no ViewModels passed to
  other classes. Use when writing or reviewing DI wiring (Hilt, Dagger,
  manual DI). Core rules have machine checks in checks/.
version: 0.1.0
---

# Dependency Injection

Operational rules for a coding agent. RIGHT/WRONG pairs are canonical.
After ANY DI wiring edit, run the Verification step (bottom of this file).

## 1. Field injection only in entry points

MUST use constructor injection for regular classes — it keeps dependencies
in the API surface and testable. Field injection exists only because
system-instantiated Android classes (Application, Activity, Service,
BroadcastReceiver, ViewModel) cannot take constructor parameters: those
classes MUST be Hilt entry points — `@AndroidEntryPoint` (or
`@HiltAndroidApp` for the Application) — for their `@Inject` fields to be
populated. A `@Inject lateinit var` in a class that is not an entry point
stays null and crashes at runtime.

WRONG:
```kotlin
class LoginActivity : AppCompatActivity() {
    @Inject
    lateinit var loginRepository: LoginRepository   // never populated
}
```

RIGHT:
```kotlin
@AndroidEntryPoint
class LoginActivity : AppCompatActivity() {
    @Inject
    lateinit var loginRepository: LoginRepository
}

class UserRepository @Inject constructor(
    private val api: UserApi,
)
```

WHY: "Hilt can provide dependencies to other Android classes that have the
@AndroidEntryPoint annotation" — without it there is no container to inject
from. The DI guide prefers constructor injection for everything else:
dependencies stay verifiable at compile time instead of hidden.

## 2. @HiltViewModel requires an @Inject constructor

MUST annotate the ViewModel constructor with `@Inject`: "Provide a
ViewModel by annotating it with @HiltViewModel and using the @Inject
annotation in the ViewModel object's constructor." The UI obtains it
through `hiltViewModel()` (Compose) or `by viewModels()` — never by
constructing it.

WRONG:
```kotlin
@HiltViewModel
class ProfileViewModel(
    private val userRepository: UserRepository
) : ViewModel()
```

RIGHT:
```kotlin
@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val userRepository: UserRepository
) : ViewModel()
```

WHY: @HiltViewModel only registers the ViewModel with the
ViewModelComponent; the @Inject constructor is what tells Hilt how to
build it. Without it the project fails to compile.

## 3. Providers live inside modules

MUST put `@Provides` / `@Binds` methods inside a class annotated
`@Module` — and every module MUST also carry `@InstallIn(Component::class)`
to say where it is installed. `@Binds` goes in an `abstract class` module
(interface → implementation); `@Provides` goes in an `object` module
(third-party classes, builders).

WRONG:
```kotlin
class DataModule {                       // missing @Module
    @Provides
    fun provideAnalyticsService(): AnalyticsService = AnalyticsServiceImpl()
}
```

RIGHT:
```kotlin
@Module
@InstallIn(SingletonComponent::class)
object DataModule {
    @Provides
    fun provideAnalyticsService(): AnalyticsService = AnalyticsServiceImpl()
}
```

## 4. ViewModels are not dependencies

MUST NOT pass a ViewModel to other classes — including another ViewModel's
constructor: "Don't pass ViewModels to other classes, functions or other
UI components. Because the platform manages them, you should keep them as
close to it as you can." A ViewModel that needs another screen's state
should share a repository (or an activity-scoped ViewModel obtained by the
owner), not receive a ViewModel via injection.

WRONG:
```kotlin
@HiltViewModel
class ProfileViewModel(
    private val userViewModel: UserViewModel   // ViewModel as a dependency
) : ViewModel()
```

RIGHT:
```kotlin
@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val userRepository: UserRepository  // share data, not ViewModels
) : ViewModel()
```

## 5. What the checks cannot see (review-verified)

- Manual DI is legitimate for small apps (the guide documents it); the
  service-locator pattern is the discouraged middle ground — global state
  that makes tests interact with the same locator.
- Scoping choices (`@Singleton`, `@ViewModelScoped`, custom components)
  and module organization across Gradle modules — verified by review.

## Verification

Run after every DI wiring edit (from the project root):

```bash
bash <skill-dir>/checks/check_field_injection_entry_point.sh <kotlin-src-dir>
bash <skill-dir>/checks/check_hilt_viewmodel_inject.sh       <kotlin-src-dir>
bash <skill-dir>/checks/check_provides_in_module.sh          <kotlin-src-dir>
bash <skill-dir>/checks/check_no_viewmodel_in_viewmodel.sh   <kotlin-src-dir>
```

All four must pass (exit 0) before declaring the task done. Checks are
deterministic heuristics — they catch the documented anti-patterns above,
not every DI bug. §5 is verified by review against references/di.md.
