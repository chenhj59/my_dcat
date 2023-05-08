import 'package:dcat/dcat.dart' as dcat;
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

const lineNumber = 'line-number';
void main(List<String> arguments) async {
  exitCode = 0;
  final parser = ArgParser()..addFlag(lineNumber, negatable: false, abbr: 'n');

  ArgResults argResults = parser.parse(arguments);
  final paths = argResults.rest;

  await my_dcat(paths, showLineNumbers: argResults[lineNumber] as bool);

  Writing_file();
  Getting_environment_information();
}

Future<void> my_dcat(List<String> paths, {bool showLineNumbers = false}) async {
  if (paths.isEmpty) {
    await stdin.pipe(stdout);
  } else {
    for (final path in paths) {
      var lineNumber = 1;
      final lines = utf8.decoder
          .bind(File(path).openRead())
          .transform(const LineSplitter());
      try {
        await for (final line in lines) {
          if (showLineNumbers) {
            stdout.write('${lineNumber++}');
          }
          stdout.writeln(line);
        }
      } catch (_) {
        await _handleError(path);
      }
    }
  }
}

Future<void> Writing_file() async {
  final quotes = File('quotes.txt');
  const stronger = 'That which does not kill us makes us stronges. -Nietzsches';

  await quotes.writeAsString(stronger, mode: FileMode.append);
}

void Getting_environment_information() {
  final envVarMap = Platform.environment;

  print('PWD = ${envVarMap['PWD']}');
  print('LOGNAME = ${envVarMap['LOGNAME']}');
  print('PATH = ${envVarMap['PATH']}');
}

Future<void> _handleError(String path) async {
  if (await FileSystemEntity.isDirectory(path)) {
    stderr.writeln('error: $path is a directory');
  } else {
    exitCode = 2;
  }
}
