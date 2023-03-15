// ignore_for_file: constant_identifier_names, non_constant_identifier_names, void_checks, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:math';

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tedious_dart/guid_parser.dart';
import 'package:tedious_dart/metadata_parser.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/token/stream_parser.dart';
import 'dart:developer' as dev show log;

const NULL = (1 << 16) - 1;
const MAX = (1 << 16) - 1;
const THREE_AND_A_THIRD = 3 + (1 / 3);
const MONEY_DIVISOR = 10000;
final PLP_NULL = Buffer.from([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]);
final UNKNOWN_PLP_LEN =
    Buffer.from([0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]);
const DEFAULT_ENCODING = 'utf8';

readTinyInt(StreamParser parser, void Function(dynamic value) callback) {
  parser.readUInt8(callback);
}

readSmallInt(StreamParser parser, void Function(dynamic value) callback) {
  parser.readInt16LE(callback);
}

readInt(StreamParser parser, void Function(dynamic value) callback) {
  parser.readInt32LE(callback);
}

readBigInt(StreamParser parser, void Function(dynamic value) callback) {
  parser.readBigInt64LE((value) {
    callback(value.toString());
  });
}

readReal(StreamParser parser, void Function(dynamic value) callback) {
  parser.readFloatLE(callback);
}

readFloat(StreamParser parser, void Function(dynamic value) callback) {
  parser.readDoubleLE(callback);
}

readSmallMoney(StreamParser parser, void Function(dynamic value) callback) {
  parser.readInt32LE((value) {
    callback(value / MONEY_DIVISOR);
  });
}

readMoney(StreamParser parser, void Function(dynamic value) callback) {
  parser.readInt32LE((high) {
    parser.readUInt32LE((low) {
      callback((low + (0x100000000 * high)) / MONEY_DIVISOR);
    });
  });
}

readBit(StreamParser parser, void Function(dynamic value) callback) {
  parser.readUInt8((value) {
    callback(value); //TODO ?? (!!value)
  });
}

valueParse(
  StreamParser parser,
  Metadata metadata,
  ParserOptions options,
  void Function(dynamic value) callback,
) {
  final type = metadata.baseMetadata!.type;

  switch (type.name) {
    case 'Null':
      return callback(null);

    case 'TinyInt':
      return readTinyInt(parser, callback);

    case 'SmallInt':
      return readSmallInt(parser, callback);

    case 'Int':
      return readInt(parser, callback);

    case 'BigInt':
      return readBigInt(parser, callback);

    case 'IntN':
      return parser.readUInt8((dataLength) {
        switch (dataLength) {
          case 0:
            return callback(null);

          case 1:
            return readTinyInt(parser, callback);
          case 2:
            return readSmallInt(parser, callback);
          case 4:
            return readInt(parser, callback);
          case 8:
            return readBigInt(parser, callback);

          default:
            throw MTypeError('Unsupported dataLength $dataLength for IntN');
        }
      });

    case 'Real':
      return readReal(parser, callback);

    case 'Float':
      return readFloat(parser, callback);

    case 'FloatN':
      return parser.readUInt8((dataLength) {
        switch (dataLength) {
          case 0:
            return callback(null);

          case 4:
            return readReal(parser, callback);
          case 8:
            return readFloat(parser, callback);

          default:
            throw MTypeError('Unsupported dataLength $dataLength for FloatN');
        }
      });

    case 'SmallMoney':
      return readSmallMoney(parser, callback);

    case 'Money':
      return readMoney(parser, callback);

    case 'MoneyN':
      return parser.readUInt8((dataLength) {
        switch (dataLength) {
          case 0:
            return callback(null);

          case 4:
            return readSmallMoney(parser, callback);
          case 8:
            return readMoney(parser, callback);

          default:
            throw MTypeError('Unsupported dataLength  $dataLength  for MoneyN');
        }
      });

    case 'Bit':
      return readBit(parser, callback);

    case 'BitN':
      return parser.readUInt8((dataLength) {
        switch (dataLength) {
          case 0:
            return callback(null);

          case 1:
            return readBit(parser, callback);

          default:
            throw MTypeError('Unsupported dataLength  $dataLength  for BitN');
        }
      });

    case 'VarChar':
    case 'Char':
      final codepage = metadata.baseMetadata!.collation!.codepage!;
      if (metadata.baseMetadata!.dataLength == MAX) {
        return readMaxChars(parser, codepage, callback);
      } else {
        return parser.readUInt16LE((dataLength) {
          if (dataLength == NULL) {
            return callback(null);
          }

          readChars(parser, dataLength, codepage, callback);
        });
      }

    case 'NVarChar':
    case 'NChar':
      if (metadata.baseMetadata!.dataLength == MAX) {
        return readMaxNChars(parser, callback);
      } else {
        return parser.readUInt16LE((dataLength) {
          if (dataLength == NULL) {
            return callback(null);
          }

          readNChars(parser, dataLength, callback);
        });
      }

    case 'VarBinary':
    case 'Binary':
      if (metadata.baseMetadata!.dataLength == MAX) {
        return readMaxBinary(parser, callback);
      } else {
        return parser.readUInt16LE((dataLength) {
          if (dataLength == NULL) {
            return callback(null);
          }

          readBinary(parser, dataLength, callback);
        });
      }

    case 'Text':
      return parser.readUInt8((textPointerLength) {
        if (textPointerLength == 0) {
          return callback(null);
        }

        parser.readBuffer(textPointerLength, (_textPointer) {
          parser.readBuffer(8, (_timestamp) {
            parser.readUInt32LE((dataLength) {
              readChars(parser, dataLength,
                  metadata.baseMetadata!.collation!.codepage!, callback);
            });
          });
        });
      });

    case 'NText':
      return parser.readUInt8((textPointerLength) {
        if (textPointerLength == 0) {
          return callback(null);
        }

        parser.readBuffer(textPointerLength, (_textPointer) {
          parser.readBuffer(8, (_timestamp) {
            parser.readUInt32LE((dataLength) {
              readNChars(parser, dataLength, callback);
            });
          });
        });
      });

    case 'Image':
      return parser.readUInt8((textPointerLength) {
        if (textPointerLength == 0) {
          return callback(null);
        }

        parser.readBuffer(textPointerLength, (_textPointer) {
          parser.readBuffer(8, (_timestamp) {
            parser.readUInt32LE((dataLength) {
              readBinary(parser, dataLength, callback);
            });
          });
        });
      });

    case 'Xml':
      return readMaxNChars(parser, callback);

    case 'SmallDateTime':
      return readSmallDateTime(parser, options.useUTC!, callback);

    case 'DateTime':
      return readDateTime(parser, options.useUTC!, callback);

    case 'DateTimeN':
      return parser.readUInt8((dataLength) {
        switch (dataLength) {
          case 0:
            return callback(null);

          case 4:
            return readSmallDateTime(parser, options.useUTC!, callback);
          case 8:
            return readDateTime(parser, options.useUTC!, callback);

          default:
            throw MTypeError(
                'Unsupported dataLength  $dataLength  for DateTimeN');
        }
      });

    case 'Time':
      return parser.readUInt8((dataLength) {
        if (dataLength == 0) {
          return callback(null);
        } else {
          return readTime(parser, dataLength, metadata.baseMetadata!.scale!,
              options.useUTC!, callback);
        }
      });

    case 'Date':
      return parser.readUInt8((dataLength) {
        if (dataLength == 0) {
          return callback(null);
        } else {
          return readDate(parser, options.useUTC!, callback);
        }
      });

    case 'DateTime2':
      return parser.readUInt8((dataLength) {
        if (dataLength == 0) {
          return callback(null);
        } else {
          return readDateTime2(parser, dataLength,
              metadata.baseMetadata!.scale!, options.useUTC!, callback);
        }
      });

    case 'DateTimeOffset':
      return parser.readUInt8((dataLength) {
        if (dataLength == 0) {
          return callback(null);
        } else {
          return readDateTimeOffset(
              parser, dataLength, metadata.baseMetadata!.scale!, callback);
        }
      });

    case 'NumericN':
    case 'DecimalN':
      return parser.readUInt8((dataLength) {
        if (dataLength == 0) {
          return callback(null);
        } else {
          return readNumeric(
              parser,
              dataLength,
              metadata.baseMetadata!.precision!,
              metadata.baseMetadata!.scale!,
              callback);
        }
      });

    case 'UniqueIdentifier':
      return parser.readUInt8((dataLength) {
        switch (dataLength) {
          case 0:
            return callback(null);

          case 0x10:
            return readUniqueIdentifier(parser, options, callback);

          default:
            throw MTypeError(
                sprintf('Unsupported guid size %d', dataLength - 1));
        }
      });

    case 'UDT':
      return readMaxBinary(parser, callback);

    case 'Variant':
      return parser.readUInt32LE((dataLength) {
        if (dataLength == 0) {
          return callback(null);
        }

        readVariant(parser, options, dataLength, callback);
      });

    default:
      throw MTypeError(sprintf('Unrecognised type %s', type.name));
  }
}

readUniqueIdentifier(
  StreamParser parser,
  ParserOptions options,
  void Function(dynamic value) callback,
) {
  parser.readBuffer(0x10, (data) {
    callback(options.lowerCaseGuids == true
        ? bufferToLowerCaseGuid(data)
        : bufferToUpperCaseGuid(data));
  });
}

readNumeric(
  StreamParser parser,
  num dataLength,
  num _precision,
  num scale,
  void Function(dynamic value) callback,
) {
  parser.readUInt8((sign) {
    sign = sign == 1 ? 1 : -1;

    dynamic readValue;
    if (dataLength == 5) {
      readValue = parser.readUInt32LE;
    } else if (dataLength == 9) {
      readValue = parser.readUinteric64LE;
    } else if (dataLength == 13) {
      readValue = parser.readUinteric96LE;
    } else if (dataLength == 17) {
      readValue = parser.readUinteric128LE;
    } else {
      throw MTypeError(
          sprintf('Unsupported numeric dataLength %d', dataLength));
    }

    readValue.call(parser, (value) {
      callback((value * sign) / pow(10, scale));
    });
  });
}

readVariant(
  StreamParser parser,
  ParserOptions options,
  int dataLength,
  void Function(dynamic value) callback,
) {
  return parser.readUInt8((baseType) {
    final type = DATATYPES[baseType]!;

    return parser.readUInt8((propBytes) {
      dataLength = dataLength - propBytes - 2;

      switch (type.name) {
        case 'UniqueIdentifier':
          return readUniqueIdentifier(parser, options, callback);

        case 'Bit':
          return readBit(parser, callback);

        case 'TinyInt':
          return readTinyInt(parser, callback);

        case 'SmallInt':
          return readSmallInt(parser, callback);

        case 'Int':
          return readInt(parser, callback);

        case 'BigInt':
          return readBigInt(parser, callback);

        case 'SmallDateTime':
          return readSmallDateTime(parser, options.useUTC!, callback);

        case 'DateTime':
          return readDateTime(parser, options.useUTC!, callback);

        case 'Real':
          return readReal(parser, callback);

        case 'Float':
          return readFloat(parser, callback);

        case 'SmallMoney':
          return readSmallMoney(parser, callback);

        case 'Money':
          return readMoney(parser, callback);

        case 'Date':
          return readDate(parser, options.useUTC!, callback);

        case 'Time':
          return parser.readUInt8((scale) {
            return readTime(
                parser, dataLength, scale, options.useUTC!, callback);
          });

        case 'DateTime2':
          return parser.readUInt8((scale) {
            return readDateTime2(
                parser, dataLength, scale, options.useUTC!, callback);
          });

        case 'DateTimeOffset':
          return parser.readUInt8((scale) {
            return readDateTimeOffset(parser, dataLength, scale, callback);
          });

        case 'VarBinary':
        case 'Binary':
          return parser.readUInt16LE((_maxLength) {
            readBinary(parser, dataLength, callback);
          });

        case 'NumericN':
        case 'DecimalN':
          return parser.readUInt8((precision) {
            parser.readUInt8((scale) {
              readNumeric(parser, dataLength, precision, scale, callback);
            });
          });

        case 'VarChar':
        case 'Char':
          return parser.readUInt16LE((_maxLength) {
            readCollation(parser, (collation) {
              readChars(parser, dataLength, collation.codepage!, callback);
            });
          });

        case 'NVarChar':
        case 'NChar':
          return parser.readUInt16LE((_maxLength) {
            readCollation(parser, (_collation) {
              readNChars(parser, dataLength, callback);
            });
          });

        default:
          throw MTypeError('Invalid type!');
      }
    });
  });
}

readBinary(
  StreamParser parser,
  int dataLength,
  void Function(dynamic value) callback,
) {
  return parser.readBuffer(dataLength, callback);
}

readChars(
  StreamParser parser,
  int dataLength,
  String? codepage,
  void Function(dynamic value) callback,
) {
  codepage ??= DEFAULT_ENCODING;

  return parser.readBuffer(dataLength, (data) {
    //TODO:callback(iconv.decode(data, codepage));
    callback(utf8.decode(data.buffer));
  });
}

readNChars(
  StreamParser parser,
  int dataLength,
  void Function(dynamic value) callback,
) {
  parser.readBuffer(dataLength, (data) {
    callback(data.toString_({'encoding': 'ucs2'}));
  });
}

readMaxBinary(
  StreamParser parser,
  void Function(dynamic value) callback,
) {
  return readMax(parser, callback);
}

readMaxChars(
  StreamParser parser,
  String? codepage,
  void Function(dynamic value) callback,
) {
  codepage ??= DEFAULT_ENCODING;

  readMax(parser, (data) {
    if (data != null) {
      // TODO:callback(iconv.decode(data, codepage));
      callback(utf8.decode(data.buffer));
    } else {
      callback(null);
    }
  });
}

readMaxNChars(
  StreamParser parser,
  void Function(String? value) callback,
) {
  readMax(parser, (data) {
    if (data != null) {
      callback(data.toString_({'encoding': 'ucs2'}));
    } else {
      callback(null);
    }
  });
}

readMax(
  StreamParser parser,
  void Function(Buffer? value) callback,
) {
  parser.readBuffer(8, (type) {
    if (type.equals(PLP_NULL)) {
      return callback(null);
    } else if (type.equals(UNKNOWN_PLP_LEN)) {
      return readMaxUnknownLength(parser, callback);
    } else {
      final low = type.readUInt32LE(0);
      final high = type.readUInt32LE(4);

      if (high >= (2 << (53 - 32))) {
        dev.log('Read UInt64LE > 53 bits : high= $high , low= $low');
      }

      final expectedLength = low + (0x100000000 * high);
      return readMaxKnownLength(parser, expectedLength, callback);
    }
  });
}

readMaxKnownLength(
  StreamParser parser,
  int totalLength,
  void Function(Buffer? value) callback,
) {
  final data = Buffer.alloc(totalLength, 0);

  var offset = 0;
  next(dynamic done) {
    parser.readUInt32LE((chunkLength) {
      if (chunkLength == 0) {
        //TODO: figure out this negating int ??
        return done();
      }

      parser.readBuffer(chunkLength, (chunk) {
        chunk.copy(data, offset);
        offset += chunkLength;

        next(done);
      });
    });
  }

  next(() {
    if (offset != totalLength) {
      throw MTypeError(
          'Partially Length-prefixed Bytes unmatched lengths : expected $totalLength, but got $offset bytes');
    }

    callback(data);
  });
}

readMaxUnknownLength(
  StreamParser parser,
  void Function(Buffer? value) callback,
) {
  List<Buffer> chunks = [];

  var length = 0;
  next(dynamic done) {
    parser.readUInt32LE((chunkLength) {
      if (chunkLength == 0) {
        return done();
      }

      parser.readBuffer(chunkLength, (chunk) {
        chunks.add(chunk);
        length += chunkLength;

        next(done);
      });
    });
  }

  next(() {
    callback(Buffer.concat(chunks, length));
  });
}

readSmallDateTime(
  StreamParser parser,
  bool useUTC,
  void Function(DateTime value) callback,
) {
  parser.readUInt16LE((days) {
    parser.readUInt16LE((minutes) {
      dynamic value;
      if (useUTC) {
        value = DateTime.utc(1900, 0, 1 + days, 0, minutes);
      } else {
        value = DateTime(1900, 0, 1 + days, 0, minutes);
      }
      callback(value);
    });
  });
}

readDateTime(
  StreamParser parser,
  bool useUTC,
  void Function(DateTime value) callback,
) {
  parser.readInt32LE((days) {
    parser.readUInt32LE((threeHundredthsOfSecond) {
      final milliseconds =
          (threeHundredthsOfSecond * THREE_AND_A_THIRD).round();

      dynamic value;
      if (useUTC) {
        value = DateTime.utc(1900, 0, 1 + days, 0, 0, 0, milliseconds);
      } else {
        value = DateTime(1900, 0, 1 + days, 0, 0, 0, milliseconds);
      }

      callback(value);
    });
  });
}

class DateWithNanosecondsDelta extends DateTime {
  //TODO: check for correct implementation
  DateWithNanosecondsDelta(
    this.dateTime,
    this.nanosecondsDelta,
  ) : super(DateTime.now().year);
  int? nanosecondsDelta;
  DateTime dateTime;
}

readTime(
  StreamParser parser,
  num dataLength,
  num scale,
  bool useUTC,
  void Function(DateWithNanosecondsDelta value) callback,
) {
  dynamic readValue;
  switch (dataLength) {
    case 3:
      readValue = parser.readUInt24LE;
      break;
    case 4:
      readValue = parser.readUInt32LE;
      break;
    case 5:
      readValue = parser.readUInt40LE;
  }
  readValue!.call(parser, (num value) {
    if (scale < 7) {
      for (num i = scale; i < 7; i++) {
        value *= 10;
      }
    }

    DateWithNanosecondsDelta date;
    if (useUTC) {
      date = DateWithNanosecondsDelta(
          DateTime.utc(1970, 0, 1, 0, 0, 0, value ~/ 10000),
          (value % 10000) / pow(10, 7) as int);
    } else {
      date = DateWithNanosecondsDelta(
          DateTime(1970, 0, 1, 0, 0, 0, value ~/ 10000),
          (value % 10000) / pow(10, 7) as int);
    }

    callback(date);
  });
}

readDate(
  StreamParser parser,
  bool useUTC,
  void Function(DateTime value) callback,
) {
  parser.readUInt24LE((days) {
    if (useUTC) {
      callback(DateTime.utc(2000, 0, days - 730118));
    } else {
      callback(DateTime(2000, 0, days - 730118));
    }
  });
}

readDateTime2(
  StreamParser parser,
  num dataLength,
  num scale,
  bool useUTC,
  void Function(DateWithNanosecondsDelta value) callback,
) {
  readTime(parser, dataLength - 3, scale, useUTC, (time) {
    // TODO: 'input' is 'time', but TypeScript cannot find "time.nanosecondsDelta";
    parser.readUInt24LE((days) {
      dynamic date;
      if (useUTC) {
        date = DateWithNanosecondsDelta(
          DateTime.utc(2000, 0, days - 730118, 0, 0, 0),
          time.nanosecondsDelta,
        );
      } else {
        date = DateWithNanosecondsDelta(
          DateTime(
            2000,
            0,
            days - 730118,
            time.dateTime.hour,
            time.dateTime.minute,
            time.dateTime.second,
            time.dateTime.millisecond,
          ),
          time.nanosecondsDelta,
        );
      }

      callback(date);
    });
  });
}

readDateTimeOffset(
  StreamParser parser,
  num dataLength,
  num scale,
  void Function(DateWithNanosecondsDelta value) callback,
) {
  readTime(parser, dataLength - 5, scale, true, (time) {
    parser.readUInt24LE((days) {
      // offset
      parser.readInt16LE((_) {
        final date = DateWithNanosecondsDelta(
          DateTime.utc(
              2000, 0, days - 730118, 0, 0, 0, time.nanosecondsDelta as int),
          time.nanosecondsDelta,
        );

        callback(date);
      });
    });
  });
}
