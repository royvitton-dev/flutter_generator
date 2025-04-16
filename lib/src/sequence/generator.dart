import 'dart:async';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'reference.dart';
import 'reference_analyzer.dart';

class SequenceDiagramGenerator extends Generator {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final methodAnalyzer = ReferenceAnalyzer();
    final buffer = StringBuffer();

    // 소스 코드 읽기 및 분석
    final sourceAsset = buildStep.inputId;
    final sourceContent = await buildStep.readAsString(sourceAsset);

    final filePath = sourceAsset.path;

    // lib 디렉토리에 있는 파일만 처리
    if (!filePath.startsWith('lib/')) {
      return '';
    }
    // MethodAnalyzer를 사용하여 메서드 호출 분석
    final methodCalls = methodAnalyzer.analyzeCode(sourceContent, filePath: filePath);

    // 클래스 목록 수집 (Set 사용)
    final classes = <String>{};

    // 분석에서 발견된 모든 클래스 수집
    for (var call in methodCalls) {
      if (call.caller.isNotEmpty && call.caller != 'UnknownClass') {
        classes.add(call.caller);
      }
      if (call.callee.isNotEmpty && call.callee != 'UnknownClass') {
        classes.add(call.callee);
      }
    }

    // 다이어그램 작성 시작
    buffer.writeln('sequenceDiagram');

    // 참여자(클래스) 추가
    for (var className in classes) {
      buffer.writeln('  participant $className');
    }

    // 시퀀스 다이어그램에 메서드 호출 추가
    for (var call in methodCalls) {
      final caller = call.caller;
      final callee = call.callee;
      final method = call.reference;
      final type = call.type;

      // final method = call.method;

      // 유효한 클래스 이름인 경우에만 추가
      if (caller.isNotEmpty && callee.isNotEmpty && caller != 'UnknownClass' && callee != 'UnknownClass') {
        switch (type) {
          case ReferenceType.methodCall:
            // buffer.writeln(method);
            if (['alt', 'par', 'else', 'end'].any((prefix) => method.startsWith(prefix))) {
              buffer.writeln(method);
            } else {
              buffer.writeln('  $caller->>$callee: $method()');
            }
            break;
          case ReferenceType.propertyAccess:
          case ReferenceType.functionCall:
            buffer.writeln('  $caller->>$callee: $method()');
            break;
          case ReferenceType.controlFlowBody:
          case ReferenceType.controlFlow:
            buffer.writeln(method);
            // Control flow는 별도로 처리하지 않음
            break;
        }
      }
    }
    return buffer.toString();
  }
}
