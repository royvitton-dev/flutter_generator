import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:path/path.dart' as p;

class MermaidClassDiagramGenerator extends Generator {
  final bool includePrivate;

  MermaidClassDiagramGenerator(this.includePrivate);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final buffer = StringBuffer();
    buffer.writeln('```mermaid');
    buffer.writeln('classDiagram');

    final definedClassNames = <String>{};

    // 먼저 모든 클래스 이름을 수집 (참조 관계 필터링용)
    for (final element in library.allElements) {
      if (element is ClassElement) {
        definedClassNames.add(element.name);
      }
    }

    for (final element in library.allElements) {
      if (element is ClassElement) {
        final className = element.name;
        buffer.writeln('class $className {');

        // 필드
        for (final field in element.fields) {
          if (!field.isPrivate || includePrivate) {
            final fieldType = field.type.getDisplayString();
            buffer.writeln('  $fieldType ${field.name}');

            // 필드 타입 참조 관계
            final typeElement = field.type.element;
            if (typeElement is ClassElement) {
              final referencedClass = typeElement.name;
              if (referencedClass != className && definedClassNames.contains(referencedClass)) {
                buffer.writeln('$referencedClass <-- $className');
              }
            }
          }
        }

        // 생성자
        for (final constructor in element.constructors) {
          final params = constructor.parameters.map((p) => '${p.type} ${p.name}').join(', ');
          buffer.writeln('  $className($params)');
        }

        // 메서드
        for (final method in element.methods) {
          if (!method.isPrivate || includePrivate) {
            final params = method.parameters.map((p) => '${p.type} ${p.name}').join(', ');
            final returnType = method.returnType.getDisplayString();
            buffer.writeln('  $returnType ${method.name}($params)');
          }
        }

        buffer.writeln('}');

        // 상속
        final supertype = element.supertype;
        if (supertype != null && supertype.element.name != 'Object') {
          buffer.writeln('${supertype.element.name} <|-- $className');
        }

        // implements
        for (final interface in element.interfaces) {
          buffer.writeln('${interface.element.name} <|.. $className');
        }
      }
    }

    buffer.writeln('```');
    return buffer.toString();
  }
}

class MermaidFolderDiagramBuilder implements Builder {
  final bool includePrivate;
  final String outputDir;
  static const outputExtension = '.md';

  MermaidFolderDiagramBuilder(this.includePrivate, this.outputDir);

  // @override
  // final buildExtensions = const {
  //   '.dart': ['.md']
  // };
  @override
  Map<String, List<String>> get buildExtensions => {
        'lib/{{}}.dart': ['$outputDir/{{}}$outputExtension'],
      };

  final _buffersByFolder = <String, StringBuffer>{};

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;

    // .dart 파일만 처리
    if (!inputId.path.endsWith('.dart')) return;

    final resolvedLibrary = await buildStep.resolver.libraryFor(inputId);
    final library = LibraryReader(resolvedLibrary);

    final relativePath = inputId.path; // 예: lib/util/ext.dart
    final folderPath = p.dirname(relativePath); // 예: lib/util

    final folderName = folderPath.split('/').last; // 예: util

    final buffer = _buffersByFolder.putIfAbsent(folderName, () {
      final b = StringBuffer();
      b.writeln('classDiagram');
      return b;
    });

    // 여기서 클래스 분석 로직 호출 (generateMermaidForLibrary 같은 함수 따로 분리)
    _generateMermaidFromLibrary(library, buffer, includePrivate);
  }

  void _generateMermaidFromLibrary(LibraryReader library, StringBuffer buffer, bool includePrivate) {
    for (final element in library.allElements) {
      if (element is ClassElement) {
        final className = element.name;
        buffer.writeln('class $className {');

        for (final field in element.fields) {
          if (!field.isPrivate || includePrivate) {
            final type = field.type.getDisplayString();
            buffer.writeln('  $type ${field.name}');
          }
        }

        buffer.writeln('}');
      }
    }
  }

  Future<void> writeAllOutputs(BuildStep buildStep) async {
    for (final entry in _buffersByFolder.entries) {
      final outputPath = 'diagram/${entry.key}.md';
      final outputId = AssetId(buildStep.inputId.package, outputPath);

      await buildStep.writeAsString(outputId, entry.value.toString());
    }
  }
}
