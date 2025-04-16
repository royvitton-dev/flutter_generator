import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

class MethodAnalyzer {
  List<MethodCall> analyzeCode(String code, {required String filePath}) {
    final result = parseString(
      content: code,
      featureSet: FeatureSet.latestLanguageVersion(),
    );

    // 파일 경로 전달
    final visitor = _MethodCallVisitor(filePath: filePath);
    result.unit.accept(visitor);

    return visitor.methodCalls;
  }
}

/// AST 방문자로 메서드 호출을 찾아내는 클래스
class _MethodCallVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final List<MethodCall> methodCalls = [];
  String currentClass = '';
  String currentMethod = '';

  var classElementMap = {};

  // final List<String> classElementMap = [];

  _MethodCallVisitor({required this.filePath});

  // lib 디렉토리 내 파일인지 확인하는 메서드
  bool get isLibFile => true; //filePath.startsWith('lib/');

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    // lib 디렉토리에 있는 파일만 처리
    if (isLibFile) {
      currentClass = node.name.lexeme;
      super.visitClassDeclaration(node);
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    // lib 디렉토리에 있는 파일만 처리
    if (isLibFile) {
      currentMethod = node.name.lexeme;
      super.visitMethodDeclaration(node);
    }
  }

  // 클래스가 lib 디렉토리의 클래스인지 확인하는 메서드
  bool isLibClass(String className) {
    // resolver를 통해 클래스 정의 위치 확인 (이 부분은 실제 구현 방식에 따라 달라질 수 있음)
    final element = _getClassElement(className);
    if (element == null) return false;

    final classSource = element.source?.fullName;
    return classSource != null && classSource.startsWith('lib/');
  }

  Element? _getClassElement(String className) {
    // 여기에는 resolver나 현재 분석 컨텍스트를 통해 클래스 요소를 가져오는 로직이 필요합니다.
    // 간단한 구현을 위해 미리 분석된 클래스 매핑 테이블을 사용할 수 있습니다.
    return classElementMap[className]; // classElementMap은 클래스 이름을 키로 하는 맵
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // lib 디렉토리에 있는 파일만 처리
    if (isLibFile) {
      String targetClass = '';

      if (node.target != null) {
        targetClass = _determineTargetClass(node.target!);

        // 타겟 클래스가 lib 디렉토리의 클래스인지 확인
        if (!isLibClass(targetClass)) {
          // lib 디렉토리의 클래스가 아니면 건너뜀
          super.visitMethodInvocation(node);
          return;
        }
      } else {
        targetClass = currentClass; // 현재 클래스 내 메서드 호출
      }

      if (currentClass.isNotEmpty && targetClass.isNotEmpty) {
        methodCalls.add(MethodCall(
          caller: currentClass,
          callee: targetClass,
          method: node.methodName.name,
        ));
      }

      super.visitMethodInvocation(node);
    }
  }

  String _determineTargetClass(Expression target) {
    if (target is Identifier) {
      return target.name;
    }
    return 'UnknownClass';
  }
}

class MethodCall {
  final String caller;
  final String callee;
  final String method;

  MethodCall({
    required this.caller,
    required this.callee,
    required this.method,
  });
}
