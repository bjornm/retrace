library dartclient_demin;

import 'dart:io';
import 'package:source_maps/source_maps.dart';
import 'package:path/path.dart' as p;

class Retracer {
  Mapping _mapping;
  List<String> _output = [];

  Retracer(String filename) {
    try {
      var json = new File(filename).readAsStringSync();
      _mapping = parse(json);
    } catch (e) {
      throw new ArgumentError("Failed to open file $filename - $e");
    }
  }

  String run(List<String> trace) {
    for(String text in trace) {
      var lineCol = parseLine(text);
      if (lineCol == null) {
        _output.add(text);
        continue;
      }
      var span = _mapping.spanFor(lineCol.line - 1, lineCol.col - 1);
      if (span == null) {
        // source_maps 0.10 fails to locate too low column numbers when target entries wrap lines
        // therefore, make a new search with the preceding line
        span = _mapping.spanFor(lineCol.line - 2, 99999);
        if (span == null) {
          _output.add("${Colors.YELLOW}$text${Colors.NONE}");
          continue;
        }
      }
      //    output.add('${span.message("", color:true)}');
      var source = p.prettyUri(span.sourceUrl);
      if (source != null) {
        var parts = source.split("/");
        if (parts.length > 3) {
          parts = parts.sublist(parts.length - 3);
        }
        source = parts.join("/");
      } else {
        source = "";
      }
      source = "$source:${span.start.line + 1}".padRight(40);
      _output.add('    at $source ${Colors.RED}${span.text}${Colors.NONE} (col ${span.start.column + 1})');
    };
    return _output.join("\n");
  }

  static LineCol parseLine(String text) {
    var match;
    if (new RegExp("\\s*at ").hasMatch(text)) {
      // chrome syntax
      match = new RegExp("\\s*at [^(]+ \\((.*):(\\d+):(\\d+)\\)").firstMatch(text);
    } else {
      // safari syntx
      match = new RegExp("\\s*[^@]+\\@(.*):(\\d+):(\\d+)").firstMatch(text);
    }
    if (match == null) {
      return null;
    }

    var line = int.parse(match[2]);
    var column = int.parse(match[3]);
    return new LineCol(line, column);
  }
}

class LineCol {
  final int line;
  final int col;
  LineCol(this.line, this.col);
  bool operator == (other) {
    if (!other is LineCol) {
      return false;
    }
    var o = (other as LineCol);
    return o.line == line && o.col == col;
  }
  int get hashCode => line + col;
}

class Colors {
  static const String RED = '\u001b[31m';
  static const String YELLOW = '\u001b[33m';
  static const String NONE = '\u001b[0m';
}