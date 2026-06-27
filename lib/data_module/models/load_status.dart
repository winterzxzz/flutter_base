enum LoadStatus { initial, loading, success, error }

extension LoadStatusX on LoadStatus {
  bool get isInitial => this == LoadStatus.initial;
  bool get isLoading => this == LoadStatus.loading;
  bool get isSuccess => this == LoadStatus.success;
  bool get isError => this == LoadStatus.error;
}
