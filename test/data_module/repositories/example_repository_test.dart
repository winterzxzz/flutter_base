import 'package:dio/dio.dart';
import 'package:flutter_base/data_module/api/example_api_client.dart';
import 'package:flutter_base/data_module/models/example_item.dart';
import 'package:flutter_base/data_module/repositories/example_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExampleRepository', () {
    test('returns Right when API succeeds', () async {
      final repository = ExampleRepositoryImpl(
        apiClient: _FakeExampleApiClient(
          result: [const ExampleItem(id: '1', title: 'First item')],
        ),
      );

      final result = await repository.fetchExamples();

      expect(result.isRight, isTrue);
      expect(result.right.single.title, 'First item');
    });

    test('returns Left when API throws DioException', () async {
      final repository = ExampleRepositoryImpl(
        apiClient: _FakeExampleApiClient(
          error: DioException(
            requestOptions: RequestOptions(path: '/examples'),
            response: Response<void>(
              requestOptions: RequestOptions(path: '/examples'),
              statusCode: 500,
              statusMessage: 'Server error',
            ),
          ),
        ),
      );

      final result = await repository.fetchExamples();

      expect(result.isLeft, isTrue);
      expect(result.left.statusCode, 500);
      expect(result.left.message, contains('Server error'));
    });

    test('returns Left when API throws unknown error', () async {
      final repository = ExampleRepositoryImpl(
        apiClient: _FakeExampleApiClient(error: StateError('broken')),
      );

      final result = await repository.fetchExamples();

      expect(result.isLeft, isTrue);
      expect(result.left.message, contains('broken'));
    });
  });
}

class _FakeExampleApiClient implements ExampleApiClient {
  _FakeExampleApiClient({this.result = const [], this.error});

  final List<ExampleItem> result;
  final Object? error;

  @override
  Future<List<ExampleItem>> fetchExamples() async {
    final error = this.error;
    if (error != null) throw error;
    return result;
  }
}
