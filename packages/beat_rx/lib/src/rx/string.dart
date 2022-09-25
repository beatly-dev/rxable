part of 'rx.dart';

extension RxString on Rx<String> {
  /// Concatenate the string with [other]
  String operator +(String other) => value + other;
}

extension RxNullableString on Rx<String?> {
  /// Concatenate the string with [other]
  String operator +(String other) => (value ?? '') + other;
}
