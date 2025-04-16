import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

// 새로운 ReferenceType 추가
enum ReferenceType {
  methodCall,
  propertyAccess,
  functionCall,
  controlFlowBody, // if, switch 등을 나타내기 위한 타입
  controlFlow // alt, end 등을 나타내기 위한 타입
}

class Reference {
  final String caller; // 호출자 클래스
  final String callee; // 대상 클래스
  final String reference; // 참조 정보 (caller->>callee: methodName())
  final ReferenceType type; // 참조 유형
  final String? mermaidAlt; // Mermaid alt 설명 (if/switch)
  final bool isParStart; // par 블록 시작 여부
  final bool isParEnd; // par 블록 종료 여부

  Reference({
    required this.caller,
    required this.callee,
    required this.reference,
    required this.type,
    this.mermaidAlt,
    this.isParStart = false,
    this.isParEnd = false,
  });
}

class ReferenceVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final Map<String, String> classLocations;
  final List<Reference> references = [];
  String currentClass = '';
  String currentMethod = '';

  ReferenceVisitor({
    required this.filePath,
    required this.classLocations,
  });

  // lib 디렉토리 내 파일인지 확인하는 메서드
  bool get isLibFile => filePath.startsWith('lib/');

  // 클래스가 lib 디렉토리에 있는지 확인하는 메서드
  bool isLibClass(String className) {
    if (!classLocations.containsKey(className)) {
      return false;
    }

    final location = classLocations[className];
    return location != null && location.startsWith('lib/');
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (isLibFile) {
      currentClass = node.name.lexeme;
      super.visitClassDeclaration(node);
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    // print("visitMethodDeclaration");
    // print("node.toString() = ${node.toString()}");
    if (isLibFile) {
      currentMethod = node.name.lexeme;
      // 메서드 시작에 par 블록 추가
      references.add(Reference(
        caller: currentClass,
        callee: currentClass,
        reference: 'par $currentMethod()',
        type: ReferenceType.methodCall,
        isParStart: true,
      ));

      super.visitMethodDeclaration(node);
      // 메서드 종료에 end 추가
      references.add(Reference(
        caller: currentClass,
        callee: currentClass,
        reference: 'end',
        type: ReferenceType.methodCall,
        isParEnd: true,
      ));
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // print("visitMethodInvocation ");
    // print("node.toString() = ${node.toString()}");
    if (isLibFile && currentMethod.isNotEmpty) {
      String targetClass = '';
      if (node.target != null) {
        targetClass = _determineTargetClass(node.target!);
      } else {
        targetClass = currentClass;
      }

      if (currentClass.isNotEmpty && targetClass.isNotEmpty) {
        // final referenceText = '$currentClass->>$targetClass: ${node.methodName.name}()';
        references.add(Reference(
          caller: currentClass,
          callee: targetClass,
          // reference: isInIfStatement ? 'alt\n  $referenceText\n end' : node.methodName.name,
          reference: node.methodName.name,
          type: ReferenceType.methodCall,
        ));
      }
      super.visitMethodInvocation(node);
    }
  }

  @override
  void visitIfStatement(IfStatement node) {
    print("visitIfStatement");
    print("node.toString() = ${node.toString()}");
    print("node.expression.toString() = ${node.expression.toString()}");

    if (isLibFile && currentMethod.isNotEmpty && node.expression.toString().contains("()")) {
      references.add(Reference(
        caller: currentClass,
        callee: currentClass,
        reference: '  alt',
        type: ReferenceType.controlFlow,
      ));

      node.thenStatement.accept(this);

      if (node.elseStatement != null) {
        references.add(Reference(
          caller: currentClass,
          callee: currentClass,
          reference: '  else',
          type: ReferenceType.controlFlow,
        ));

        node.elseStatement!.accept(this);
      }
      super.visitIfStatement(node);
      references.add(Reference(
        caller: currentClass,
        callee: currentClass,
        reference: '  end',
        type: ReferenceType.controlFlow,
      ));
    }
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    // print("visitSwitchStatement");
    // print("node.toString() = ${node.members.toString()}");
    if (isLibFile && currentMethod.isNotEmpty) {
      references.add(Reference(
        caller: currentClass,
        callee: currentClass,
        reference: '  alt ',
        type: ReferenceType.controlFlow,
      ));
      references.add(Reference(
        caller: currentClass,
        callee: currentClass,
        reference: '$currentClass <<-->> $currentClass : switch(${node.expression})',
        type: ReferenceType.controlFlowBody,
      ));

      for (var member in node.members) {
        // print("member = ${member.toString()}");
        // print("member is  = ${member is SwitchCase}");

        if (member is SwitchDefault) {
          references.add(Reference(
            caller: currentClass,
            callee: currentClass,
            reference: '    else default',
            type: ReferenceType.controlFlow,
          ));
          member.statements.forEach((statement) => statement.accept(this));
        } else if (member is SwitchPatternCase) {
          var first = member.guardedPattern.pattern.endToken.lexeme;
          references.add(Reference(
            caller: currentClass,
            callee: currentClass,
            reference: '    else $first',
            type: ReferenceType.controlFlow,
          ));
          member.statements.forEach((statement) => statement.accept(this));
        }
      }
    }
    references.add(Reference(
      caller: currentClass,
      callee: currentClass,
      reference: '$currentClass <<-->> $currentClass : switch end',
      type: ReferenceType.controlFlowBody,
    ));
    references.add(Reference(
      caller: currentClass,
      callee: currentClass,
      reference: '  end',
      type: ReferenceType.controlFlow,
    ));
    // super.visitSwitchStatement(node);
  }
  // @override
  // void visitIfStatement(IfStatement node) {
  //   if (isLibFile && currentMethod.isNotEmpty) {
  //     references.add(Reference(
  //       caller: currentClass,
  //       callee: currentClass,
  //       reference: '  alt',
  //       type: ReferenceType.controlFlow,
  //     ));
  //     isInIfStatement = true;

  //     node.thenStatement.accept(this);
  //     isInIfStatement = false;
  //     references.add(Reference(
  //       caller: currentClass,
  //       callee: currentClass,
  //       reference: '  end',
  //       type: ReferenceType.controlFlow,
  //     ));
  //   }
  //   super.visitIfStatement(node);
  // }

  // @override
  // void visitSwitchStatement(SwitchStatement node) {
  //   // if (isLibFile && currentMethod.isNotEmpty)
  //   {
  //     bool isFirst = true;
  //     for (var memeber in node.members) {
  //       var header = isFirst ? 'critical' : 'option';
  //       references.add(Reference(
  //         caller: currentClass,
  //         callee: currentClass,
  //         reference: ' $header  ${memeber.toString()}',
  //         type: ReferenceType.controlFlow,
  //       ));
  //       isInIfStatement = true;
  //       super.visitSwitchStatement(node);
  //       isFirst = false;
  //     }
  //     references.add(Reference(
  //       caller: currentClass,
  //       callee: currentClass,
  //       reference: '  end',
  //       type: ReferenceType.controlFlow,
  //     ));
  //   }
  //   super.visitSwitchStatement(node);
  // }

  // ... (나머지 visit 메서드는 변경 없음)

  String _determineTargetClass(Expression target) {
    if (target is Identifier) {
      final name = target.name;
      if (name == 'this') {
        return currentClass;
      } else if (name == 'super') {
        return currentClass;
      }
      final potentialClassName = _toPascalCase(name);
      if (classLocations.containsKey(potentialClassName)) {
        return potentialClassName;
      }
      return name;
    } else if (target is PrefixedIdentifier) {
      return target.prefix.name;
    } else if (target is PropertyAccess) {
      final accessedType = _determineTargetClass(target.target!);
      // 속성 접근의 경우, 속성의 타입을 반환하는 로직이 필요할 수 있습니다.
      // 여기서는 단순화를 위해 accessedType을 그대로 반환합니다.
      return accessedType;
    } else if (target is MethodInvocation) {
      return _determineTargetClass(target.target!); // 메서드 호출의 결과를 타겟으로 처리
    }
    return 'UnknownClass';
  }

  String _toPascalCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }
}
