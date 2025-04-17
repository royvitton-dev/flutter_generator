// import "package:flutter_generator/flutter_generator.dart";
import "package:flutter_generator/testcode_annotation.dart";

class Caculator {
  @TestCode(
    cases: [
      TestCase(params: [1, 2], expected: 3),
      TestCase(params: [5, 7], expected: 12),
    ],
  )
  double add(double a, double b) {
    return a + b;
  }

  @TestCode(
    cases: [
      TestCase(params: [1, 2], expected: 3),
      TestCase(params: [5, 7], expected: 12),
    ],
  )
  double subtract(double a, double b) {
    return a - b;
  }

  double multiply(double a, double b) {
    return a * b;
  }

  double divide(double a, double b) {
    if (b == 0) {
      throw ArgumentError('Cannot divide by zero');
    }
    return a / b;
  }
}
