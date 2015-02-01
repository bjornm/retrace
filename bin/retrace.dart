// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:retrace/retrace.dart';

main(List<String> args) {
  if (args.length != 1) {
    print("Usage: retrace <map>");
    exit(-1);
  }

  try {
    var retracer = new Retracer(args[0]);
    print("Paste your minified trace here:");
    var lines = [];
    while(true) {
      var line = stdin.readLineSync();
      if (line.isEmpty) {
        String trace = retracer.run(lines);
        print("\n$trace\n");
        break;
      } else {
        lines.add(line);
      }
    }
  } on ArgumentError catch (e) {
    print(e);
    exit(-1);
  }
}
