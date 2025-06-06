import 'package:build/build.dart';
import 'package:flutter_generator/src/testcode/testcode_builder.dart';

Builder testcodeBuilder(BuilderOptions options) {
  final outputDir = options.config['output_directory'] as String? ?? 'output'; //기본값
  final outputExtension = options.config['output_extension'] as String? ?? '_test.dart'; //기본값
  return TestcodeBuilder(outputDir, outputExtension);
}
