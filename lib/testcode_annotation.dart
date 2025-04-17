class TestCode {
  final List<TestCase> cases;

  const TestCode({required this.cases});
}

class TestCase {
  final List<dynamic> params;
  final dynamic expected;
  final bool isNot;
  const TestCase({required this.params, required this.expected, this.isNot = false});
}
