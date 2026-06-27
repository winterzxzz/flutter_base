import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

class NetworkError extends Equatable {
  const NetworkError({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  factory NetworkError.fromDioError(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final statusMessage = response?.statusMessage;
    final message = statusMessage?.isNotEmpty == true
        ? statusMessage!
        : error.message ?? error.toString();

    return NetworkError(message: message, statusCode: statusCode);
  }

  @override
  List<Object?> get props => [message, statusCode];
}
