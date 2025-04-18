// @dart=3.6
// ignore_for_file: directives_ordering
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:build_runner_core/build_runner_core.dart' as _i1;
import 'package:source_gen/builder.dart' as _i2;
import 'package:flutter_generator/flutter_generator.dart' as _i3;
import 'package:build_config/build_config.dart' as _i4;
import 'package:build/build.dart' as _i5;
import 'package:build_resolvers/builder.dart' as _i6;
import 'dart:isolate' as _i7;
import 'package:build_runner/build_runner.dart' as _i8;
import 'dart:io' as _i9;

final _builders = <_i1.BuilderApplication>[
  _i1.apply(
    r'source_gen:combining_builder',
    [_i2.combiningBuilder],
    _i1.toNoneByDefault(),
    hideOutput: false,
    appliesBuilders: const [r'source_gen:part_cleanup'],
  ),
  _i1.apply(
    r'flutter_generator_sample:testcode',
    [_i3.testcodeBuilder],
    _i1.toRoot(),
    hideOutput: false,
    defaultGenerateFor: const _i4.InputSet(
      include: [
        r'lib/*.dart',
        r'lib/**/*.dart',
      ],
      exclude: [
        r'lib/**_test.dart',
        r'lib/**/*_test.dart',
      ],
    ),
    defaultOptions: const _i5.BuilderOptions(<String, dynamic>{
      r'includePrivate': true,
      r'output_directory': r'test',
      r'output_extension': r'_test.dart',
    }),
  ),
  _i1.apply(
    r'flutter_generator_sample:sequence',
    [_i3.sequenceBuilder],
    _i1.toRoot(),
    hideOutput: false,
    defaultGenerateFor: const _i4.InputSet(
      include: [
        r'lib/*.dart',
        r'lib/**/*.dart',
      ],
      exclude: [
        r'lib/**.md',
        r'lib/**/*.md',
        r'gen/**/*.dart',
      ],
    ),
    defaultOptions: const _i5.BuilderOptions(<String, dynamic>{
      r'output_directory': r'gen/sequence',
      r'output_extension': r'.seq.md',
    }),
  ),
  _i1.apply(
    r'flutter_generator_sample:class',
    [_i3.classdiagramBuilder],
    _i1.toRoot(),
    hideOutput: false,
    defaultGenerateFor: const _i4.InputSet(
      include: [
        r'lib/*.dart',
        r'lib/**/*.dart',
      ],
      exclude: [
        r'lib/**.md',
        r'lib/**/*.md',
        r'gen/**/*.dart',
      ],
    ),
    defaultOptions: const _i5.BuilderOptions(<String, dynamic>{
      r'includePrivate': true,
      r'output_directory': r'gen/class',
      r'output_extension': r'.class.md',
    }),
  ),
  _i1.apply(
    r'build_resolvers:transitive_digests',
    [_i6.transitiveDigestsBuilder],
    _i1.toAllPackages(),
    isOptional: true,
    hideOutput: true,
    appliesBuilders: const [r'build_resolvers:transitive_digest_cleanup'],
  ),
  _i1.applyPostProcess(
    r'build_resolvers:transitive_digest_cleanup',
    _i6.transitiveDigestCleanup,
  ),
  _i1.applyPostProcess(
    r'source_gen:part_cleanup',
    _i2.partCleanup,
  ),
];
void main(
  List<String> args, [
  _i7.SendPort? sendPort,
]) async {
  var result = await _i8.run(
    args,
    _builders,
  );
  sendPort?.send(result);
  _i9.exitCode = result;
}
