---
name: flutter-clean-architecture
description: Architects a Flutter application using the project's strict Feature-first Clean Architecture, BLoC, fpdart, Freezed, and Retrofit. Use when creating or modifying features, domains, or data layers.
---
# Architecting Flutter Applications (Feature-First Clean Architecture)

## Contents
- [Architectural Layers](#architectural-layers)
- [Project Structure](#project-structure)
- [Dependency Injection](#dependency-injection)
- [Workflow: Implementing a New Feature](#workflow-implementing-a-new-feature)
- [Examples](#examples)

## Architectural Layers

Enforce strict Separation of Concerns using Feature-first Clean Architecture.

### Presentation Layer (UI & State)
*   **State Management Selection (BLoC vs Cubit):**
    *   **Use `Cubit` for:** Simple state management, direct UI interactions (e.g., button taps, form submissions like Login/Sign up), and straightforward fire-and-forget API calls without complex concurrency.
    *   **Use `Bloc` for:** Complex state machines, event transformations (e.g., debouncing search queries), handling concurrent asynchronous events, pagination, and listening/reacting to external Streams (e.g., tracking global session changes).
*   **State & Events:** Use `flutter_bloc`. State and Events MUST be `sealed` classes extending `Equatable` (use `final class` for concrete implementations).
*   **Processing Results:** When calling a repository, the result is `Either<AppFailure, T>`. You MUST process it using `.fold()`: `result.fold((failure) => emit(ErrorState(failure)), (data) => emit(SuccessState(data)))`.
*   **Routing:** Use `auto_router` for screen navigation.

### Domain Layer (Business Logic)
*   **Pure Dart:** No Flutter imports (`package:flutter/*`), no JSON serialization libraries.
*   **Entities:** Pure Dart models or `freezed` classes without `fromJson`/`toJson`.
*   **Repositories (Interfaces):** Abstract classes defining operations. Return type MUST be `Future<Either<AppFailure, T>>` (using `fpdart`). Use `Unit` from `fpdart` for void operations.

### Data Layer (External Systems)
*   **Datasources (Retrofit/Dio):** Use `dio` for networking and `retrofit` for defining API endpoints via annotations.
*   **Models (DTOs):** Data Transfer Objects annotated with `@freezed` and `@JsonSerializable()`. Suffix with `DTO` (e.g., `UserDTO`). Include methods to map to/from domain models (`toDomain()`, `fromDomain()`).
*   **Repositories (Implementations):** Implement domain interfaces. The ENTIRE body of repository methods MUST be wrapped in `ExceptionMapper.guard(() => datasource.call())` to catch and map raw exceptions to `AppFailure`. Do NOT use standard `try/catch` in repositories.

## Project Structure

Group all code by feature, then by layer.

```text
lib/
├── core/                   # Shared utilities, extensions
├── domain/
│   └── failures/           # Global failure definitions (AppFailure)
├── features/
│   └── [feature_name]/
│       ├── data/
│       │   ├── datasources/    # Retrofit API clients
│       │   ├── models/         # Freezed DTOs
│       │   └── repositories/   # Repo implementations (using ExceptionMapper)
│       ├── domain/
│       │   ├── entities/       # Pure Dart domain models
│       │   └── repositories/   # Repo interfaces returning Either<AppFailure, T>
│       └── presentation/
│           ├── bloc/           # BLoCs / Cubits
│           ├── view/           # Screens / Pages
│           └── widgets/        # Feature-specific UI
├── i18n/                   # Slang translations
└── packages/               # Workspace packages (ui_kit, storage, etc)
```

## Dependency Injection

*   Dependencies are initialized via sequential steps in `lib/core/initialization/data/initialize_dependencies.dart` and exposed through `InheritedDependencies` (`InheritedWidget`).
*   Access dependencies in the widget tree via `context.deps` or `Dependencies.of(context)`.
*   Pass dependencies through constructors.

## Workflow: Implementing a New Feature

Follow this sequential workflow.

**Task Progress:**
- [ ] **Step 1: Domain Entities & Repositories.** Create domain models. Create the repository interface returning `Future<Either<AppFailure, T>>`.
- [ ] **Step 2: DTOs & Datasources.** Create `freezed` DTOs with `fromJson`. Define the Retrofit interface. Run build_runner: `dart run build_runner build -d`.
- [ ] **Step 3: Repository Implementation.** Implement the interface in the `data` layer. Map DTOs to Domain. Wrap calls in `ExceptionMapper.guard()`.
- [ ] **Step 4: BLoC / Cubit.** Create State and Event sealed classes using `Equatable`. Inject the repository. Handle operations using `Either.fold()`.
- [ ] **Step 5: View.** Create the screen widget. Consume the BLoC using `BlocProvider`, `BlocBuilder`, or `BlocConsumer`.
- [ ] **Step 6: DI.** Add Datasource and Repository initialization to `_initializationSteps` in `initialize_dependencies.dart`. Add new fields to `Dependencies` / `$MutableDependencies` / `_$ImmutableDependencies`.

## Examples

### Data Layer: Retrofit and Repository

```dart
// 1. DTO
@freezed
abstract class UserDTO with _$UserDTO {
  const factory UserDTO({
    required String id,
    required String name,
  }) = _UserDTO;

  const UserDTO._();

  factory UserDTO.fromJson(Map<String, dynamic> json) => _$UserDTOFromJson(json);

  User toDomain() => User(id: id, name: name);
}

// 2. Datasource (Retrofit)
@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio) = _UserApi;
  @GET('/users/{id}')
  Future<UserDTO> getUser(@Path('id') String id);
}

// 3. Repository Implementation
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._api);
  final UserApi _api;

  @override
  Future<Either<AppFailure, User>> getUser(String id) {
    // ALWAYS wrap in ExceptionMapper.guard to catch network/system errors
    return ExceptionMapper.guard(() async {
      final dto = await _api.getUser(id);
      return dto.toDomain();
    });
  }
}
```

### Presentation Layer: BLoC

```dart
class UserCubit extends Cubit<UserState> {
  UserCubit(this._repo) : super(const UserInitial());
  final UserRepository _repo;

  Future<void> fetchUser(String id) async {
    emit(const UserLoading());
    final result = await _repo.getUser(id);
    
    // Process Either result
    result.fold(
      (failure) => emit(UserError(failure)),
      (user) => emit(UserLoaded(user)),
    );
  }
}
```