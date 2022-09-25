part of 'rx.dart';

/// Utility extension for [num]s.
extension BeatxRxNum on Rx<num> {
  /// Plus operator
  num operator +(num other) => value + other;

  /// Minus operator
  num operator -(num other) => value - other;

  /// Multiply operator
  num operator *(num other) => value * other;

  /// Divide operator
  num operator /(num other) => value / other;

  /// Modulo operator
  num operator %(num other) => value % other;

  /// Remainder operator
  num operator ~/(num other) => value ~/ other;

  /// Negate operator
  num operator -() => -value;

  /// Left shift operator
  num operator <<(int other) {
    final current = value;
    if (current is int) {
      return current << other;
    }
    return value;
  }

  /// Right shift operator
  num operator >>>(int other) {
    final current = value;
    if (current is int) {
      return current >>> other;
    }
    return value;
  }

  /// Right shift operator
  num operator >>(int other) {
    final current = value;
    if (current is int) {
      return current >> other;
    }
    return value;
  }

  /// Bitwise AND operator
  num operator &(int other) {
    final current = value;
    if (current is int) {
      return current & other;
    }
    return value;
  }

  /// Bitwise OR operator
  num operator |(int other) {
    final current = value;
    if (current is int) {
      return current | other;
    }
    return value;
  }

  /// Bitwise XOR operator
  num operator ^(int other) {
    final current = value;
    if (current is int) {
      return current ^ other;
    }
    return value;
  }

  /// Bitwise NOT operator
  num operator ~() {
    final current = value;
    if (current is int) {
      return ~current;
    }
    return value;
  }

  /// less then
  bool operator <(num other) => value < other;

  /// less then or equal to
  bool operator <=(num other) => value <= other;

  /// greater then
  bool operator >(num other) => value > other;

  /// greater then or equal to
  bool operator >=(num other) => value >= other;

  /// equal to
  bool equalsTo(num other) => value == other;

  /// not equal to
  bool notEqualsTo(num other) => value != other;
}

/// Utility extension for nullable [num]s.
extension BeatxRxNullableNum on Rx<num?> {
  /// Plus operator
  num? operator +(num other) {
    final current = value;
    if (current == null) {
      return null;
    }
    return current + other;
  }

  /// Minus operator
  num? operator -(num other) {
    final current = value;
    if (current == null) {
      return null;
    }
    return current - other;
  }

  /// Multiply operator
  num? operator *(num other) {
    final current = value;
    if (current == null) {
      return null;
    }
    return current * other;
  }

  /// Divide operator
  num? operator /(num other) {
    final current = value;
    if (current == null) {
      return null;
    }
    return current / other;
  }

  /// Modulo operator
  num? operator %(num other) {
    final current = value;
    if (current == null) {
      return null;
    }
    return current % other;
  }

  /// Remainder operator
  num? operator ~/(num other) {
    final current = value;
    if (current == null) {
      return null;
    }
    return current ~/ other;
  }

  /// Negate operator
  num? operator -() {
    final current = value;
    if (current == null) {
      return null;
    }
    return -current;
  }

  /// Left shift operator
  num? operator <<(int other) {
    final current = value;
    if (current == null) {
      return null;
    }
    if (current is int) {
      return current << other;
    }
    return value;
  }

  /// Right shift operator
  num? operator >>>(int other) {
    final current = value;
    if (current == null) {
      return null;
    }
    if (current is int) {
      return current >>> other;
    }
    return value;
  }

  /// Right shift operator
  num? operator >>(int other) {
    final current = value;
    if (current == null) {
      return null;
    }
    if (current is int) {
      return current >> other;
    }
    return value;
  }

  /// Bitwise AND operator
  num? operator &(int other) {
    final current = value;
    if (current == null) {
      return null;
    }
    if (current is int) {
      return current & other;
    }
    return value;
  }

  /// Bitwise OR operator
  num? operator |(int other) {
    final current = value;
    if (current == null) {
      return null;
    }
    if (current is int) {
      return current | other;
    }
    return value;
  }

  /// Bitwise XOR operator
  num? operator ^(int other) {
    final current = value;
    if (current == null) {
      return null;
    }
    if (current is int) {
      return current ^ other;
    }
    return value;
  }

  /// Bitwise NOT operator
  num? operator ~() {
    final current = value;
    if (current == null) {
      return null;
    }
    if (current is int) {
      return ~current;
    }
    return value;
  }

  /// less then
  bool operator <(num other) {
    final current = value;
    if (current == null) {
      return false;
    }
    return current < other;
  }

  /// less then or equal to
  bool operator <=(num other) {
    final current = value;
    if (current == null) {
      return false;
    }
    return current <= other;
  }

  /// greater then
  bool operator >(num other) {
    final current = value;
    if (current == null) {
      return false;
    }
    return current > other;
  }

  /// greater then or equal to
  bool operator >=(num other) {
    final current = value;
    if (current == null) {
      return false;
    }
    return current >= other;
  }

  /// equal to
  bool equalsTo(num? other) {
    return value == other;
  }

  /// not equal to
  bool notEqualsTo(num? other) {
    return value != other;
  }
}
