//manufactured class instead of object literal
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/token/stream_parser.dart';
import 'package:tedious_dart/token/token.dart';
import 'dart:developer' show log;

class EnvChangeEvents {
  final String name;
  final String event;
  const EnvChangeEvents({
    required this.name,
    required this.event,
  });
}

Map<int, EnvChangeEvents> _types = {
  1: EnvChangeEvents(name: 'DATABASE', event: 'databaseChange'),
  2: EnvChangeEvents(name: 'LANGUAGE', event: 'languageChange'),
  3: EnvChangeEvents(name: 'CHARSET', event: 'charsetChange'),
  4: EnvChangeEvents(name: 'PACKET_SIZE', event: 'packetSizeChange'),
  7: EnvChangeEvents(name: 'SQL_COLLATION', event: 'sqlCollationChange'),
  8: EnvChangeEvents(name: 'BEGIN_TXN', event: 'beginTransaction'),
  9: EnvChangeEvents(name: 'COMMIT_TXN', event: 'commitTransaction'),
  10: EnvChangeEvents(name: 'ROLLBACK_TXN', event: 'rollbackTransaction'),
  13: EnvChangeEvents(name: 'DATABASE_MIRRORING_PARTNER', event: 'partnerNode'),
  17: EnvChangeEvents(name: 'TXN_ENDED', event: '_'),
  18: EnvChangeEvents(name: 'RESET_CONNECTION', event: 'resetConnection'),
  20: EnvChangeEvents(name: 'ROUTING_CHANGE', event: 'routingChange'),
};

readNewAndOldValue(
  StreamParser parser,
  num length,
  EnvChangeEvents type,
  void Function(Token? token) callback,
) {
  switch (type.name) {
    case 'DATABASE':
    case 'LANGUAGE':
    case 'CHARSET':
    case 'PACKET_SIZE':
    case 'DATABASE_MIRRORING_PARTNER':
      return parser.readBVarChar((newValue) {
        parser.readBVarChar((oldValue) {
          switch (type.name) {
            case 'PACKET_SIZE':
              return callback(PacketSizeEnvChangeToken(
                newValue: int.parse(newValue),
                oldValue: int.parse(oldValue),
              ));

            case 'DATABASE':
              return callback(DatabaseEnvChangeToken(
                newValue: newValue,
                oldValue: oldValue,
              ));

            case 'LANGUAGE':
              return callback(LanguageEnvChangeToken(
                newValue: newValue,
                oldValue: oldValue,
              ));

            case 'CHARSET':
              return callback(CharsetEnvChangeToken(
                newValue: newValue,
                oldValue: oldValue,
              ));

            case 'DATABASE_MIRRORING_PARTNER':
              return callback(DatabaseMirroringPartnerEnvChangeToken(
                newValue: newValue,
                oldValue: oldValue,
              ));
          }
        });
      });

    case 'SQL_COLLATION':
    case 'BEGIN_TXN':
    case 'COMMIT_TXN':
    case 'ROLLBACK_TXN':
    case 'RESET_CONNECTION':
      return parser.readBVarByte((newValue) {
        parser.readBVarByte((oldValue) {
          switch (type.name) {
            case 'SQL_COLLATION':
              {
                final newCollation = newValue.length == 0
                    ? Collation.fromBuffer(newValue)
                    : null;
                final oldCollation = oldValue.length == 0
                    ? Collation.fromBuffer(oldValue)
                    : null;

                return callback(CollationChangeToken(
                  newValue: newCollation,
                  oldValue: oldCollation,
                ));
              }

            case 'BEGIN_TXN':
              return callback(BeginTransactionEnvChangeToken(
                newValue: newValue,
                oldValue: oldValue,
              ));

            case 'COMMIT_TXN':
              return callback(CommitTransactionEnvChangeToken(
                newValue: newValue,
                oldValue: oldValue,
              ));

            case 'ROLLBACK_TXN':
              return callback(RollbackTransactionEnvChangeToken(
                newValue: newValue,
                oldValue: oldValue,
              ));

            case 'RESET_CONNECTION':
              return callback(ResetConnectionEnvChangeToken(
                newValue: newValue,
                oldValue: oldValue,
              ));
          }
        });
      });

    case 'ROUTING_CHANGE':
      return parser.readUInt16LE((valueLength) {
        // Routing Change:
        // Byte 1: Protocol (must be 0)
        // Bytes 2-3 (USHORT): Port number
        // Bytes 4-5 (USHORT): Length of server data in unicode (2byte chars)
        // Bytes 6-*: Server name in unicode characters
        parser.readBuffer(valueLength, (routePacket) {
          final protocol = routePacket.readUInt8(0);

          if (protocol != 0) {
            throw MTypeError('Unknown protocol byte in routing change event');
          }

          final port = routePacket.readUInt16LE(1);
          final serverLen = routePacket.readUInt16LE(3);
          // 2 bytes per char, starting at offset 5
          final server = routePacket.toString_({
            'encoding': 'ucs2',
            'start': 5,
            'end': 5 + (serverLen * 2).toInt()
          });

          final newValue = RoutingEnvChange(
            protocol: protocol,
            port: port,
            server: server,
          );

          parser.readUInt16LE((oldValueLength) {
            parser.readBuffer(oldValueLength, (oldValue) {
              callback(RoutingEnvChangeToken(
                newValue: newValue,
                oldValue: oldValue,
              ));
            });
          });
        });
      });

    default:
      log('Tedious > Unsupported ENVCHANGE type ${type.name}');
      // skip unknown bytes
      parser.readBuffer(length - 1 as int, (_) {
        callback(null);
      });
  }
}
