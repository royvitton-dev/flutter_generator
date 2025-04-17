      import 'package:flutter_test/flutter_test.dart';
      import 'package:flutter_generator_sample/util/caculator.dart';

      void main() {
          test('add case 0', () {
    final caculator = Caculator();
    
    final result = caculator.add(1, 2);
    expect(result, 3);
  });

  test('add case 1', () {
    final caculator = Caculator();
    
    final result = caculator.add(5, 7);
    expect(result, 12);
  });


  test('subtract case 0', () {
    final caculator = Caculator();
    
    final result = caculator.subtract(1, 2);
    expect(result, 3);
  });

  test('subtract case 1', () {
    final caculator = Caculator();
    
    final result = caculator.subtract(5, 7);
    expect(result, 12);
  });



      }
      