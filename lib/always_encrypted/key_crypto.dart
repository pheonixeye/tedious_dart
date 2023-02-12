// ignore_for_file: non_constant_identifier_names

import 'package:node_interop/node_interop.dart';
import 'package:tedious_dart/always_encrypted/aead_aes_256_cbc_hmac_algorithm.dart';
import 'package:tedious_dart/always_encrypted/aead_aes_256_cbc_hmac_encryption_key.dart';
import 'package:tedious_dart/always_encrypted/symmetric_key.dart';
import 'package:tedious_dart/always_encrypted/symmetric_key_cache.dart';
import 'package:tedious_dart/always_encrypted/types.dart';
import 'package:tedious_dart/conn_config.dart';
import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/models/errors.dart';

String validateAndGetEncryptionAlgorithmName(
  int cipherAlgorithmId,
  String? cipherAlgorithmName,
) {
  if (cipherAlgorithmId != 2) {
    throw MTypeError('Custom cipher algorithm not supported.');
  }

  return algorithmName;
}

Future<Buffer> encryptWithKey(
    Buffer plaintext, CryptoMetadata md, ConnectionOptions options) async {
  if (options.trustedServerNameAE == null) {
    throw MTypeError('Server name should not be null in EncryptWithKey');
  }

  if (md.cipherAlgorithm == null) {
    await decryptSymmetricKey(md, options);
  }

  if (md.cipherAlgorithm == null) {
    throw MTypeError('Cipher Algorithm should not be null in EncryptWithKey');
  }

  final Buffer? cipherText = md.cipherAlgorithm?.encryptData(plaintext);

  if (cipherText == null) {
    throw MTypeError('Internal error. Ciphertext value cannot be null.');
  }

  return cipherText;
}

Buffer decryptWithKey(
    Buffer cipherText, CryptoMetadata md, ConnectionOptions options) {
  if (options.trustedServerNameAE == null) {
    throw MTypeError('Server name should not be null in DecryptWithKey');
  }

  // if (!md.cipherAlgorithm) {
  //   await decryptSymmetricKey(md, options);
  // }

  if (md.cipherAlgorithm == null) {
    throw MTypeError('Cipher Algorithm should not be null in DecryptWithKey');
  }

  final Buffer? plainText = md.cipherAlgorithm?.decryptData(cipherText);

  if (plainText == null) {
    throw MTypeError('Internal error. Plaintext value cannot be null.');
  }

  return plainText;
}

Future<void> decryptSymmetricKey(
    CryptoMetadata? md, ConnectionOptions options) async {
  if (md == null) {
    throw MTypeError('md should not be null in DecryptSymmetricKey.');
  }

  if (md.cekEntry == null) {
    throw MTypeError(
        'md.EncryptionInfo should not be null in DecryptSymmetricKey.');
  }

  if (md.cekEntry!.columnEncryptionKeyValues.isEmpty) {
    throw MTypeError(
        'md.EncryptionInfo.ColumnEncryptionKeyValues should not be null in DecryptSymmetricKey.');
  }

  SymmetricKey? symKey;
  EncryptionKeyInfo? encryptionKeyInfoChosen;
  List<EncryptionKeyInfo>? CEKValues = md.cekEntry?.columnEncryptionKeyValues;
  MTypeError? lastError;

  for (var CEKValue in CEKValues!) {
    try {
      symKey = await getKey(CEKValue, options);
      if (symKey.rootKey != null) {
        encryptionKeyInfoChosen = CEKValue;
        break;
      }
    } catch (e) {
      lastError = MTypeError(e.toString());
    }
  }

  if (symKey != null) {
    if (lastError != null) {
      throw lastError;
    } else {
      throw MTypeError(
          'Exception while decryption of encrypted column encryption key.');
    }
  }

  var algorithmName = validateAndGetEncryptionAlgorithmName(
      md.cipherAlgorithmId as int, md.cipherAlgorithmName);
  var cipherAlgorithm = AeadAes256CbcHmac256Algorithm(
      columnEncryptionKey: AeadAes256CbcHmac256EncryptionKey(
          rootKey: symKey!.rootKey!, algorithmName: algorithmName),
      encryptionType: md.encryptionType);

  md.cipherAlgorithm = cipherAlgorithm;
  md.encryptionKeyInfo = encryptionKeyInfoChosen as EncryptionKeyInfo;
}
