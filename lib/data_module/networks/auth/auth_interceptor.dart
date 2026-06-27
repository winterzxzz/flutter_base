import 'package:dio/dio.dart';

import 'auth_token_store.dart';
import 'token_refresher.dart';

/// Attaches the bearer token to every request and, on a 401, refreshes the
/// token once and retries the original request. Product-neutral: the refresh
/// endpoint is supplied through [TokenRefresher].
///
/// Extends [QueuedInterceptorsWrapper] so concurrent 401s are handled one at a
/// time instead of triggering parallel refreshes.
class AuthInterceptor extends QueuedInterceptorsWrapper {
  AuthInterceptor({
    required AuthTokenStore tokenStore,
    required TokenRefresher refresher,
    Dio? retryClient,
    void Function()? onSessionExpired,
  }) : _tokenStore = tokenStore,
       _refresher = refresher,
       _retryClient = retryClient ?? Dio(),
       _onSessionExpired = onSessionExpired;

  final AuthTokenStore _tokenStore;
  final TokenRefresher _refresher;
  final Dio _retryClient;
  final void Function()? _onSessionExpired;

  /// Set `options.extra[skipAuthKey] = true` to skip the bearer header (e.g. on
  /// the login or refresh request itself).
  static const String skipAuthKey = 'skipAuth';
  static const String _retriedKey = '__auth_retried__';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthKey] == true ||
        options.headers.containsKey('Authorization')) {
      handler.next(options);
      return;
    }
    final token = await _tokenStore.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isAuthFailure = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;
    if (!isAuthFailure || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _expireSession();
      handler.next(err);
      return;
    }

    final tokens = await _refresher.refresh(refreshToken);
    if (tokens == null) {
      await _expireSession();
      handler.next(err);
      return;
    }

    await _tokenStore.saveTokens(tokens);

    final options = err.requestOptions
      ..extra[_retriedKey] = true
      ..headers['Authorization'] = 'Bearer ${tokens.accessToken}';

    try {
      final response = await _retryClient.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<void> _expireSession() async {
    await _tokenStore.clear();
    _onSessionExpired?.call();
  }
}
