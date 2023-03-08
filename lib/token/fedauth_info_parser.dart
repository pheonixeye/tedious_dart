// ignore_for_file: constant_identifier_names

import 'package:tedious_dart/token/stream_parser.dart';
import 'package:tedious_dart/token/token.dart';

const FEDAUTHINFOID = {
  'STSURL': 0x01,
  'SPN': 0x02,
};

fedAuthInfoParser(
  StreamParser parser,
  ParserOptions options,
  void Function(FedAuthInfoToken data) callback,
) {
  parser.readUInt32LE((tokenLength) {
    parser.readBuffer(tokenLength, (data) {
      String? spn;
      String? stsurl;

      int offset = 0;

      final countOfInfoIDs = data.readUInt32LE(offset);
      offset += 4;

      for (int i = 0; i < countOfInfoIDs; i++) {
        final fedauthInfoID = data.readUInt8(offset);
        offset += 1;

        final fedAuthInfoDataLen = data.readUInt32LE(offset);
        offset += 4;

        final fedAuthInfoDataOffset = data.readUInt32LE(offset);
        offset += 4;

        switch (fedauthInfoID) {
          case 0x01: //FEDAUTHINFOID['SPN']:
            spn = data.toString_({
              'encoding': 'ucs2',
              'start': fedAuthInfoDataOffset,
              'end': fedAuthInfoDataOffset + fedAuthInfoDataLen
            });
            break;

          case 0x02: //FEDAUTHINFOID['STSURL']:
            stsurl = data.toString_({
              'encoding': 'ucs2',
              'start': fedAuthInfoDataOffset,
              'end': fedAuthInfoDataOffset + fedAuthInfoDataLen,
            });
            break;

          // ignoring unknown fedauthinfo options
          default:
            break;
        }
      }

      callback(FedAuthInfoToken(
        spn: spn,
        stsurl: stsurl,
      ));
    });
  });
}
