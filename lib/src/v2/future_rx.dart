import 'package:async/async.dart';

import 'value_rx.dart';

class FutureRx<T> extends ValueRx<Future<T>> {
  FutureRx(
    Future<T> future, {
    super.autoDispose,
    super.onDispose,
  })  : _completer = CancelableOperation.fromFuture(future),
        super(() => future) {
    _completer.then(
      (result) {
        _isCompleted = true;
        _result = result;
        forceUpdate();
      },
      onError: (e, _) {
        _isError = true;
        _errorResult = e;
        forceUpdate();
      },
    );
  }

  final CancelableOperation<T> _completer;

  /// The result of the future.
  late T _result;

  /// The error result.
  dynamic _errorResult;

  bool _isError = false;
  bool _isCompleted = false;

  /// The future is completed.
  bool get isCompleted => _isCompleted;

  /// The future is canceled.
  bool get isCanceled => _completer.isCanceled;

  /// The future is completed with an error.
  bool get isError => _isError;

  /// The future is in progress.
  bool get isLoading => !isCompleted && !isCanceled && !isError;

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  /// Cancel the future
  Future<dynamic> cancel() async {
    _completer.cancel().then((_) {
      forceUpdate();
    });
  }

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
    if (isError && error != null) {
      return error.call(_errorResult);
    }
    if (isCanceled && canceled != null) {
      return canceled.call();
    }
    if (isCompleted && completed != null) {
      return completed.call(_result);
    }
    if (isLoading && loading != null) {
      return loading.call();
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
    if (isError && error != null) {
      return error.call(_errorResult);
    }
    if (isCanceled && canceled != null) {
      return canceled.call();
    }
    if (isCompleted && completed != null) {
      return completed.call(_result);
    }
    if (isLoading && loading != null) {
      return loading.call();
    }
    orElse!.call();
  }
}

// coverage:ignore-start
extension TransformToFutureRx<T> on Future<T> {
  FutureRx<T> toRx({
    bool autoDispose = false,
    void Function(Future<T> lastValue)? onDispose,
  }) =>
      FutureRx(
        this,
        autoDispose: autoDispose,
        onDispose: onDispose,
      );
}
// coverage:ignore-end