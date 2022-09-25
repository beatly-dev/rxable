part of 'rx.dart';

/// TODO
/// - Disposable
/// - Restartable
/// For [Future]s.
class FutureRx<T> extends Rx<CancelableCompleter<T>> {
  FutureRx(this._future) : super(CancelableCompleter<T>()) {
    _future.then((result) {
      _result = result;
      _value.complete(result);
      rebuild();
    }).catchError((error) {
      _isError = true;
      _errorResult = error;
      rebuild();
    });
  }
  final Future<T> _future;

  bool _isError = false;

  /// The future is completed with an error.
  bool get isError {
    /// Intentionally check [isComplete] first
    /// to register the listener
    if (!isCompleted) {
      return _isError;
    }
    return false;
  }

  /// The error result.
  dynamic _errorResult;

  /// The future is completed.
  bool get isCompleted => value.isCompleted;

  /// The result of the future.
  late T _result;

  /// The future is canceled.
  bool get isCanceled => value.isCanceled;

  /// The future is in progress.
  bool get isLoading => !isCompleted && !isCanceled && !_isError;

  /// Cancel the future
  Future<dynamic> cancel() async {
    _value.operation.cancel().then((_) => rebuild());
  }

  /// Map the result of the future.
  P map<P>({
    P Function(T result)? completed,
    P Function()? loading,
    P Function(dynamic error)? error,
    P Function()? canceled,
    P Function()? orElse,
  }) {
    assert(
        (completed != null &&
                loading != null &&
                error != null &&
                canceled != null) ||
            orElse != null,
        '''
You should provide at least `orElse` callback or all of the following callbacks:
- [completed], [loading], [error], [canceled]
''');
    if (isCompleted) {
      return completed?.call(_result) ?? orElse!.call();
    }
    if (isLoading) {
      return loading?.call() ?? orElse!.call();
    }
    if (isError) {
      return error?.call(_errorResult) ?? orElse!.call();
    }
    if (isCanceled) {
      return canceled?.call() ?? orElse!.call();
    }
    return orElse!.call();
  }

  /// Execute a callback for the result of the future.
  void when({
    void Function(T result)? completed,
    void Function()? loading,
    void Function(dynamic error)? error,
    void Function()? canceled,
    void Function()? orElse,
  }) {
    assert(
        (completed != null &&
                loading != null &&
                error != null &&
                canceled != null) ||
            orElse != null,
        '''
You should provide at least `orElse` callback or all of the following callbacks:
- [completed], [loading], [error], [canceled]
''');
    if (isCompleted) {
      completed?.call(_result);
    } else if (isLoading) {
      loading?.call();
    } else if (isError) {
      error?.call(_errorResult);
    } else if (isCanceled) {
      canceled?.call();
    }
    orElse?.call();
  }
}

extension TransformToBeatxFutureObservable<T> on Future<T> {
  /// Get a FutureRx
  FutureRx<T> get rx => FutureRx(this);
}
