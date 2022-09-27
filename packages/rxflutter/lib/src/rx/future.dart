part of 'rx.dart';

/// For [Future]s.
class FutureRx<T> extends Rx<Future<T>> {
  FutureRx(
    Future<T> future, {
    super.autoDispose,
    super.listenOnUnchanged,
    super.onDispose,
  })  : _completer = CancelableOperation.fromFuture(future),
        super(() => future) {
    _completer.then(
      (result) {
        _isCompleted = true;
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

  final CancelableOperation<T> _completer;

  CancelableOperation<T> get completer {
    /// intentionally access `value` getter to register this [Rx]
    final _ = value;
    return _completer;
  }

  bool _isError = false;
  bool _isCompleted = false;

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
  bool get isCompleted => _isCompleted;

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
    if (isError) {
      return error?.call(_errorResult) ?? orElse!.call();
    }
    if (isCanceled) {
      return canceled?.call() ?? orElse!.call();
    }
    if (isCompleted) {
      return completed?.call(_result) ?? orElse!.call();
    }
    if (isLoading) {
      return loading?.call() ?? orElse!.call();
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
    if (isError) {
      return error?.call(_errorResult);
    }
    if (isCanceled) {
      return canceled?.call();
    }
    if (isCompleted) {
      return completed?.call(_result);
    }
    if (isLoading) {
      return loading?.call();
    }
    orElse?.call();
  }
}

extension TransformToFutureRx<T> on Future<T> {
  /// Get a [FutureRx]
  FutureRx<T> rx({
    bool listenOnUnchanged = false,
    bool autoDispose = false,
    void Function(Future<T> lastValue)? onDispose,
  }) =>
      FutureRx(
        this,
        listenOnUnchanged: listenOnUnchanged,
        autoDispose: autoDispose,
        onDispose: onDispose,
      );
}
