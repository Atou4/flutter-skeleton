# Flutter Skeleton

A production-ready Flutter starter project with clean architecture, dependency injection, typed routing, and state management already wired together. Fork it, rename it, and start building.

## Architecture Overview

```
lib/
├── bootstrap.dart              # App lifecycle: bindings, DI, error handling, runApp
├── main_development.dart       # Dev flavor entry point
├── main_staging.dart           # Staging flavor entry point
├── main_production.dart        # Production flavor entry point
├── core/
│   ├── configs/                # AppConfig (flavors, endpoints), Environment (dart-defines)
│   ├── const/                  # App-wide constants
│   ├── entities/               # Shared domain entities
│   ├── enums/                  # Shared enums (UserRole, etc.)
│   ├── exceptions/             # AppException hierarchy and Failure types
│   ├── network/                # ErrorHandler, AuthInterceptor, RepositoryHelper
│   ├── services/               # Abstract + concrete services
│   │   ├── analytics/          # AnalyticsClient interface + facade + logger impl
│   │   ├── crashlytics/        # CrashlyticsService interface + NoOp impl
│   │   ├── local_storage/      # LocalStorageService + SharedPreferences impl
│   │   ├── network/            # NetworkAdapter (connectivity stream)
│   │   └── secure_storage/     # SecureStorageService (flutter_secure_storage)
│   └── utils/                  # Logging, validators
├── di/
│   ├── di_container.dart       # GetIt singleton
│   ├── di_initializer.dart     # Injector.init() wiring order
│   └── modules/                # ServiceModule, DioModule, BlocModule
├── features/
│   ├── app/presentation/       # Root App widget with MultiBlocProvider + MaterialApp.router
│   ├── auth/                   # Generic auth shell (repository, cubit, splash/welcome screens)
│   ├── sample_feature/         # Reference feature: entity -> repository -> cubit -> screen
│   └── shared/                 # BaseCubit, LanguageCubit
├── l10n/                       # Localization (ARB files + generated code)
└── navigation/
    ├── app_router.dart         # GoRouter config with auth redirect
    ├── routes_shell.dart       # Shell mode: bottom nav with persistent tabs
    └── routes_flat.dart        # Flat mode: simple stack navigation
```

## Startup Flow

```
main_<flavor>.dart
  └─ bootstrap()
       ├─ WidgetsFlutterBinding.ensureInitialized()
       ├─ AppConfig.config<Flavor>()
       ├─ Bloc.observer = AppBlocObserver()
       ├─ Injector.init()
       │    ├─ ServiceModule   (analytics, crashlytics, storage, router)
       │    ├─ DioModule       (base Dio with logger)
       │    ├─ BlocModule      (AuthCubit, LanguageCubit)
       │    └─ DioModule       (auth interceptor)
       ├─ CrashlyticsService.init()
       ├─ FlutterError.onError + PlatformDispatcher.onError
       └─ runApp(App())
```

## Requirements

- Flutter SDK >= 3.8.0
- Dart SDK >= 3.8.0

## Getting Started

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Generate code (routes, JSON serialization)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Generate localization files

```bash
flutter gen-l10n
```

### 4. Run the app

Each flavor uses `--dart-define` for compile-time environment variables:

```bash
# Development
flutter run \
  --target lib/main_development.dart \
  --dart-define=FLUTTER_APP_FLAVOR=development \
  --dart-define=REST_API_URL=https://dev-api.example.com

# Staging
flutter run \
  --target lib/main_staging.dart \
  --dart-define=FLUTTER_APP_FLAVOR=staging \
  --dart-define=REST_API_URL=https://staging-api.example.com

# Production
flutter run \
  --target lib/main_production.dart \
  --dart-define=FLUTTER_APP_FLAVOR=production \
  --dart-define=REST_API_URL=https://api.example.com
```

## Environment Variables (--dart-define)

| Variable | Required | Description |
|---|---|---|
| `FLUTTER_APP_FLAVOR` | Yes | `development`, `staging`, or `production` |
| `REST_API_URL` | Yes | Base URL for the REST API |

## Adding a New Feature

Follow the same structure as `features/sample_feature/`:

```
features/your_feature/
├── domain/
│   ├── entities/          # Pure Dart classes (Equatable)
│   └── repositories/      # Abstract repository contract
├── data/
│   ├── datasource/remote/ # Retrofit data source
│   ├── models/            # JSON-serializable response models
│   └── repositories/      # Repository implementation using RepositoryHelper
└── presentation/
    ├── cubit/             # Cubit + sealed state
    └── screens/           # Widgets
```

### Wiring checklist:

1. Create the data source, model, repository contract, and implementation.
2. Register the data source and repository in a new DI module (or extend existing ones).
3. Create the cubit and register it in `BlocModule`.
4. Add a typed route in `navigation/routes_shell.dart` or `routes_flat.dart` and run `build_runner`.
5. Provide the cubit via `BlocProvider` in the route builder.

## Optional Integrations

### Firebase

1. Add `firebase_core`, `firebase_crashlytics`, `firebase_analytics`, and `firebase_messaging` to `pubspec.yaml`.
2. Run `flutterfire configure` to generate `firebase_options.dart`.
3. Replace `NoOpCrashlyticsService` with a `FirebaseCrashlyticsService` in `di_service_module.dart`.
4. Initialize Firebase in `bootstrap.dart` before `Injector.init()`.

### Social Authentication

1. Add `google_sign_in` and/or `sign_in_with_apple` to `pubspec.yaml`.
2. Create a `SocialAuthService` in `features/auth/data/services/`.
3. Add `--dart-define=GOOGLE_CLIENT_ID=...` to your run commands.
4. Wire it through the auth repository and cubit.

### Payments (RevenueCat / Stripe)

1. Add the payment SDK dependency.
2. Create a `features/payments/` module following the sample feature pattern.
3. Add API keys via `--dart-define`.

## Routing Modes

The skeleton ships with two routing strategies. Switch by changing a single import in `lib/navigation/app_router.dart`:

```dart
// Shell mode (default) – bottom navigation bar with persistent tab state
import 'package:flutter_skeleton/navigation/routes_shell.dart';

// Flat mode – simple stack-based navigation, no shell
// import 'package:flutter_skeleton/navigation/routes_flat.dart';
```

After switching, run `dart run build_runner build --delete-conflicting-outputs` to regenerate.

### Shell mode (`routes_shell.dart`)

Best for apps with a main dashboard and multiple top-level sections (e.g. Home, Profile, Settings). Each tab keeps its own navigation stack.

```
/splash          -> SplashScreen
/welcome         -> WelcomeScreen
/home            -> HomeScreen       (tab 0)
/profile         -> ProfileScreen    (tab 1)
/settings        -> SettingsScreen   (pushed on top of shell)
```

The `DashboardShellRoute` wraps `/home` and `/profile` in a `StatefulNavigationShell` with a `NavigationBar`. Add more branches by extending the `TypedStatefulShellBranch` list.

### Flat mode (`routes_flat.dart`)

Best for simpler apps, onboarding flows, or apps where bottom navigation is not needed. Every route is a plain `GoRouteData` on the same navigator stack.

```
/splash          -> SplashScreen
/welcome         -> WelcomeScreen
/home            -> HomeScreen
/profile         -> ProfileScreen
/settings        -> SettingsScreen
```

All routes share the same route class names (`SplashRoute`, `WelcomeRoute`, `HomeRoute`, `ProfileRoute`, `SettingsRoute`) so `app_router.dart` works with either import without any other changes.

## Key Patterns

| Pattern | Implementation |
|---|---|
| State management | `flutter_bloc` with sealed states |
| Dependency injection | `get_it` with module-based registration |
| Networking | `dio` + `retrofit` + `AuthInterceptor` with token refresh |
| Error handling | `ErrorHandler` -> `Failure` types -> `RepositoryHelper` |
| Routing | `go_router` + `go_router_builder` (typed, code-gen) -- shell or flat mode |
| Localization | Flutter gen-l10n with ARB files |
| Storage | `SharedPreferences` (general) + `FlutterSecureStorage` (tokens) |

## License

MIT
