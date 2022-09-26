A simple but reactful state management library for Flutter.

- Easy to use.
- Not depend on any other libraries.
- No boilerplate code.
- No need to use `setState`.

# Usage

## Rx

`Rx` is an observable unit. You can `.rx()` on any object to create an observable.

### Primitive types

```dart
final counter = 0.rx();
final text = 'Hello, World!'.rx();
final pi = 3.14.rx();
final list = [1, 2, 3].rx();
final map = {'a': 1, 'b': 2, 'c': 3}.rx();
```

### Custom types

```dart
class User {
	final String name;
	final int age;

	User(this.name, this.age);
}
final user = User('Oh Gihwan', 20).rx();
```

or you can make every field of your class observable.

```dart
class User {
  final Rx<String> name;
  final Rx<int> age;

  User(this.name, this.age);
}

final user = User('Oh Gihwan'.rx(), 20.rx()).rx();
```

### Composable values

If you want to create observables that depend on other observables,
you can use `ComputedRx` class.

```dart
final hours = 0.rx();
/// minutes will change when hours changes.
final minutes = ComputedRx(() => hours.value * 60);
/// seconds will change when hours and minutes changes.
final seconds = (() => minutes.value * 60).rx(); // same as ComputeRx(() => minutes.value * 60)


final currentHour = 0.rx();
final currentMinute = 0.rx();
final currentSecond = 0.rx();
/// Rx will call `toString()` on a `value`.
/// If you override `toString()` method, you don't need to call `value.toString()`.
/// `currentTime` will change when currentHour, currentMinute, currentSecond changes.
final currentTime = ComputedRx(() => '${currentHour}:${currentMinute}:${currentSecond}');
```

The other method and usage of `ComputedRx` are same as `Rx`.

### `.rxFamily` - Dynamically Created Rx Family

If you want to delay the createion of the `Rx` until you get the required information,
you can use `.rxFamily` or `RxFamily`.

```dart
final _counterTemplate = ((input) => input).rxFamily();

/// ....
final _counterFromZero = _counterTemplate(0);
final _counterFromTen  = _counterTemplate(10);
```

## Change the state

You can change the state of the observable by calling `.value = ...` on it.

```dart
final counter = 0.rx();

// ...
// this will rebuild the RxObserver widgets that depend on the counter
counter.value++;
```

### Custom state

If you make the fields of your class observable,
you can change the state of the class by calling `.value = ...` on the fields.
But if you don't make the fields observable, but you still want to change the state of the class
with the reactive way, you can use `rebuild()` method.

```dart
class User {
  User(this.name);
  var String name;
}
final user = User('Oh Gihwan').rx();

// ...
// this will not rebuild your RxObserver widgets
user.name = 'Gihwan Oh';

// this will rebuild your RxObserver widgets
user.rebuild();
```

## ReactiveBuilder

`ReactiveBuilder` observes the observables and rebuilds the widget when the observables are changed.
You don't need to explicitly define what you are depending on. Just wrap your widget with `ReactiveBuilder`.

```dart
class MyWidget extends StatelessWidget {
  final counter = 0.rx();
  @override
  Widget build(BuildContext context) {
    return ReactiveBuilder(
      builder: (BuildContext context) {
        return Text(counter.value.toString());
      },
    );
  }
}
```

or you can simply use `.observe` extension on a widget builder.
A widget builder is a function that returns a widget.
`beatx_rx` will pass the `BuildContext` to the builder function if needed.
You can omit the `BuildContext` parameter if you don't need it.

```dart
class MyWidget extends StatelessWidget {
  final counter = 0.rx();
  @override
  Widget build(BuildContext context) {
    return (() {
      return Text(counter.value.toString());
    }).observe;
	}
}
```

## Custom ReactiveBuilder

Wrapping your widget with `ReactiveBuilder` is not the only way to observe the observables.
Sometimes you want to observe the observables in a specific widget,
just like `StatelessWidget` and `StatefulWidget`.

`beatx_rx` provides `StatelessReactiveMixin`, `StatefulReactiveMixin`, and `ReactiveStateMixin` for this purpose.
For example, `ReactiveBuilder` is just a wrapper of `StatelessReactiveMixin`.

### StatelessReactiveMixin

If you don't need to use lifecycle methods, you can mixin `StatelessReactiveMixin`.

```dart
/// Somewhere in your code
final counter = 0.rx();

/// ...
class MyObserverWidget extends StatelessWidget with StatelessReactiveMixin {
  @override
  Widget build(BuildContext context) {
    return Text('You clicked the button ${counter} times!');
  }
}
```

### StatefulReactiveMixin

If you need to use lifecycle methods, you can mixin `StatefulReactiveMixin`.

```dart
class MyStatefulSomeWidget extends StatefulWidget with StatefulReactiveMixin {
  /// your code here
}

/// State class does not need to be modified
```

# FutureRx

`FutureRx` is a special type of `Rx` that observes a `Future`.
`FutureRx` will rebuild the widgets that depend on it when the `Future` state changes.
Defining a `FutureRx` is same as defining a `Rx`.

```dart
Future<int> delayedCounter() async {
  await Future.delayed(Duration(seconds: 3));
  return 1;
}

final myDelayedRx = delayedCounter().rx();
```

## Reactive to Future

You can use a set of getters and methods to observe the state of the `Future`.

- `isCompleted`, `isError`, `isLoading`, and `isCanceled` getters.
- `when` and `map` methods

All of these getters and methods are reactive. They will rebuild the widgets that depend on them
when the `Future` state changes.

```dart
// `myDelayedRx` from the above example

ReactiveBuilder(
  builder: (BuildContext context) {
    /// Provide all the possible states of the `Future`
    return myDelayedRx.map(
      loading: () => Text('Loading...'),
      error: (error) => Text('Error: $error'),
      completed: (value) => Text('Completed: $value'),
      canceled: () => Text('Canceled'),
    );

    /// Or, at least `orElse` callback,
    return myDelayedRx.map(
      orElse: () => Text('Loading...'),
      completed: (value) => Text('Completed: $value'),
    );
  }
)
```

`when` method is similar to `map` method, but it doesn't return a value.

### Canceling a Future

You can cancel the ongoing `Future` with `cancel()` method.

```dart
// You can omit the `await` keyword
await myDelayedRx.cancel();
```

## AsyncRx - Futures depending on other Rx

If your async method depends on other `Rx`, you can create a reactive `AsyncRx`.
`FutureRx` is holding a `Future` itself, but `AsyncRx` is holding a function that returns a `Future`.
Just use `.rx` on your async method, not on a `Future` result.
Let's see the example.

```dart
/// Somewhere in your code
final counter = 0.rx();

/// ...
Future<int> delayedCounter() async {
  /// All the dependencies should not be in a async gap
  final count = counter.value;
  await Future.delayed(Duration(seconds: 1));
  return count;
}

/// ** There is no method caller `()`, just make method itself a reactive **
final reactiveDelayedCounter = delayedCounter.rx();

/// Now, same as `FutureRx`
ReactiveBuilder(
  builder: (BuildContext context) {
    /// Provide all the possible states of the `Future`
    return reactiveDelayedCounter.map(
      loading: () => Text('Loading...'),
      error: (error) => Text('Error: $error'),
      completed: (value) => Text('Completed: $value'),
      canceled: () => Text('Canceled'),
    );

    /// Or, at least `orElse` callback,
    return reactiveDelayedCounter.map(
      orElse: () => Text('Loading...'),
      completed: (value) => Text('Completed: $value'),
    );
  }
)
```

In the above code, it the `counter` changes, the previous `reactiveDelayedCounter` will be canceled and
rebuild the `ReactiveBuilder` with a new result of `reactiveDelayedCounter`.

# Examples

You can find examples from [examples](https://github.com/beatly-dev/beatx/tree/main/examples/rx)
directory.

```

```
