---
name: flutter-base-style
description: "Use when editing this Flutter base project: data_module/presentation_module layering, WrapperLayoutView screens, flutter_bloc Cubit, get_it DI, context.textTheme text styling, flutter_screenutil .r text sizes, Retrofit APIs, json_annotation models, repositories with Either NetworkError result types, and generated code."
---

# Flutter Base Style

Use this skill before creating or changing Flutter app code in this repository.
Keep the base reusable and product-neutral. Do not add plant-specific, ads,
Firebase, premium, or IAP code unless a story explicitly requires it.

## Structure

- `lib/core/di/`: `get_it` registration.
- `lib/data_module/api/`: Retrofit API clients.
- `lib/data_module/error/`: typed errors such as `NetworkError`.
- `lib/data_module/models/`: `json_annotation` DTOs and models.
- `lib/data_module/repositories/`: contracts and implementations.
- `lib/data_module/services/`: provider/platform service wrappers.
- `lib/presentation_module/app.dart`: app shell.
- `lib/presentation_module/blocs/`: app-wide Cubits/BLoCs.
- `lib/presentation_module/extensions/`: `BuildContext` helpers.
- `lib/presentation_module/shared_view/`: reusable widgets and layouts.
- `lib/presentation_module/theme/`: theme definitions.
- `lib/presentation_module/ui/<feature>/`: feature page, Cubit, state,
  widgets.

## WrapperLayoutView

Use `WrapperLayoutView` for new standard screens that need shared `Scaffold`
and `AppBar` behavior.

```dart
return BlocProvider(
  create: (_) => sl<SearchCubit>(),
  child: WrapperLayoutView(
    args: WrapperLayoutArgs(
      title: 'Search',
      showBack: true,
      onBack: () => Navigator.maybePop(context),
      bodyPadding: EdgeInsets.all(20.r),
      actions: [
        IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh)),
      ],
      body: const SearchView(),
    ),
  ),
);
```

Rules:

- Prefer `WrapperLayoutView` over hand-written `Scaffold`/`AppBar` on normal
  pages.
- Configure layout only through `WrapperLayoutArgs`; do not add screen-specific
  branches inside the wrapper.
- Use `title` for plain titles and `customTitle` for rich title widgets.
- Use `showBack` or `showClose` with `onBack`/`onClose`; fallback is
  `Navigator.maybePop(context)`.
- Use `bodyPadding: EdgeInsets... .r` for responsive padding.
- Use `actions`, `bottom`, and `bottomNavigationBar` instead of nested
  Scaffolds or local app bars.
- Use wrapper gradient args for page backgrounds; do not duplicate gradient
  scaffold code in feature screens.
- Use `isHideAppBar: true` only for full-screen experiences.
- Keep `WrapperLayoutView` product-neutral: no premium, ads, Firebase, IAP,
  feature Cubit, SVG asset, or navigator singleton dependencies.
- Widgets inside `body` still follow: Widget -> Cubit -> Repository ->
  ApiClient/Service.

## Text Style

Always use the context extension in widgets:

```dart
final textTheme = context.textTheme;

Text(
  title,
  style: textTheme.titleMedium?.copyWith(fontSize: 16.r),
)
```

Rules:

- Import `presentation_module/extensions/extensions.dart`.
- Declare `final textTheme = context.textTheme` near the top of `build` or
  builder callbacks.
- Do not repeat `Theme.of(context).textTheme` inside widget trees.
- Text size uses `flutter_screenutil` `.r`, not `.sp`.
- Spacing uses `.w`, `.h`, or `.r` by axis/intent.

## Cubit Flow

Widgets do not call repositories directly. Widgets call Cubits; Cubits call
repositories; repositories call API clients/services.

```text
Widget -> Cubit -> Repository -> ApiClient/Service
```

Cubit rules:

- Use Cubit for screen state unless event streams need full BLoC.
- State is immutable and extends `Equatable`.
- State constructors are `const` with defaults.
- Include `copyWith` and status getters such as `isLoading` and `isSuccess`.
- Use `LoadStatus` for initial/loading/success/error.
- Close timers/subscriptions in Cubit `close` or widget `dispose`.
- Use `context.read<Cubit>()` for commands and `BlocBuilder` for rendering.

## get_it

Register dependencies by layer in `core/di/injection_container.dart`:

```dart
sl.registerLazySingleton<AuthApiClient>(
  () => AuthApiClient(sl<Dio>(), baseUrl: NetworkUtils.apiBaseUrl),
);

sl.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(authApiClient: sl<AuthApiClient>()),
);

sl.registerFactory<SearchCubit>(
  () => SearchCubit(sl<SearchRepository>()),
);
```

Rules:

- Register network/API first, repositories second, services third, Cubits last.
- App-wide Cubits can be singleton/lazy singleton with dispose callbacks.
- Per-screen Cubits are usually factories.
- Tests call `resetDependencies()` when touching global `sl`.

## Retrofit APIs

API clients live in `data_module/api` and use typed DTOs:

```dart
@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String? baseUrl}) = _AuthApiClient;

  @POST('/v1/auth/init')
  Future<AuthResponse> initAuth(@Body() AuthRequest body);
}
```

Rules:

- Pass `Dio` and `baseUrl` through DI.
- Keep URLs and env/config outside widgets and Cubits.
- Use typed request/response DTOs, not raw maps in feature code.
- Use Retrofit annotations: `@GET`, `@POST`, `@PUT`, `@Body`, `@Query`,
  `@Path`, `@Header`, `@Part`.
- Generated `*.g.dart` files come from `build_runner`; do not hand-edit them.

## json_annotation Models

Models live in `data_module/models`:

```dart
@JsonSerializable()
class UserResponse {
  const UserResponse({this.id = '', this.name = ''});

  @JsonKey(defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String name;
}
```

Rules:

- Prefer `const` constructors and defaults for absent API fields.
- Use `@JsonKey(defaultValue: ...)` for defensive parsing.
- Use `@JsonSerializable(genericArgumentFactories: true)` for generic wrappers.
- UI consumes typed objects; parsing stays in `data_module`.

## Repository Pattern

Repositories return `Either<NetworkError, T>` from `either_dart`, using
`Left(error)` for failure and `Right(data)` for success.

Rules:

- Widgets never call repositories directly.
- Cubits call repositories and fold `Left`/`Right` into UI state.
- Repositories validate required config before network calls.
- Network, provider, and parse failures become typed errors, not thrown UI
  exceptions.

## Validation

- Add focused tests with risk-based coverage.
- Use `bloc_test` for Cubit state transitions.
- API/model generation changes require `dart run build_runner build`.
- Before completion run `dart format lib test`, `flutter analyze`,
  `flutter test`, `! rg '\.sp\b' lib`, and
  `! rg 'Theme\.of\(context\)\.textTheme' lib`.
