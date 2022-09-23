part of '../rx.dart';

extension RxString on BeatxRx<String> {
  /// Concatenate the string with [other]
  String operator +(String other) => value + other;
}

extension RxNullableString on BeatxRx<String?> {
  /// Concatenate the string with [other]
  String operator +(String other) => (value ?? '') + other;
}
