library retrace_test;

import 'package:retrace/retrace.dart';
import 'package:test/test.dart';

void main() {
  group('LineCol', () {
    test('should have a working equals operator', () {
      expect(new LineCol(1, 2), new LineCol(1, 2));
    });
  });

  group('parseLine', () {
    test('should not parse empty line', () => expect(Retracer.parseLine(""), null));
    test('should not parse mumbo characters', () => expect(Retracer.parseLine(" asdf asdf "), null));
    test('should parse chrome format', () {
      expect(Retracer.parseLine("    at WK.X4 (http://www.example.com/example.dart.js:17106:31)"), new LineCol(17106, 31));
    });
    test('should parse safari format', () {
      expect(Retracer.parseLine("R5@http://www.example.com/example.dart.js:17106:31"), new LineCol(17106, 31));
    });
    test('should parse stack_trace package format', () {
      expect(Retracer.parseLine("game.html.polymer.bootstrap.dart.js 21400:6   Pc.dart.Pc.bh"), new LineCol(21400, 6));
    });
  });
}
