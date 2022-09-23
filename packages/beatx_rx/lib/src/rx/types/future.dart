part of '../rx.dart';

/// Utility extension for [Future]s.
extension FutureRx on BeatxRx<Future> {
  Completer get _completer {
    final completer = Completer();
    value.then((value) {
      completer.complete(value);
    }).onError((e, _) {
      completer.completeError(e ?? 'error occured');
    });
    return completer;
  }

  /// Check if the future is completed
  bool get isCompleted {
    return _completer.isCompleted;
  }

  /// Check if the future is not completed
  bool get isLoading => !isCompleted;
}
