import 'package:flutter/widgets.dart';

abstract class ReactiveX<T> {
  ReactiveX();
  T get value;
  ReactiveX<T> bind(BuildContext context);
  ReactiveX<T> unbind(BuildContext context);
}
