import 'package:equatable/equatable.dart';

/// Access/refresh token pair returned by a product's auth endpoint.
class AuthTokens extends Equatable {
  const AuthTokens({required this.accessToken, this.refreshToken});

  final String accessToken;
  final String? refreshToken;

  @override
  List<Object?> get props => [accessToken, refreshToken];
}
