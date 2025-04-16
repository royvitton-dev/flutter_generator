import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'reference.dart';

class ReferenceAnalyzer {
  // 클래스 정의가 발견된 경로를 저장하는 맵
  final Map<String, String> _classLocations = {};

  /// 주어진 코드에서 참조 관계를 분석합니다.
  List<Reference> analyzeCode(String code, {required String filePath}) {
    final result = parseString(
      content: code,
      featureSet: FeatureSet.latestLanguageVersion(),
    );

    // 먼저 클래스 위치를 수집
    final classCollector = _ClassLocationCollector(filePath);
    result.unit.accept(classCollector);
    _classLocations.addAll(classCollector.classLocations);

    // 참조 분석
    final visitor = ReferenceVisitor(
      filePath: filePath,
      classLocations: _classLocations,
    );
    result.unit.accept(visitor);

    // 분석 결과 반환
    return visitor.references;
  }

  /// 분석기 상태를 초기화합니다
  void reset() {
    _classLocations.clear();
  }

  /// 여러 파일 분석 결과를 시퀀스 다이어그램으로 변환
  String generateSequenceDiagram(List<Reference> allReferences) {
    // 여기서 참조 정보를 기반으로 시퀀스 다이어그램을 생성
    // PlantUML 형식으로 출력하는 예시:

    final buffer = StringBuffer();
    buffer.writeln('@startuml');
    buffer.writeln('skinparam sequenceArrowThickness 2');
    buffer.writeln('skinparam roundcorner 20');
    buffer.writeln('skinparam maxmessagesize 160');
    buffer.writeln('skinparam sequenceParticipant underline');

    // 참여 클래스 목록 생성
    final participants = <String>{};
    for (final ref in allReferences) {
      participants.add(ref.caller);
      participants.add(ref.callee);
    }

    // 참여자 선언
    for (final participant in participants) {
      buffer.writeln('participant "$participant" as ${_sanitize(participant)}');
    }
    buffer.writeln();

    // 참조 관계 표시
    for (final ref in allReferences) {
      final caller = _sanitize(ref.caller);
      final callee = _sanitize(ref.callee);

      // 참조 유형에 따라 다른 화살표 스타일 사용
      // switch (ref.type) {
      //   case ReferenceType.methodCall:
      //     buffer.writeln('$caller -> $callee: ${ref.reference}()');
      //     break;
      //   case ReferenceType.propertyAccess:
      //     buffer.writeln('$caller -> $callee: ${ref.reference}');
      //     break;
      //   case ReferenceType.functionCall:
      //     buffer.writeln('$caller -> $callee: ${ref.reference}()');
      //     break;
      // }

      switch (ref.type) {
        case ReferenceType.methodCall:
          buffer.writeln('$caller -> $callee: ${ref.reference}()');
          break;
        case ReferenceType.propertyAccess:
          buffer.writeln('$caller -> $callee: ${ref.reference}');
          break;
        case ReferenceType.controlFlowBody:
          buffer.writeln('$caller -> $callee: ${ref.reference}');
          break;
        case ReferenceType.functionCall:
        case ReferenceType.controlFlow:
          buffer.writeln(ref.reference);
          break;
      }
    }

    buffer.writeln('@enduml');
    return buffer.toString();
  }

  // PlantUML 다이어그램에서 사용할 수 있도록 문자열 정리
  String _sanitize(String input) {
    return input.replaceAll(' ', '_').replaceAll('.', '_');
  }
}

class _ClassLocationCollector extends RecursiveAstVisitor<void> {
  final String filePath;
  final Map<String, String> classLocations = {};

  _ClassLocationCollector(this.filePath);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final className = node.name.lexeme;
    classLocations[className] = filePath;
    super.visitClassDeclaration(node);
  }
}
