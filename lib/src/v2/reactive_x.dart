import 'package:flutter/widgets.dart';

abstract class ReactiveX<T> {
  ReactiveX();

  T get value;

  bool dirty = true;

  bool isActive = false;

  @protected
  void updateParent();

  void forceUpdate();

  ReactiveX<T> bind(BuildContext context);
  void unbind(BuildContext context);
}
