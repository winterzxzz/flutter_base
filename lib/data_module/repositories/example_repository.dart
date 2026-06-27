import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

import '../api/example_api_client.dart';
import '../error/network_error.dart';
import '../models/example_item.dart';

abstract class ExampleRepository {
  Future<Either<NetworkError, List<ExampleItem>>> fetchExamples();
}

class ExampleRepositoryImpl implements ExampleRepository {
  ExampleRepositoryImpl({required ExampleApiClient apiClient})
    : _apiClient = apiClient;

  final ExampleApiClient _apiClient;

  @override
  Future<Either<NetworkError, List<ExampleItem>>> fetchExamples() async {
    try {
      final response = await _apiClient.fetchExamples();
      return Right(response);
    } on DioException catch (error) {
      return Left(NetworkError.fromDioError(error));
    } catch (error) {
      return Left(NetworkError(message: error.toString()));
    }
  }
}
