library dartclient_demin;

import 'dart:io';
import 'dart:convert';
import 'package:source_maps/source_maps.dart';
import 'package:path/path.dart' as p;

class Retracer {
  Mapping _mapping;

  Retracer(String filename) {
    try {
      var json = new File(filename).readAsStringSync();
      _mapping = parse(json);
    } catch (e) {
      throw new ArgumentError("Failed to open file $filename - $e");
    }
  }

  List<RetracedLine> run(List<String> trace) {
    var output = <RetracedLine>[];
    for(String text in trace) {
      var lineCol = parseLine(text);
      if (lineCol == null) {
        output.add(new RetracedLine.notParsed(text));
        continue;
      }
      var span = _mapping.spanFor(lineCol.line - 1, lineCol.col - 1);
      if (span == null) {
        // source_maps 0.10 fails to locate too low column numbers when target entries wrap lines
        // therefore, make a new search with the preceding line
        span = _mapping.spanFor(lineCol.line - 2, 99999);
        if (span == null) {
          output.add(new RetracedLine.notLocated(text));
          continue;
        }
      }

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
      output.add(new RetracedLine(source, text, span.start.line + 1, span.start.column + 1));
    };
    return output;
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

class RetracedLine {
  final String source;
  final String raw;
  final int line;
  final int col;
  final bool parsed;
  final bool located;

  RetracedLine(this.source, this.raw, this.line, this.col):
        parsed = true, located = true;
  RetracedLine.notLocated(this.raw):
        parsed = true, located = false,
        source = null, line = null, col = null;
  RetracedLine.notParsed(this.raw):
        parsed = false, located = false,
        source = null, line = null, col = null;
}

class TextFormatter {
  final bool useColors;
  TextFormatter({this.useColors: false});

  String format(List<RetracedLine> trace){
    var output = new StringBuffer();
    for(var line in trace) {
      if(!line.parsed){
        output.writeln(line.raw);
        continue;
      }
      if(!line.located){
        output.writeln(yellow(line.raw));
      }

      output.write('    at ');
      output.write("${line.source}:${line.line}".padRight(40));
      output.write(' ');
      output.write(red(line.raw));
      output.write(' (col ${line.col})');
      output.writeln();
    };
    return output.toString();
  }

  String red(String text) => useColors ? "${Colors.RED}${text}${Colors.NONE}" : text;
  String yellow(String text) => useColors ? "${Colors.YELLOW}${text}${Colors.NONE}" : text;
}

class JsonFormatter {
  String format(List<RetracedLine> trace){
    return new JsonEncoder.withIndent('  ')
        .convert(trace.map(_lineToJson).toList());
  }

  static Map _lineToJson(RetracedLine line) => {
    'source': line.source,
    'raw': line.raw,
    'line': line.line,
    'column': line.col,
  };
}

class Colors {
  static const String RED = '\u001b[31m';
  static const String YELLOW = '\u001b[33m';
  static const String NONE = '\u001b[0m';
}
