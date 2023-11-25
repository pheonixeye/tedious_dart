import 'dart:async';

import 'package:events_emitter/emitters/event_emitter.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/token/handler.dart';
import 'package:tedious_dart/token/stream_parser.dart';

class TokenStreamParser extends EventEmitter {
  Debug debug;
  ParserOptions options;
  late Stream parser;

  late StreamSubscription sub;

  TokenStreamParser({
    required this.debug,
    required this.options,
    required Message message,
    required TokenHandler tokenHandler,
  }) {
    parser = Stream.fromIterable(StreamParser.parseTokens(
      debug: debug,
      options: options,
      iterable: message.controller.stream,
    )).asBroadcastStream();

    sub = parser.listen((data) {
      //TODO:
      //call the function from token handler class whos name is in data as token.handlerName with token as a parameter
      TOKEN_FUNCTIONS[data.handlerName]!(data).call();
    });

    sub.onDone(() {
      emit('end');
    });

    //TODO: on drain

    // parser.on('drain', () {
    //   emit('drain');
    // });
  }

  void pause() {
    return sub.pause();
  }

  void resume() {
    return sub.resume();
  }
}
