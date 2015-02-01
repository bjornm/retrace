// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library retrace_test;

import 'package:retrace/retrace.dart';
import 'package:unittest/unittest.dart';

void main() => defineTests();

void defineTests() {
  group('main tests', () {
    test('parseLine', () {
      expect(Retracer.parseLine(""), null);
      expect(Retracer.parseLine(" asdf asdf "), null);
      expect(Retracer.parseLine("    at WK.X4 (http://www.example.com/example.dart.js:17106:31)"), new LineCol(17106, 31));
      expect(Retracer.parseLine("R5@http://www.example.com/example.dart.js:17106:31"), new LineCol(17106, 31));
    });
  });
}
