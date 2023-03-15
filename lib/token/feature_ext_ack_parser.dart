// ignore_for_file: constant_identifier_names

import 'package:tedious_dart/token/stream_parser.dart';
import 'package:tedious_dart/token/token.dart';
import 'package:magic_buffer_copy/magic_buffer.dart';

const Map<String, int> FEATURE_ID = {
  'SESSIONRECOVERY': 0x01,
  'FEDAUTH': 0x02,
  'COLUMNENCRYPTION': 0x04,
  'GLOBALTRANSACTIONS': 0x05,
  'AZURESQLSUPPORT': 0x08,
  'UTF8_SUPPORT': 0x0A,
  'TERMINATOR': 0xFF
};

featureExtAckParser(
  StreamParser parser,
  ParserOptions options,
  void Function(FeatureExtAckToken data) callback,
) {
  Buffer? fedAuth;
  bool? utf8Support;

  void next() {
    parser.readUInt8((featureId) {
      if (featureId == FEATURE_ID['TERMINATOR']!) {
        return callback(FeatureExtAckToken(
          fedAuth: fedAuth,
          utf8Support: utf8Support,
        ));
      }
      parser.readUInt32LE((featureAckDataLen) {
        parser.readBuffer(featureAckDataLen, (featureData) {
          switch (featureId) {
            case 0x02: //FEATURE_ID['FEDAUTH']!:
              fedAuth = featureData;
              break;
            case 0x0A: //FEATURE_ID['UTF8_SUPPORT']!:
              utf8Support = !!featureData[0];
              break;
          }
          next();
        });
      });
    });
  }

  next();
}
