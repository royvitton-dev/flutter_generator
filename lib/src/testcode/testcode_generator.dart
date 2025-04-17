import 'dart:async';
import 'package:build/build.dart';
import 'package:flutter_generator/testcode_annotation.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/constant/value.dart';

class TestCodeGenerator extends Generator {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final buffer = StringBuffer();

    for (var element in library.allElements) {
      // 함수 레벨
      if (element is FunctionElement) {
        final annotation = _getTestGenAnnotation(element);
        if (annotation != null) {
          buffer.writeln(_generateTests(element, annotation));
        }
      }

      // 클래스 내 메서드
      if (element is ClassElement) {
        for (final method in element.methods) {
          final annotation = _getTestGenAnnotation(method);
          if (annotation != null) {
            buffer.writeln(_generateTests(method, annotation));
          }
        }
      }
    }

    if (buffer.isEmpty) return '';

    // 최종 파일 출력 형태
    return '''
      \nimport 'package:flutter_test/flutter_test.dart';
      \nimport '${buildStep.inputId.uri}';

      void main() {
        ${buffer.toString()}
      }
      ''';
  }

  ConstantReader? _getTestGenAnnotation(Element element) {
    final ann = const TypeChecker.fromRuntime(TestCode).firstAnnotationOf(element);
    return ann != null ? ConstantReader(ann) : null;
  }

  String _generateTests(ExecutableElement element, ConstantReader annotation) {
    final isMethod = element is MethodElement;
    final isStatic = isMethod && (element).isStatic;

    String? className;
    String? instanceName;

    if (isMethod) {
      final enclosing = (element).enclosingElement3;
      if (enclosing is ClassElement) {
        className = enclosing.name;
        instanceName = _lowerFirst(className);
      }
    }

    final funcName = element.name;
    final testCases = annotation.read('cases').listValue;

    final buffer = StringBuffer();

    for (var i = 0; i < testCases.length; i++) {
      final testCase = testCases[i];
      final params = testCase.getField('params')?.toListValue() ?? [];
      final expected = testCase.getField('expected');
      final isNot = testCase.getField('isNot')?.toBoolValue() ?? false;

      final paramStr = params.map(_dartLiteral).join(', ');
      final expectedStr = _dartLiteral(expected);

      final callExpr = (className != null)
          ? (isStatic ? '$className.$funcName($paramStr)' : '$instanceName.$funcName($paramStr)')
          : '$funcName($paramStr)';

      final setup = (!isStatic && className != null) ? 'final $instanceName = $className();\n    ' : '';
      final expect_msg = isNot == true ? 'expect(result, isNot($expectedStr));' : 'expect(result, $expectedStr);';

      buffer.writeln('  test(\'$funcName case $i\', () {');
      buffer.writeln('    $setup');
      buffer.writeln('    final result = $callExpr;');
      buffer.writeln('    $expect_msg');
      buffer.writeln('  });\n');
    }

    return buffer.toString();
  }

  String _dartLiteral(DartObject? obj) {
    if (obj == null) return 'null';
    if (obj.type?.isDartCoreString == true) return "'${obj.toStringValue()}'";
    if (obj.type?.isDartCoreInt == true) return obj.toIntValue().toString();
    if (obj.type?.isDartCoreDouble == true) return obj.toDoubleValue().toString();
    if (obj.type?.isDartCoreBool == true) return obj.toBoolValue().toString();
    if (obj.toListValue() != null) {
      return '[${obj.toListValue()!.map(_dartLiteral).join(', ')}]';
    }
    return 'null';
  }

  String _lowerFirst(String input) => input.isNotEmpty ? input[0].toLowerCase() + input.substring(1) : '';
}
