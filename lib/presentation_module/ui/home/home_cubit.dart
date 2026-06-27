import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void increment() {
    emit(state.copyWith(count: state.count + 1));
  }

  void decrement() {
    if (state.count == 0) return;
    emit(state.copyWith(count: state.count - 1));
  }

  void reset() {
    if (state.count == 0) return;
    emit(const HomeState());
  }
}

class HomeState extends Equatable {
  const HomeState({this.count = 0});

  final int count;

  HomeState copyWith({int? count}) {
    return HomeState(count: count ?? this.count);
  }

  @override
  List<Object?> get props => [count];
}
