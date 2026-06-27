import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_base/data_module/error/network_error.dart';
import 'package:flutter_base/data_module/models/example_item.dart';
import 'package:flutter_base/data_module/repositories/example_repository.dart';
import 'package:flutter_base/data_module/models/load_status.dart';
import 'package:flutter_base/presentation_module/ui/example/example_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExampleCubit', () {
    blocTest<ExampleCubit, ExampleState>(
      'loads examples from repository',
      build: () => ExampleCubit(
        repository: _FakeExampleRepository(
          result: const Right([ExampleItem(id: '1', title: 'Example')]),
        ),
      ),
      act: (cubit) => cubit.loadExamples(),
      expect: () => const [
        ExampleState(status: LoadStatus.loading),
        ExampleState(
          status: LoadStatus.success,
          items: [ExampleItem(id: '1', title: 'Example')],
        ),
      ],
    );

    blocTest<ExampleCubit, ExampleState>(
      'emits error when repository returns Left',
      build: () => ExampleCubit(
        repository: _FakeExampleRepository(
          result: const Left(NetworkError(message: 'Request failed')),
        ),
      ),
      act: (cubit) => cubit.loadExamples(),
      expect: () => const [
        ExampleState(status: LoadStatus.loading),
        ExampleState(status: LoadStatus.error, errorMessage: 'Request failed'),
      ],
    );
  });
}

class _FakeExampleRepository implements ExampleRepository {
  const _FakeExampleRepository({required this.result});

  final Either<NetworkError, List<ExampleItem>> result;

  @override
  Future<Either<NetworkError, List<ExampleItem>>> fetchExamples() async {
    return result;
  }
}
