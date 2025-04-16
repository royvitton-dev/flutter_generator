import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:path/path.dart' as path;

import 'generator.dart';

class SequenceBuilder implements Builder {
  final String outputDir;
  static const outputExtension = '.sequence.md';

  SequenceBuilder(this.outputDir);

  @override
  Map<String, List<String>> get buildExtensions => {
        'lib/{{}}.dart': ['$outputDir/{{}}$outputExtension'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    final library = await buildStep.resolver.libraryFor(inputId);
    final reader = LibraryReader(library);

    final content = await SequenceDiagramGenerator().generate(reader, buildStep);

    // 원본 경로에서 lib/ 제거하고 diagram/ 붙이기
    final relativePath = path.relative(inputId.path, from: 'lib');
    final withoutExt = path.withoutExtension(relativePath);
    final outputPath = '$outputDir/$withoutExt$outputExtension';

    final outputId = AssetId(inputId.package, outputPath);
    await buildStep.writeAsString(outputId, content);
  }
}
