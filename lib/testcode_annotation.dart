class TestCode {
  final List<TestCase> cases;

  const TestCode({required this.cases});
}

class TestCase {
  final List<dynamic> params;
  final dynamic expected;

  const TestCase({required this.params, required this.expected});
}
