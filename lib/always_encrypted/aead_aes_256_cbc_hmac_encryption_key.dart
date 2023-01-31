import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/always_encrypted/symmetric_key.dart';
import 'package:tedious_dart/models/errors.dart';
// import 'package:crypto/crypto.dart';

const keySize = 256;
const keySizeInBytes = keySize / 8;

//todo: recheck
Buffer deriveKey(Buffer rootKey, String salt) {
  var hmac = Hmac(sha256, rootKey.buffer);
  var output = AccumulatorSink<Digest>();
  ByteConversionSink input = hmac.startChunkedConversion(output);
  input.add(Buffer.from(salt, 'utf16le').buffer);
  input.close();
  Digest result = output.events.single;
  return Buffer.from(result);
}

String generateKeySalt(
  String keyType,
  String algorithmName,
  num keySize,
) =>
    'Microsoft SQL Server cell $keyType key '
    'with encryption algorithm:$algorithmName and key length:$keySize';

class AeadAes256CbcHmac256EncryptionKey extends SymmetricKey {
  late final String algorithmName;
  late String encryptionKeySaltFormat;
  late String macKeySaltFormat;
  late String ivKeySaltFormat;
  late SymmetricKey encryptionKey;
  late SymmetricKey macKey;
  late SymmetricKey ivKey;
  AeadAes256CbcHmac256EncryptionKey({
    required Buffer rootKey,
    required String algorithmName,
  }) : super(rootKey) {
    algorithmName = algorithmName;
    encryptionKeySaltFormat =
        generateKeySalt('encryption', this.algorithmName, keySize);
    macKeySaltFormat = generateKeySalt('MAC', this.algorithmName, keySize);
    ivKeySaltFormat = generateKeySalt('IV', this.algorithmName, keySize);

    if (rootKey.length != keySizeInBytes) {
      throw MTypeError(
          "The column encryption key has been successfully decrypted but it's length: ${rootKey.length} does not match the length: ${keySizeInBytes} for algorithm ${this.algorithmName}. Verify the encrypted value of the column encryption key in the database.");
    }

    try {
      final encKeyBuff = deriveKey(rootKey, encryptionKeySaltFormat);

      encryptionKey = SymmetricKey(encKeyBuff);

      final macKeyBuff = deriveKey(rootKey, macKeySaltFormat);

      macKey = SymmetricKey(macKeyBuff);

      final ivKeyBuff = deriveKey(rootKey, ivKeySaltFormat);

      ivKey = SymmetricKey(ivKeyBuff);
    } catch (e) {
      throw MTypeError('Key extraction failed : ${e.toString()}.');
    }
  }
  Buffer getEncryptionKey() {
    return encryptionKey.rootKey!;
  }

  Buffer getMacKey() {
    return macKey.rootKey!;
  }

  Buffer getIvKey() {
    return ivKey.rootKey!;
  }
}
