import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_base/data_module/networks/auth/auth_interceptor.dart';
import 'package:flutter_base/data_module/networks/auth/auth_token_store.dart';
import 'package:flutter_base/data_module/networks/auth/auth_tokens.dart';
import 'package:flutter_base/data_module/networks/auth/token_refresher.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory token store.
class _FakeTokenStore implements AuthTokenStore {
  _FakeTokenStore({this.accessToken, this.refreshToken});

  String? accessToken;
  String? refreshToken;
  bool cleared = false;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    accessToken = tokens.accessToken;
    refreshToken = tokens.refreshToken ?? refreshToken;
  }

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    cleared = true;
  }
}

class _StubRefresher implements TokenRefresher {
  _StubRefresher(this._tokens);

  final AuthTokens? _tokens;
  int calls = 0;

  @override
  Future<AuthTokens?> refresh(String refreshToken) async {
    calls++;
    return _tokens;
  }
}

/// Canned HTTP responses keyed by what the request carries.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.onFetch);

  final ResponseBody Function(RequestOptions options) onFetch;
  final List<RequestOptions> requests = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return onFetch(options);
  }
}

ResponseBody _json(String body, int statusCode) {
  return ResponseBody.fromString(
    body,
    statusCode,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

void main() {
  group('AuthInterceptor', () {
    test('attaches the bearer token on requests', () async {
      final store = _FakeTokenStore(accessToken: 'token-1');
      final adapter = _FakeAdapter((_) => _json('{}', 200));
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter
        ..interceptors.add(
          AuthInterceptor(tokenStore: store, refresher: _StubRefresher(null)),
        );

      await dio.get<dynamic>('/me');

      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer token-1',
      );
    });

    test('refreshes once on 401 then retries the original request', () async {
      final store = _FakeTokenStore(
        accessToken: 'expired',
        refreshToken: 'refresh-1',
      );
      final refresher = _StubRefresher(
        const AuthTokens(accessToken: 'fresh', refreshToken: 'refresh-2'),
      );
      final adapter = _FakeAdapter((options) {
        final auth = options.headers['Authorization'];
        return auth == 'Bearer fresh'
            ? _json('{"ok":true}', 200)
            : _json('{"message":"expired"}', 401);
      });
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter
        ..interceptors.add(
          AuthInterceptor(
            tokenStore: store,
            refresher: refresher,
            retryClient: Dio()..httpClientAdapter = adapter,
          ),
        );

      final response = await dio.get<dynamic>('/me');

      expect(response.statusCode, 200);
      expect(refresher.calls, 1);
      expect(store.accessToken, 'fresh');
    });

    test('retries with latest stored token before refreshing', () async {
      final store = _FakeTokenStore(
        accessToken: 'fresh',
        refreshToken: 'refresh-1',
      );
      final refresher = _StubRefresher(
        const AuthTokens(accessToken: 'unused', refreshToken: 'unused-refresh'),
      );
      final adapter = _FakeAdapter((options) {
        final auth = options.headers['Authorization'];
        return auth == 'Bearer fresh'
            ? _json('{"ok":true}', 200)
            : _json('{"message":"expired"}', 401);
      });
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter
        ..interceptors.add(
          AuthInterceptor(
            tokenStore: store,
            refresher: refresher,
            retryClient: Dio()..httpClientAdapter = adapter,
          ),
        );

      final response = await dio.get<dynamic>(
        '/me',
        options: Options(headers: {'Authorization': 'Bearer expired'}),
      );

      expect(response.statusCode, 200);
      expect(refresher.calls, 0);
      expect(store.accessToken, 'fresh');
    });

    test('clears the session when refresh fails', () async {
      final store = _FakeTokenStore(
        accessToken: 'expired',
        refreshToken: 'refresh-1',
      );
      final adapter = _FakeAdapter((_) => _json('{"message":"expired"}', 401));
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter
        ..interceptors.add(
          AuthInterceptor(
            tokenStore: store,
            refresher: _StubRefresher(null),
            retryClient: Dio()..httpClientAdapter = adapter,
          ),
        );

      await expectLater(dio.get<dynamic>('/me'), throwsA(isA<DioException>()));
      expect(store.cleared, isTrue);
    });
  });
}
