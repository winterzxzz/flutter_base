import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_base/data_module/error/network_error.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dio(
  DioExceptionType type, {
  Response<dynamic>? response,
  Object? error,
}) {
  return DioException(
    requestOptions: RequestOptions(path: '/test'),
    type: type,
    response: response,
    error: error,
  );
}

Response<dynamic> _response(int statusCode, Object? data) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: '/test'),
    statusCode: statusCode,
    data: data,
  );
}

void main() {
  group('NetworkError.fromDioError', () {
    test('maps timeout types and flags isTimeout', () {
      final error = NetworkError.fromDioError(
        _dio(DioExceptionType.connectionTimeout),
      );

      expect(error.type, DioExceptionType.connectionTimeout);
      expect(error.isTimeout, isTrue);
    });

    test('maps a SocketException connection error to a friendly message', () {
      final error = NetworkError.fromDioError(
        _dio(
          DioExceptionType.connectionError,
          error: const SocketException('no route'),
        ),
      );

      expect(error.isConnectionError, isTrue);
      expect(error.message, 'Please check your internet connection');
    });

    test('flags 401 as unauthorized', () {
      final error = NetworkError.fromDioError(
        _dio(
          DioExceptionType.badResponse,
          response: _response(401, {'message': 'nope'}),
        ),
      );

      expect(error.statusCode, 401);
      expect(error.isUnauthorized, isTrue);
      expect(error.message, 'Unauthorized');
    });

    test('reads a structured message from the response body', () {
      final error = NetworkError.fromDioError(
        _dio(
          DioExceptionType.badResponse,
          response: _response(422, {
            'errors': [
              {'message': 'Email is invalid'},
            ],
          }),
        ),
      );

      expect(error.message, 'Email is invalid');
    });
  });
}
