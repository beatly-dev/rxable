A simple but reactful state management library for Flutter.

- Easy to use.
- Not depend on any other libraries.
- No boilerplate code.
- No need to use `setState`.

# Usage

## BeatxRx

`BeatxRx`/`Rx` is an observable unit. You can `.rx` on any object to create an observable.

### Primitive types

```dart
final counter = 0.rx;
final text = 'Hello, World!'.rx;
final pi = 3.14.rx;
final list = [1, 2, 3].rx;
final map = {'a': 1, 'b': 2, 'c': 3}.rx;
```

### Custom types

```dart
class User {
	final String name;
	final int age;

	User(this.name, this.age);
}
final user = User('Oh Gihwan', 20).rx;
```

or you can make every field of your class observable.

```dart
class User {
	final Rx<String> name;
	final Rx<int> age;

	User(this.name, this.age);
}

final user = User('Oh Gihwan'.rx, 20.rx).rx;
```

### Comprehensive values

If you want to create observables that depend on other observables,
you can use `ComputedRx` class.

```dart
final hours = 0.rx;
/// minutes will change when hours changes.
final minutes = ComputedRx(() => hours.value * 60);
/// seconds will change when hours and minutes changes.
final seconds = ComputedRx(() => minutes.value * 60);

final currentHour = 0.rx;
final currentMinute = 0.rx;
final currentSecond = 0.rx;
/// Rx will call `toString()` on a `value`.
/// If you override `toString()` method, you don't need to call `value.toString()`.
/// `currentTime` will change when currentHour, currentMinute, currentSecond changes.
final currentTime = ComputedRx(() => '${currentHour}:${currentMinute}:${currentSecond}');
```

The other method and usage of `ComputedRx` are same as `Rx`.

## RxObserver

`RxObserver` observes the observables and rebuilds the widget when the observables are changed.
You don't need to explicitly define what you are depending on. Just wrap your widget with `RxObserver`.

```dart
class MyWidget extends StatelessWidget {
	final counter = 0.rx;
	@override
	Widget build(BuildContext context) {
		return RxObserver(
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
	final counter = 0.rx;
	@override
	Widget build(BuildContext context) {
		return (() {
			return Text(counter.value.toString());
		}).observe;
	}
}
```

## Change the state

You can change the state of the observable by calling `.value = ...` on it.

```dart
final counter = 0.rx;

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
final user = User('Oh Gihwan').rx;

// ...
// this will not rebuild your RxObserver widgets
user.name = 'Gihwan Oh';

// this will rebuild your RxObserver widgets
user.rebuild();
```

## Custom RxObserver

Wrapping your widget with `RxObserver` is not the only way to observe the observables.
Sometimes you want to observe the observables in a specific widget,
just like `StatelessWidget` and `StatefulWidget`.

`beatx_rx` provides `StatelessRxObserver` and `StatefulRxObserver` for this purpose.
For example, `RxObserver` just is a wrapper of `StatelessRxObserver`.

### StatelessRxObserver

If you don't need to use lifecycle methods, you can extend `StatelessRxObserver`.

```dart
/// Somewhere in your code
final counter = 0.rx;

/// ...
class MyObserverWidget extends StatelessRxObserver {
	@override
	Widget build(BuildContext context) {
		return Text('You clicked the button ${counter} times!');
	}
}
```

### StatefulRxObserver

If you need to use lifecycle methods, you can extend `StatefulRxObserver`.

```dart
/// Somewhere in your code
final counter = 0.rx;

/// ...
class MyObserverWidget extends StatefulRxObserver<MyObserverWidgetState> {
	@override
	MyObserverWidgetState createState() => MyObserverWidgetState();
}

class MyObserverWidgetState extends StatefulRxObserverState<MyObserverWidget> {
	/// You can use initState, dispose, didUpdateWidget, didChangeDependencies

	@override
	Widget build(BuildContext context) {
		return Text('You clicked the button ${counter} times!');
	}
}
```

# Examples

You can find examples from [examples](https://github.com/beatly-dev/beatx/tree/main/examples/rx)
directory.
