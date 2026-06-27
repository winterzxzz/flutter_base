import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data_module/models/example_item.dart';
import '../../../data_module/models/load_status.dart';
import '../../../data_module/repositories/example_repository.dart';

class ExampleCubit extends Cubit<ExampleState> {
  ExampleCubit({required ExampleRepository repository})
    : _repository = repository,
      super(const ExampleState());

  final ExampleRepository _repository;

  Future<void> loadExamples() async {
    emit(state.copyWith(status: LoadStatus.loading, clearErrorMessage: true));

    final result = await _repository.fetchExamples();
    result.fold(
      (error) => emit(
        state.copyWith(status: LoadStatus.error, errorMessage: error.message),
      ),
      (items) => emit(
        state.copyWith(
          status: LoadStatus.success,
          items: items,
          clearErrorMessage: true,
        ),
      ),
    );
  }
}

class ExampleState extends Equatable {
  const ExampleState({
    this.status = LoadStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final LoadStatus status;
  final List<ExampleItem> items;
  final String? errorMessage;

  bool get isInitial => status.isInitial;
  bool get isLoading => status.isLoading;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;

  ExampleState copyWith({
    LoadStatus? status,
    List<ExampleItem>? items,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ExampleState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
