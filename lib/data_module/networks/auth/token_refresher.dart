import 'auth_tokens.dart';

/// Exchanges a refresh token for a new token pair. A product implements this
/// against its own auth endpoint and registers it in DI.
abstract class TokenRefresher {
  /// Returns the new tokens, or `null` when the refresh token is no longer
  /// valid (the caller then clears the session and forces re-login).
  Future<AuthTokens?> refresh(String refreshToken);
}

/// Default refresher used until a product wires a real one. It never refreshes,
/// so a 401 simply clears the session.
class UnsupportedTokenRefresher implements TokenRefresher {
  const UnsupportedTokenRefresher();

  @override
  Future<AuthTokens?> refresh(String refreshToken) async => null;
}
