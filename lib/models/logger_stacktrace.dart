import 'package:chalkdart/chalk.dart';
import 'package:chalkdart/chalk_x11.dart';

class LoggerStackTrace {
  const LoggerStackTrace._({
    required this.functionName,
    required this.callerFunctionName,
    required this.fileName,
    required this.lineNumber,
    required this.columnNumber,
  });

  factory LoggerStackTrace.from(StackTrace trace) {
    final frames = trace.toString().split('\n');
    final functionName = _getFunctionNameFromFrame(frames[0]);
    final callerFunctionName = _getFunctionNameFromFrame(frames[1]);
    final fileInfo = _getFileInfoFromFrame(frames[0]);

    return LoggerStackTrace._(
      functionName: functionName,
      callerFunctionName: callerFunctionName,
      fileName: fileInfo[0],
      lineNumber: int.parse(fileInfo[1]),
      columnNumber: int.parse(fileInfo[2].replaceFirst(')', '')),
    );
  }

  final String functionName;
  final String callerFunctionName;
  final String fileName;
  final int lineNumber;
  final int columnNumber;

  static List<String> _getFileInfoFromFrame(String trace) {
    final indexOfFileName = trace.indexOf(RegExp('[A-Za-z]+.dart'));
    final fileInfo = trace.substring(indexOfFileName);

    return fileInfo.split(':');
  }

  static String _getFunctionNameFromFrame(String trace) {
    final indexOfWhiteSpace = trace.indexOf(' ');
    final subStr = trace.substring(indexOfWhiteSpace);
    final indexOfFunction = subStr.indexOf(RegExp('[A-Za-z0-9]'));

    return subStr
        .substring(indexOfFunction)
        .substring(0, subStr.substring(indexOfFunction).indexOf(' '));
  }

  @override
  String toString() {
    return 'LoggerStackTrace('
        'functionName: ${chalk.green(functionName)}, '
        'callerFunctionName: ${chalk.green(callerFunctionName)}, '
        'fileName: ${chalk.green(fileName)}, '
        'lineNumber: ${chalk.green(lineNumber)}, '
        'columnNumber: ${chalk.green(columnNumber)}\n';
  }
}

class Console {
  Console();
  final color = chalk.greenX11;
  final sb = StringBuffer();
  void log(List<dynamic> args) {
    args.map((e) => sb.write(color("$e, "))).toList();
    print(sb.toString());
    sb.clear();
  }
}

final console = Console();
