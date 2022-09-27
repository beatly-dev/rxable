part of 'rx.dart';

/// For [Future]s.
class AsyncRx<T> extends Rx<Future<T>> {
  AsyncRx(
    Future<T> Function() async, {
    super.autoDispose,
    super.listenOnUnchanged,
    super.onDispose,
  }) : super(() => async());

  CancelableOperation<T>? _completer;

  CancelableOperation<T>? get completer {
    /// intentionally access `value` getter to register this [Rx]
    final next = super.value;
    if (_prev != next) {
      _setupCompleter(next);
    }
    _prev = next;
    return _completer;
  }

  Future<T>? _prev;

  @override
  Future<T> get value {
    final next = super.value;
    if (_prev != next) {
      _setupCompleter(next);
    }
    _prev = next;
    return next;
  }

  /// Can't set new async method
  @override
  set value(_) {}

  void _setupCompleter(Future<T> future) {
    _completer?.cancel();
    _completer = CancelableOperation<T>.fromFuture(future);
    _completer?.then(
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
  bool get isCompleted => completer?.isCompleted ?? false;

  /// The result of the future.
  late T _result;

  /// The future is canceled.
  bool get isCanceled => completer?.isCanceled ?? false;

  /// The future is in progress.
  bool get isLoading => !isCompleted && !isCanceled && !isError;

  /// Cancel the future
  Future<dynamic> cancel() async {
    completer?.cancel().then((_) {
      rebuild();
    });
  }

  @override
  void drop() {
    _completer?.cancel();
    super.drop();
  }

  /// Map the result of the future.
  R map<R>({
    R Function(T result)? completed,
    R Function()? loading,
    R Function(dynamic error)? error,
    R Function()? canceled,
    R Function()? orElse,
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

extension TransformToAsyncRx<T> on Future<T> Function() {
  /// Get a [AsyncRx]
  AsyncRx<T> rx({
    bool listenOnUnchanged = false,
    bool autoDispose = false,
    void Function(Future<T> lastValue)? onDispose,
  }) =>
      AsyncRx(
        this,
        listenOnUnchanged: listenOnUnchanged,
        autoDispose: autoDispose,
        onDispose: onDispose,
      );
}
