library retrace_test;

import 'package:retrace/retrace.dart';
import 'package:guinness2/guinness2.dart';

void main() {
  describe('LineCol', () {
    it('should have a working equals operator', () {
      expect(new LineCol(1, 2)).toEqual(new LineCol(1, 2));
    });
  });

  describe('parseLine', () {
    it('should not parse empty line', () => expect(Retracer.parseLine(""), null));
    it('should not parse mumbo characters', () => expect(Retracer.parseLine(" asdf asdf "), null));
    it('should parse chrome format', () {
      expect(Retracer.parseLine("    at WK.X4 (http://www.example.com/example.dart.js:17106:31)")).toEqual(new LineCol(17106, 31));
    });
    it('should parse safari format', () {
      expect(Retracer.parseLine("R5@http://www.example.com/example.dart.js:17106:31")).toEqual(new LineCol(17106, 31));
    });
  });
}
