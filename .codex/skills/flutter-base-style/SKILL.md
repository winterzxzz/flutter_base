---
name: flutter-base-style
description: "Use when creating, editing, refactoring, or splitting any Flutter app code in this base project: data_module/presentation_module layering and folder structure, WrapperLayoutView screens, shared_view reusable widgets/layouts, feature sub-widget extraction when a page or build method grows too long, promoting widgets from a feature to shared_view, flutter_bloc Cubit flow and state, get_it DI registration, context.textTheme text styling, flutter_screenutil .r/.w/.h sizes, Retrofit API clients, json_annotation models/DTOs, repositories with Either NetworkError result types, Hive local database, secure storage, build_runner generated code, clean-code refactors, and the format/analyze/test validation steps."
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

## Shared View

`lib/presentation_module/shared_view/` holds widgets and layouts that are reused
across multiple features. Only put a widget here when more than one place uses
it.

Rules:

- Write a widget into `shared_view/` only when it is reused in two or more
  features/screens. A widget used by a single feature stays in that feature's
  `widgets/` folder.
- Do not pre-emptively move a one-off widget to `shared_view/`; promote it later
  when a second caller appears.
- Keep `shared_view/` widgets product-neutral and presentational: data and
  callbacks via the constructor, no feature Cubit, repository, service, or
  `get_it` access.
- Export shared widgets from the `shared_view/shared_view.dart` barrel and
  import that barrel.

## Feature Sub-Widgets

Each feature lives in `lib/presentation_module/ui/<feature>/` with a barrel
`<feature>.dart`, a `<feature>_page.dart`, a `<feature>_cubit.dart`, and its
state. When a feature page grows too long, split it into sub-widgets that are
local to that feature, not into `shared_view/`.

Layout:

```text
lib/presentation_module/ui/example/
  example.dart            // barrel, exports page + cubit + widgets
  example_page.dart       // thin: layout + composition only
  example_cubit.dart
  example_state.dart
  widgets/                // sub-widgets used only by this feature
    example_header.dart
    example_list_item.dart
```

Rules:

- Keep `<feature>_page.dart` thin: it composes the screen and wires the Cubit;
  it does not hold large widget trees.
- When `build` gets long or a chunk of UI is reusable only inside this feature,
  extract it into `widgets/` under the same feature folder.
- Name sub-widgets with the feature prefix (`ExampleHeader`,
  `ExampleListItem`) so ownership is obvious.
- Export feature sub-widgets from the feature barrel `<feature>.dart`, and
  import the barrel within the feature.
- Promote a widget to `shared_view/` only when a second feature needs it; until
  then it stays feature-local.
- Sub-widgets stay presentational: they take data and callbacks via the
  constructor; they call the Cubit via `context.read`/`BlocBuilder`, never a
  repository, service, or `get_it` directly.
- Prefer extracting sub-widget classes over private `Widget _buildX()` helper
  methods.

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

## Networking and Env

Build the shared `Dio` and read env config through
`data_module/networks/network_utils.dart`. Env values come from `.env`
(loaded by `flutter_dotenv` in `main`); `.env.example` lists the keys.

```dart
sl.registerLazySingleton<Dio>(NetworkUtils.createDio);

sl.registerLazySingleton<ExampleApiClient>(
  () => ExampleApiClient(sl<Dio>(), baseUrl: NetworkUtils.apiBaseUrl),
);
```

Rules:

- `NetworkUtils.createDio()` sets `AppConstants.timeout`, adds
  `NetworkInterceptor` (error logging) and `PrettyDioLogger` in debug only.
- Read base URLs/secrets via `NetworkUtils.requiredEnv('KEY')`; never hard-code
  them in API clients, Cubits, or widgets.
- Load `.env` once in `main` with `await dotenv.load(fileName: '.env')`.
- `NetworkError.fromDioError` maps `DioExceptionType` to a message and keeps
  `statusCode` + `type`; branch via `isUnauthorized`/`isTimeout`/
  `isConnectionError`, not by parsing `message`.
- `NetworkInterceptor` only logs failures; auth/token refresh is a separate
  interceptor (see below).

## Auth Token and Refresh

`data_module/networks/auth/` adds bearer auth, kept product-neutral:

- `AuthTokenStore` (default `SecureStorageAuthTokenStore`) stores the token pair
  in `SecureStorageService` under `SecureStorageKeys.accessToken`/`refreshToken`.
- `TokenRefresher` swaps a refresh token for new tokens; base ships
  `UnsupportedTokenRefresher`, products register a real one.
- `AuthInterceptor` attaches `Authorization: Bearer <token>` and, on 401,
  refreshes once and retries; on failure it clears the session and calls
  `onSessionExpired`.

Rules:

- Add `AuthInterceptor` via `NetworkUtils.createDio(interceptors: [...])` in DI;
  give it a retry client so refresh does not loop.
- Skip auth on login/refresh with
  `options.extra[AuthInterceptor.skipAuthKey] = true`.
- Read tokens only through `AuthTokenStore`; never hard-code auth endpoints in
  the base.

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

## Local Storage

Use Hive for local database storage and `flutter_secure_storage` for secrets.

Rules:

- Plain Hive boxes are for non-sensitive cache and app preferences only.
- Sensitive data uses `LocalDatabaseService.openEncryptedBox`, never a plain
  Hive box.
- Hive encryption keys are generated with Hive and stored in
  `SecureStorageService`, backed by platform secure storage.
- Keep storage access in services/repositories; widgets must call Cubits, not
  Hive or secure storage directly.
- Register storage services in `core/di/injection_container.dart` and inject
  them through repositories or Cubits.
- Use stable box/key names from `HiveBoxNames` and `SecureStorageKeys`.

## Validation

- Add focused tests with risk-based coverage.
- Use `bloc_test` for Cubit state transitions.
- API/model generation changes require `dart run build_runner build`.
- Before completion run `dart format lib test`, `flutter analyze`,
  `flutter test`, `! rg '\.sp\b' lib`, and
  `! rg 'Theme\.of\(context\)\.textTheme' lib`.
