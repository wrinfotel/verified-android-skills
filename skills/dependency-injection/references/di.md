# Dependency injection — primary sources

Distilled index. Rule text lives in SKILL.md; this file exists so the agent
(and reviewers) can verify every rule against its origin.

1. **DI in Android** — constructor vs field injection ("Certain Android
   framework classes such as activities and fragments are instantiated by
   the system, so constructor injection is not possible"); Hilt is
   "Jetpack's recommended library for dependency injection in Android";
   service locator criticized: "all the tests have to interact with the
   same global service locator"; benefits: reusability, refactoring,
   testing.
   https://developer.android.com/training/dependency-injection

2. **Hilt fundamentals** — "All apps that use Hilt must contain an
   Application class that is annotated with @HiltAndroidApp"; @AndroidEntryPoint
   supports Application, ViewModel, Activity, Service, BroadcastReceiver
   ("Hilt only supports activities that extend ComponentActivity"); field
   injection example `@Inject lateinit var analytics: AnalyticsAdapter`
   inside an @AndroidEntryPoint class; "Use the @Inject annotation on the
   constructor of a class to tell Hilt how to provide instances of that
   class"; modules: "@Module ... You must also annotate every module with
   @InstallIn"; @Binds in abstract class modules, @Provides in object
   modules.
   https://developer.android.com/training/dependency-injection/hilt-android

3. **Hilt + Jetpack** — "Provide a ViewModel by annotating it with
   @HiltViewModel and using the @Inject annotation in the ViewModel
   object's constructor"; obtained via `by viewModels()` in an
   @AndroidEntryPoint activity.
   https://developer.android.com/training/dependency-injection/hilt-jetpack

4. **ViewModel best practices** — "Don't pass ViewModels to other classes,
   functions or other UI components. Because the platform manages them,
   you should keep them as close to it as you can"; ViewModels shouldn't
   hold lifecycle-related references (Context, Resources). SKILL.md §4
   applies the first rule to constructor injection of one ViewModel into
   another.
   https://developer.android.com/topic/libraries/architecture/viewmodel

Format precedent (terse, imperative, RIGHT/WRONG pairs, verification
checklist) reviewed from Apache-2.0/MIT projects listed in NOTICE.
