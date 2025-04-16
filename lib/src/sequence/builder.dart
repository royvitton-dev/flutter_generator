// lib/builder.dart
import 'package:build/build.dart';
import 'sequence_builder.dart';

Builder sequenceBuilder(BuilderOptions options) {
  final outputDir = options.config['output_directory'] as String? ?? 'output'; //기본값
  return SequenceBuilder(outputDir);
}
