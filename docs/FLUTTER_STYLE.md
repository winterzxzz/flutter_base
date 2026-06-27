# Flutter Style Guide

This repo follows the reusable Flutter style from
`/Users/winterzxzz/Documents/Work/Flutter/plant-id-flutter`, without copying
product-specific plant, Firebase, ads, or IAP code into the base.

## Structure

```text
lib/
  core/di/                         get_it registration
  data_module/api/                 Retrofit API clients
  data_module/error/               typed data/network failures
  data_module/models/              json_annotation DTOs/models
  data_module/repositories/        repository contracts + implementations
  data_module/services/            provider/platform service wrappers
  presentation_module/app.dart     app shell
  presentation_module/blocs/       app-wide Cubits/BLoCs
  presentation_module/configs/     constants and routing
  presentation_module/extensions/  BuildContext helpers
  presentation_module/shared_view/ reusable widgets
  presentation_module/theme/       theme definitions
  presentation_module/ui/<feature> feature page, Cubit, state, widgets
```

## Text Style

Widgets must import `presentation_module/extensions/extensions.dart`, declare
the text theme once, and use it in `Text` widgets.

```dart
final textTheme = context.textTheme;

Text(
  title,
  style: textTheme.titleMedium?.copyWith(fontSize: 16.r),
)
```

Rules:

- Use `final textTheme = context.textTheme` in `build` or builder callbacks.
- Do not repeat `Theme.of(context).textTheme` inside widget trees.
- Text sizes use `flutter_screenutil` `.r`, not `.sp`.
- Spacing uses `.w`, `.h`, or `.r` by axis/intent.

## Wrapper Layout

Use `WrapperLayoutView` for common page chrome instead of rebuilding Scaffold
and AppBar behavior in every screen.

```dart
return WrapperLayoutView(
  args: WrapperLayoutArgs(
    title: 'Search',
    showBack: true,
    onBack: () => Navigator.maybePop(context),
    backgroundColor: const Color(0xFFF5F5F5),
    bodyPadding: EdgeInsets.all(20.r),
    actions: [IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh))],
    body: const SearchView(),
  ),
);
```

Customization points:

- `title` or `customTitle`
- `showBack`, `showClose`, `leading`, `backIcon`, `closeIcon`
- `actions`, `bottom`, `bottomNavigationBar`
- `backgroundColor`, `appBarBackgroundColor`, gradient fields
- `bodyPadding`, `extendBodyBehindAppBar`, `resizeToAvoidBottomInset`
- `isHideAppBar` for full-screen pages

New screen rules:

- Start with `WrapperLayoutView(args: WrapperLayoutArgs(...))` for normal pages.
- Put feature UI in the `body`; keep state reads in the feature view/widgets.
- Use `BlocProvider(create: (_) => sl<FeatureCubit>())` outside the view when
  the screen needs state.
- Use `actions`, `bottom`, or `bottomNavigationBar` for page chrome instead of
  nested Scaffolds.
- Use `bodyPadding: EdgeInsets... .r` for responsive padding.
- Use `isHideAppBar: true` only for full-screen experiences.
- Do not call repositories from the wrapper body widget; call Cubit methods.

Keep the base layout product-neutral. Do not add premium, ads, SVG asset, or
feature-specific dependencies to `WrapperLayoutView`.

## Shared View vs Feature Widgets

Reusable UI is split by how many features use it.

- `presentation_module/shared_view/`: widgets/layouts reused by **two or more**
  features. Export them from `shared_view/shared_view.dart` and import that
  barrel.
- `presentation_module/ui/<feature>/widgets/`: sub-widgets used by **only that
  feature**. Export them from the feature barrel `<feature>.dart`.

Rules:

- Put a widget in `shared_view/` only when a second feature/screen needs it.
  A one-off widget stays in its feature's `widgets/` folder; promote it later
  when a second caller appears.
- `shared_view/` widgets are product-neutral and presentational: data and
  callbacks via the constructor, no feature Cubit, repository, service, or
  `get_it` access.

## Feature Sub-Widgets

When a feature page grows too long, split it into sub-widgets local to that
feature instead of into `shared_view/`.

```text
lib/presentation_module/ui/example/
  example.dart            barrel: exports page + cubit + widgets
  example_page.dart       thin: layout + composition only
  example_cubit.dart
  example_state.dart
  widgets/                sub-widgets used only by this feature
    example_header.dart
    example_list_item.dart
```

Rules:

- Keep `<feature>_page.dart` thin: compose the screen and wire the Cubit; it
  does not hold large widget trees.
- When `build` gets long, extract a chunk into `widgets/` under the same
  feature folder.
- Name sub-widgets with the feature prefix (`ExampleHeader`, `ExampleListItem`).
- Export feature sub-widgets from the feature barrel `<feature>.dart`.
- Prefer extracting sub-widget classes over private `Widget _buildX()` helper
  methods.
- Sub-widgets stay presentational: data/callbacks via the constructor; reach the
  Cubit via `context.read`/`BlocBuilder`, never a repository, service, or
  `get_it` directly.

## Cubit Flow

Widgets do not call repositories directly. Widgets call Cubits; Cubits call
repositories; repositories call API clients/services.

```text
Widget -> Cubit -> Repository -> ApiClient/Service
```

Use Cubit for screen state unless event streams need full BLoC.

```dart
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._repository) : super(const SearchState());

  final SearchRepository _repository;

  Future<void> search(String query) async {
    emit(state.copyWith(status: LoadStatus.loading));
    final result = await _repository.search(query: query.trim());
    result.fold(
      (error) => emit(state.copyWith(
        status: LoadStatus.error,
        errorMessage: error.message,
      )),
      (items) => emit(state.copyWith(
        status: LoadStatus.success,
        items: items,
        clearErrorMessage: true,
      )),
    );
  }
}
```

State rules:

- Immutable `const` state classes extend `Equatable`.
- Include `copyWith` and status getters such as `isLoading` and `isSuccess`.
- Use `LoadStatus` for initial/loading/success/error.
- Close timers/subscriptions in Cubit `close` or widget `dispose`.
- Test success, error, stale response, and duplicate-call behavior.

Widget rules:

```dart
return BlocProvider(
  create: (_) => sl<SearchCubit>(),
  child: const SearchView(),
);
```

- Use `context.read<Cubit>()` for commands.
- Use `BlocBuilder<Cubit, State>` for rendering state.
- Do not pass repositories into widgets.

## get_it

Register dependencies by layer in `core/di/injection_container.dart`.

```dart
final sl = GetIt.instance;

Future<void> configureDependencies() async {
  sl.registerSingleton<Dio>(NetworkUtils.createDio());

  sl.registerLazySingleton<AuthApiClient>(
    () => AuthApiClient(sl<Dio>(), baseUrl: NetworkUtils.apiBaseUrl),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authApiClient: sl<AuthApiClient>()),
  );

  sl.registerFactory<SearchCubit>(
    () => SearchCubit(sl<SearchRepository>()),
  );
}
```

Rules:

- Register network/API first, repositories second, services third, Cubits last.
- App-wide Cubits can be singleton/lazy singleton with `dispose` closing.
- Per-screen Cubits are usually factories.
- Tests call `resetDependencies()` when touching global `sl`.

## Retrofit APIs

API clients live in `data_module/api`.

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_client.g.dart';

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

Models live in `data_module/models`.

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user_response.g.dart';

@JsonSerializable()
class UserResponse {
  const UserResponse({this.id = '', this.name = ''});

  @JsonKey(defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String name;

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseToJson(this);
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

Reference implementation in this repo:

- `lib/data_module/api/example_api_client.dart`
- `lib/data_module/models/example_item.dart`
- `lib/data_module/error/network_error.dart`
- `lib/data_module/repositories/example_repository.dart`
- `lib/presentation_module/ui/example/example_cubit.dart`
- `test/data_module/repositories/example_repository_test.dart`
- `test/presentation_module/ui/example/example_cubit_test.dart`

```dart
abstract class AuthRepository {
  Future<Either<NetworkError, AuthResponse>> initAuth(AuthRequest request);
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthApiClient authApiClient})
    : _authApiClient = authApiClient;

  final AuthApiClient _authApiClient;

  @override
  Future<Either<NetworkError, AuthResponse>> initAuth(
    AuthRequest request,
  ) async {
    try {
      final response = await _authApiClient.initAuth(request);
      return Right(response);
    } on DioException catch (e) {
      return Left(NetworkError.fromDioError(e));
    } catch (e) {
      return Left(NetworkError(message: e.toString()));
    }
  }
}
```

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

- Add failing tests before production code.
- Use `bloc_test` for Cubit state transitions.
- API/model generation changes require `dart run build_runner build`.
- Before completion run `dart format lib test`, `flutter analyze`,
  `flutter test`, `! rg '\.sp\b' lib`, and
  `! rg 'Theme\.of\(context\)\.textTheme' lib`.
