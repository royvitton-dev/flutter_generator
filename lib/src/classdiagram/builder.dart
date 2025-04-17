import 'package:build/build.dart';
import 'package:flutter_generator/src/classdiagram/class_builder.dart';

Builder classdiagramBuilder(BuilderOptions options) {
  final includePrivate = options.config['include_private'] as bool? ?? false; //기본값
  final outputDir = options.config['output_directory'] as String? ?? 'output'; //기본값
  final outputExtension = options.config['output_extension'] as String? ?? '.md'; //기본값
  return ClassDiagramBuilder(includePrivate, outputDir, outputExtension);
}
