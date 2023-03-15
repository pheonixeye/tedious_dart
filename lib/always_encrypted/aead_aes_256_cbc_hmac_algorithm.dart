import 'dart:convert';
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:pointycastle/api.dart' as pcapi;
import 'package:pointycastle/block/modes/cbc.dart' as pcp;
import 'package:tedious_dart/always_encrypted/aead_aes_256_cbc_hmac_encryption_key.dart';
import 'package:tedious_dart/always_encrypted/types.dart';
import 'package:tedious_dart/models/errors.dart';

const algorithmName = 'AEAD_AES_256_CBC_HMAC_SHA256';
const algorithmVersion = 0x1;
const blockSizeInBytes = 16;

class AeadAes256CbcHmac256Algorithm implements EncryptionAlgorithm {
  late AeadAes256CbcHmac256EncryptionKey columnEncryptionkey;
  late bool isDeterministic;
  late num keySizeInBytes;
  late Buffer version;
  late Buffer versionSize;
  late num minimumCipherTextLengthInBytesNoAuthenticationTag;
  late num minimumCipherTextLengthInBytesWithAuthenticationTag;

  AeadAes256CbcHmac256Algorithm(
      {required AeadAes256CbcHmac256EncryptionKey columnEncryptionKey,
      required SQLServerEncryptionType encryptionType}) {
    keySizeInBytes = keySize / 8;
    version = Buffer.from([algorithmVersion]);
    versionSize = Buffer.from([1]);
    minimumCipherTextLengthInBytesNoAuthenticationTag =
        1 + blockSizeInBytes + blockSizeInBytes;
    minimumCipherTextLengthInBytesWithAuthenticationTag =
        minimumCipherTextLengthInBytesNoAuthenticationTag + keySizeInBytes;
    columnEncryptionkey = columnEncryptionKey;
    isDeterministic = encryptionType == SQLServerEncryptionType.Deterministic;
  }
  @override
  Buffer? decryptData(Buffer cipherText) {
    final Buffer iv = Buffer.alloc(blockSizeInBytes);

    num minimumCiperTextLength =
        minimumCipherTextLengthInBytesWithAuthenticationTag;

    if (cipherText.length < minimumCiperTextLength) {
      throw MTypeError(
          "Specified ciphertext has an invalid size of ${cipherText.length} bytes, which is below the minimum $minimumCiperTextLength bytes required for decryption.");
    }

    var startIndex = 0;
    if (cipherText[0] != algorithmVersion) {
      throw MTypeError(
          "The specified ciphertext's encryption algorithm version ${Buffer.from([
            cipherText[0]
          ]).toString_({
            'encoding': 'hex'
          })} does not match the expected encryption algorithm version $algorithmVersion.");
    }

    startIndex += 1;
    var authenticationTagOffset = 0;

    authenticationTagOffset = startIndex;
    startIndex += keySizeInBytes as int;

    cipherText.copy(iv, 0, startIndex, startIndex + iv.length);
    startIndex += iv.length;

    final cipherTextOffset = startIndex;
    final cipherTextCount = cipherText.length - startIndex;

    final Buffer authenticationTag = _prepareAuthenticationTag(
        iv, cipherText, cipherTextOffset, cipherTextCount);

    if (0 !=
        Buffer.compare(
          authenticationTag,
          cipherText,
        )) {
      throw MTypeError(
          'Specified ciphertext has an invalid authentication tag.');
    }

    Buffer plainText;

    // const decipher = createDecipheriv('aes-256-cbc', this.columnEncryptionkey.getEncryptionKey(), iv);
    final decipher = pcp.CBCBlockCipher(pcapi.BlockCipher('aes-256-cbc'))
      ..init(
          true,
          pcapi.ParametersWithIV(
            pcapi.KeyParameter(columnEncryptionkey.getEncryptionKey().buffer),
            iv.buffer,
          ));
    try {
      plainText = Buffer.from(decipher.process(cipherText
          .slice(cipherTextOffset, cipherTextOffset + cipherTextCount)
          .buffer));
      plainText = Buffer.concat([
        plainText,
        //TODO: decipher.process(plainText.buffer).last,
      ]);
    } catch (e) {
      throw MTypeError("Internal error while decryption: ${e.toString()}");
    }

    return plainText;
  }

  @override
  Buffer? encryptData(Buffer plainText) {
    late Buffer iv;

    if (isDeterministic == true) {
      var hmacIv = Hmac(sha256, columnEncryptionkey.getIvKey().buffer);
      var output = AccumulatorSink<Digest>();
      ByteConversionSink input = hmacIv.startChunkedConversion(output);
      input.add(plainText.buffer);
      input.close();
      Digest result = output.events.single;
      iv = Buffer.from(result).slice(0, blockSizeInBytes);
    } else {
      iv = Buffer.from(Random.secure().nextInt(blockSizeInBytes));
    }

    final encryptCipher = pcp.CBCBlockCipher(pcapi.BlockCipher('aes-256-cbc'))
      ..init(
          true,
          pcapi.ParametersWithIV(
            pcapi.KeyParameter(columnEncryptionkey.getEncryptionKey().buffer),
            iv.buffer,
          ));

    // final encryptCipher = createCipheriv(
    //     'aes-256-cbc', columnEncryptionkey.getEncryptionKey(), iv);

    final encryptedBuffer = Buffer.concat([
      Buffer(encryptCipher.process(plainText.buffer)),
      //TODO: encryptCipher.process(plainText.buffer).last
    ]);

    final authenticationTag = _prepareAuthenticationTag(
        iv, encryptedBuffer, 0, encryptedBuffer.length);

    return Buffer.concat([
      Buffer.from([algorithmVersion]),
      authenticationTag,
      iv,
      encryptedBuffer
    ]);
  }

  _prepareAuthenticationTag(
      Buffer iv, Buffer cipherText, int offset, int length) {
    var hmac = Hmac(sha256, columnEncryptionkey.getMacKey().buffer);
    var output = AccumulatorSink<Digest>();
    ByteConversionSink input = hmac.startChunkedConversion(output);
    input.add(version.buffer);
    input.add(iv.buffer);
    input.add(cipherText.slice(offset, offset + length).buffer);
    input.add(versionSize.buffer);
    input.close();
    Digest result = output.events.single;
    return Buffer.from(result);
  }
}
