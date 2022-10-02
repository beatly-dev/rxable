import 'package:flutter/material.dart';

import 'reactive_x.dart';

class ValueRx<T> extends ReactiveX<T> {
  ValueRx(
    this.builder, {
    this.autoDispose = false,
    this.onDispose,
  });

  static ReactiveX? _rxAccessingNow;

  /// Initial value builder
  final T Function() builder;

  /// Auto dispose this Rx when no widget is using it.
  final bool autoDispose;

  /// Callback when this Rx is disposed.
  final void Function(T lastValue)? onDispose;

  /// Internal value to store the value of this rx.
  T? _value;

  /// Elements depending on this Rx
  final Set<Element> _elements = {};

  /// Has any elements depending on this Rx?
  @visibleForTesting
  bool get hasElements => _elements.isNotEmpty;

  /// A Compounded Rx which is depending on this Rx.
  final List<ReactiveX> _children = [];

  @visibleForTesting
  bool get hasChildren => _children.isNotEmpty;

  bool _registeredDisposer = false;

  /// Get the value of this rx.
  @override
  T get value {
    final prevAcc = _rxAccessingNow;

    if (prevAcc != null) {
      /// add child to this Rx for rebuilding
      _children.add(prevAcc);
    }

    _rxAccessingNow = this;
    if (!isActive || dirty) {
      _value = builder();
    }
    _rxAccessingNow = prevAcc;
    isActive = true;
    dirty = false;
    if (autoDispose && !_registeredDisposer) {
      _registeredDisposer = true;
      _automaticallyDisposeIfPossible();
    }
    return _value as T;
  }

  /// Set the value of this rx.
  set value(T newVal) {
    if (newVal == _value) {
      return;
    }
    _value = newVal;
    _markWidgetsNeedsBuildAll();
    for (final child in _children) {
      child.updateParent();
    }
  }

  /// Update value when the parent is updated.
  @override
  void updateParent() {
    /// All the notification routines are done in the setter.
    value = builder();
  }

  /// Mark all widgets as needing to be rebuilt.
  void _markWidgetsNeedsBuildAll() {
    for (var e in _elements) {
      e.markNeedsBuild();
    }
  }

  /// Bind widgets to this rx.
  /// Through this method, the rx will be able to rebuild the widgets.
  @override
  ValueRx<T> bind(BuildContext context) {
    final elm = context as Element;
    if (_elements.contains(elm)) {
      return this;
    }
    _elements.add(elm);
    _automaticallyUnbind(context);
    if (autoDispose && !_registeredDisposer) {
      _registeredDisposer = true;
      _automaticallyDisposeIfPossible();
    }
    return this;
  }

  /// Watch for unmounting of the widget
  void _automaticallyUnbind(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final elm = context as Element;
      try {
        /// With null-safety, this will throw an exception if the widget is unmounted.
        // ignore: unnecessary_null_comparison
        if (elm.widget == null) {
          unbind(context); // LCOV_EXCL_LINE
        }
        _automaticallyUnbind(context);
      } catch (e) {
        unbind(context);
      }
    });
  }

  /// Unbind widgets from this rx
  @override
  void unbind(BuildContext context) {
    _elements.remove(context as Element);
  }

  void _automaticallyDisposeIfPossible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_canDispose()) {
        return _automaticallyDisposeIfPossible();
      }
      _dispose();
    });
  }

  bool _canDispose() {
    _gcWidgets();
    _gcChildren();
    return _elements.isEmpty && _children.isEmpty;
  }

  void _gcWidgets() {
    _elements.removeWhere((element) {
      try {
        // ignore: unnecessary_null_comparison
        if (element.widget == null) {
          return true;
        }
      } catch (e) {
        return true;
      }
      return false;
    });
  }

  void _gcChildren() {
    _children.removeWhere((child) {
      return !child.isActive;
    });
  }

  void _dispose() {
    final lastVal = _value;
    _value = null;
    onDispose?.call(lastVal as T);

    dirty = true;
    isActive = false;
    _registeredDisposer = false;
  }

  /// Forward [toString] to the value
  @override
  String toString() => value.toString();
}
