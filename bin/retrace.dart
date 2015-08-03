// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:retrace/retrace.dart';
import 'package:args/args.dart';

main(List<String> args) {
  var parser = new ArgParser(allowTrailingOptions: true);
  parser.addOption('format',
      help: "How output should be displayed.",
      allowed: ['text', 'json'],
      defaultsTo: 'text');

  ArgResults argResults;
  try{
    argResults = parser.parse(args);
  } on FormatException catch (ex){
    print(ex.message);
    exit(1);
  }
  if (argResults.rest.length != 1) {
    print("Usage: retrace <map>");
    print("");
    print(parser.usage);
    exit(1);
  }
  String format = argResults['format'];

  try {
    var retracer = new Retracer(argResults.rest.single);
    if(stdioType(stdin) == StdioType.TERMINAL && format == 'text')
      print("Paste your minified trace here:");
    var lines = [];
    while(true) {
      var line = stdin.readLineSync();
      if (line == null || line.isEmpty) {
        var trace = retracer.run(lines);
        if(format == 'text'){
          var fmtr = new TextFormatter(useColors: stdout.hasTerminal);
          print(fmtr.format(trace));
        } else {
          var fmtr = new JsonFormatter();
          print(fmtr.format(trace));
        }
        break;
      } else {
        lines.add(line);
      }
    }
  } on ArgumentError catch (e) {
    print(e);
    exit(1);
  }
}
