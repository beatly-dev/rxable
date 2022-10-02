import 'reactive_x.dart';

class ValueRx<T> extends ReactiveX<T> {
  ValueRx(this.builder);
  final T Function() builder;
  @override
  T get value {
    return builder();
  }
}
