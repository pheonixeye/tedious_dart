import 'dart:async';

import 'package:events_emitter/emitters/event_emitter.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/models/sync_async_iterable.dart';
import 'package:tedious_dart/token/handler.dart';
import 'package:tedious_dart/token/stream_parser.dart';
import 'package:tedious_dart/token/token.dart';

class TokenStreamParser extends EventEmitter {
  final Debug debug;
  final ParserOptions options;
  final Stream<Token?> parser;
  late final StreamSubscription<Token?> sub;

  TokenStreamParser({
    required this.debug,
    required this.options,
    required Message message,
    required TokenHandler tokenHandler,
  }) : parser = StreamParser.parseTokens(
          debug: debug,
          options: options,
          iterable: SyncAsyncIterable(message.controller.stream),
        ).asBroadcastStream() {
    sub = parser.listen((data) {
      //todo:
      //call the function from token handler class whos name is in data as token.handlerName with token as a parameter
      TokenHandler().TOKEN_FUNCTIONS[data?.handlerName]!(data);
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
