part of 'rx.dart';

/// For [Future]s.
class FutureRx<T> extends Rx<Future<T>> {
  FutureRx(Future<T> future) : super(() => future) {
    _completer = CancelableOperation<T>.fromFuture(future);
    _completer.then(
      (result) {
        _result = result;
        rebuild();
      },
      onError: (e, _) {
        _isError = true;
        _errorResult = e;
        rebuild();
      },
    );
  }

  late final CancelableOperation<T> _completer;

  CancelableOperation<T> get completer {
    /// intentionally access `value` getter to register this [Rx]
    final _ = value;
    return _completer;
  }

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
  bool get isCompleted => completer.isCompleted;

  /// The result of the future.
  late T _result;

  /// The future is canceled.
  bool get isCanceled => completer.isCanceled;

  /// The future is in progress.
  bool get isLoading => !isCompleted && !isCanceled && !isError;

  /// Cancel the future
  Future<dynamic> cancel() async {
    completer.cancel().then((_) {
      rebuild();
    });
  }

  @override
  void drop() {
    _completer.cancel();
    super.drop();
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

extension TransformToFutureRx<T> on Future<T> {
  /// Get a [FutureRx]
  FutureRx<T> get rx => FutureRx(this);
}
