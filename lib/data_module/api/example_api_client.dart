import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/example_item.dart';

part 'example_api_client.g.dart';

@RestApi()
abstract class ExampleApiClient {
  factory ExampleApiClient(Dio dio, {String? baseUrl}) = _ExampleApiClient;

  @GET('/examples')
  Future<List<ExampleItem>> fetchExamples();
}
