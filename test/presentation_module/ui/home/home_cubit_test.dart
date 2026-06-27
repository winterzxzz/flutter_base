import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_base/presentation_module/ui/home/home_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeCubit', () {
    test('starts at zero', () {
      final cubit = HomeCubit();

      expect(cubit.state.count, 0);

      cubit.close();
    });

    blocTest<HomeCubit, HomeState>(
      'increments count',
      build: HomeCubit.new,
      act: (cubit) => cubit.increment(),
      expect: () => const [HomeState(count: 1)],
    );

    blocTest<HomeCubit, HomeState>(
      'does not decrement below zero',
      build: HomeCubit.new,
      act: (cubit) => cubit.decrement(),
      expect: () => const <HomeState>[],
    );
  });
}
