import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LoggerExample extends StatefulWidget {
  const LoggerExample({super.key});

  @override
  State<LoggerExample> createState() => _LoggerExampleState();
}

class _LoggerExampleState extends State<LoggerExample> {
  var logger = Logger(
    printer: PrettyPrinter(),
  );

  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(
        'Run with either `dart example/main.dart` or `dart --enable-asserts example/main.dart`.');
    demo();
  }

  void demo() {
    logger.d('Log message with 2 methods');

    loggerNoStack.i('Info message');

    loggerNoStack.w('Just a warning!');

    logger.e('Error! Something bad happened', error: 'Test Error');

    loggerNoStack.t({'key': 5, 'value': 'something'});

    Logger(printer: SimplePrinter(colors: true)).t('boom');
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
