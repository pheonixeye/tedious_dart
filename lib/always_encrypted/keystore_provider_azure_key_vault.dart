// ignore_for_file: unused_element

import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/always_encrypted/_keyvault_keys.dart';
import 'package:tedious_dart/extensions/locale_compare_on_string.dart';
import 'package:tedious_dart/models/errors.dart';

class CryptographyClient {
  dynamic masterKey;
  ClientSecretCredential credentials;
  CryptographyClient(this.masterKey, this.credentials);

  Future verify(String algorithm, Buffer dataToSign, Buffer signedHash) async {
    //TODO:
  }
}

class ParsedKeyPath {
  final String vaultUrl;
  final String name;
  final String? version;

  ParsedKeyPath({
    required this.vaultUrl,
    required this.name,
    this.version,
  });
}

//manufactured class
//TODO
class ClientSecretCredential {
  String clientId;
  String clientKey;
  String tenantId;
  ClientSecretCredential(
    this.clientId,
    this.clientKey,
    this.tenantId,
  );
}

//manufactured class
//TODO
class KeyClient {
  String url;
  ClientSecretCredential credentials;
  KeyClient(this.url, this.credentials);
  Future<KeyVaultKey> getKey(String name, String? version) async {
    return KeyVaultKey(null, null, [], null, name, null);
  }
}

class ColumnEncryptionAzureKeyVaultProvider {
  late String name;
  String? url;
  late String rsaEncryptionAlgorithmWithOAEPForAKV;
  late Buffer firstVersion;
  late ClientSecretCredential credentials;
  late String azureKeyVaultDomainName;
  KeyClient? keyClient;

  final String clientId;
  final String clientKey;
  final String tenantId;

  ColumnEncryptionAzureKeyVaultProvider({
    required this.clientId,
    required this.clientKey,
    required this.tenantId,
  }) {
    name = 'AZURE_KEY_VAULT';
    azureKeyVaultDomainName = 'vault.azure.net';
    rsaEncryptionAlgorithmWithOAEPForAKV = 'RSA-OAEP';
    firstVersion = Buffer.from([0x01]);
    credentials = ClientSecretCredential(
      clientId,
      clientKey,
      tenantId,
    );
  }
  Future<Buffer> decryptColumnEncryptionKey(String? masterKeyPath,
      String? encryptionAlgorithm, Buffer? encryptedColumnEncryptionKey) async {
    if (encryptedColumnEncryptionKey == null) {
      throw MTypeError(
          'Internal error. Encrypted column encryption key cannot be null.');
    }

    if (encryptedColumnEncryptionKey.length == 0) {
      throw MTypeError(
          'Internal error. Empty encrypted column encryption key specified.');
    }

    encryptionAlgorithm = _validateEncryptionAlgorithm(encryptionAlgorithm);

    final masterKey = await getMasterKey(masterKeyPath);

    final keySizeInBytes = _getAKVKeySize(masterKey);

    final cryptoClient = _createCryptoClient(masterKey);

    if (encryptedColumnEncryptionKey[0] != firstVersion[0]) {
      throw MTypeError(
          'Specified encrypted column encryption key contains an invalid encryption algorithm version ${Buffer.from([
            encryptedColumnEncryptionKey[0]
          ]).toString_({
            'encoding': 'hex'
          })}. Expected version is ${Buffer.from([firstVersion[0]]).toString_({
            'encoding': 'hex'
          })}.');
    }

    int currentIndex = firstVersion.length;
    final keyPathLength =
        encryptedColumnEncryptionKey.readInt16LE(currentIndex);

    currentIndex += 2;

    final cipherTextLength =
        encryptedColumnEncryptionKey.readInt16LE(currentIndex);

    currentIndex += 2;

    currentIndex += keyPathLength as int;

    if (cipherTextLength != keySizeInBytes) {
      throw MTypeError(
          "The specified encrypted column encryption key's ciphertext length: $cipherTextLength does not match the ciphertext length: $keySizeInBytes when using column master key (Azure Key Vault key) in $masterKeyPath. The encrypted column encryption key may be corrupt, or the specified Azure Key Vault key path may be incorrect.");
    }

    final signatureLength =
        encryptedColumnEncryptionKey.length - currentIndex - cipherTextLength;

    if (signatureLength != keySizeInBytes) {
      throw MTypeError(
          "The specified encrypted column encryption key's signature length: $signatureLength does not match the signature length: $keySizeInBytes when using column master key (Azure Key Vault key) in $masterKeyPath. The encrypted column encryption key may be corrupt, or the specified Azure Key Vault key path may be incorrect.");
    }

    final cipherText = Buffer.alloc(cipherTextLength as int);
    encryptedColumnEncryptionKey.copy(
        cipherText, 0, currentIndex, currentIndex + cipherTextLength);
    currentIndex += cipherTextLength;

    final signature = Buffer.alloc(signatureLength as int);
    encryptedColumnEncryptionKey.copy(
        signature, 0, currentIndex, currentIndex + signatureLength);

    final hash =
        Buffer.alloc(encryptedColumnEncryptionKey.length - signature.length);
    encryptedColumnEncryptionKey.copy(
        hash, 0, 0, encryptedColumnEncryptionKey.length - signature.length);

    // final messageDigest = createHash('sha256');
    // messageDigest.update(hash);
    // final messageDigest = createHash('sha256');
    var messageDigest = Hmac(sha256, []);
    var output = AccumulatorSink<Digest>();
    ByteConversionSink input = messageDigest.startChunkedConversion(output);
    input.add(hash.buffer);
    input.close();
    Digest result = output.events.single;
    late Buffer? dataToVerify;
    dataToVerify = Buffer.from(result.bytes);

    if (dataToVerify == null) {
      throw MTypeError(
          'Hash should not be null while decrypting encrypted column encryption key.');
    }

    final verifyKey =
        await cryptoClient.verify('RS256', dataToVerify, signature);
    if (!verifyKey.result) {
      throw MTypeError(
          "The specified encrypted column encryption key signature does not match the signature computed with the column master key (Asymmetric key in Azure Key Vault) in $masterKeyPath. The encrypted column encryption key may be corrupt, or the specified path may be incorrect.");
    }

    final Buffer decryptedCEK = await _azureKeyVaultUnWrap(
        cryptoClient, encryptionAlgorithm, cipherText);

    return decryptedCEK;
  }

  Future<Buffer> encryptColumnEncryptionKey(String? masterKeyPath,
      String? encryptionAlgorithm, Buffer? columnEncryptionKey) async {
    if (columnEncryptionKey == null) {
      throw MTypeError('Column encryption key cannot be null.');
    }

    if (columnEncryptionKey.length == 0) {
      throw MTypeError('Empty column encryption key specified.');
    }

    encryptionAlgorithm = _validateEncryptionAlgorithm(encryptionAlgorithm);

    final masterKey = await getMasterKey(masterKeyPath);

    final keySizeInBytes = _getAKVKeySize(masterKey);

    final cryptoClient = _createCryptoClient(masterKey);

    final version = Buffer.from([firstVersion[0]]);

    final Buffer masterKeyPathBytes =
        Buffer.from(masterKeyPath!.toLowerCase(), 0, 0, 'utf8');

    final Buffer keyPathLength = Buffer.alloc(2);

    keyPathLength[0] = masterKeyPathBytes.length & 0xff;
    keyPathLength[1] = masterKeyPathBytes.length >> 8 & 0xff;

    final Buffer cipherText = await _azureKeyVaultWrap(
        cryptoClient, encryptionAlgorithm, columnEncryptionKey);

    final Buffer cipherTextLength = Buffer.alloc(2);

    cipherTextLength[0] = cipherText.length & 0xff;
    cipherTextLength[1] = cipherText.length >> 8 & 0xff;

    if (cipherText.length != keySizeInBytes) {
      throw MTypeError('CipherText length does not match the RSA key size.');
    }

    Buffer dataToHash = Buffer.alloc(version.length +
        keyPathLength.length +
        cipherTextLength.length +
        masterKeyPathBytes.length +
        cipherText.length);
    int destinationPosition = version.length;
    version.copy(dataToHash, 0, 0, version.length);

    keyPathLength.copy(
        dataToHash, destinationPosition, 0, keyPathLength.length);
    destinationPosition += keyPathLength.length;

    cipherTextLength.copy(
        dataToHash, destinationPosition, 0, cipherTextLength.length);
    destinationPosition += cipherTextLength.length;

    masterKeyPathBytes.copy(
        dataToHash, destinationPosition, 0, masterKeyPathBytes.length);
    destinationPosition += masterKeyPathBytes.length;

    cipherText.copy(dataToHash, destinationPosition, 0, cipherText.length);

    // final messageDigest = createHash('sha256');
    var messageDigest = Hmac(sha256, []);
    var output = AccumulatorSink<Digest>();
    ByteConversionSink input = messageDigest.startChunkedConversion(output);
    input.add(dataToHash.buffer);
    input.close();
    Digest result = output.events.single;

    // messageDigest.update(dataToHash);

    final Buffer dataToSign = Buffer.from(result.bytes);
    // messageDigest.digest();

    final Buffer signedHash =
        await _azureKeyVaultSignedHashedData(cryptoClient, dataToSign);
    if (signedHash.length != keySizeInBytes) {
      throw MTypeError('Signed hash length does not match the RSA key size.');
    }

    final verifyKey =
        await cryptoClient.verify('RS256', dataToSign, signedHash);

    if (!verifyKey.result) {
      throw MTypeError(
          'Invalid signature of the encrypted column encryption key computed.');
    }

    final int encryptedColumnEncryptionKeyLength = version.length +
        cipherTextLength.length +
        keyPathLength.length +
        cipherText.length +
        masterKeyPathBytes.length +
        signedHash.length;
    final Buffer encryptedColumnEncryptionKey =
        Buffer.alloc(encryptedColumnEncryptionKeyLength);

    int currentIndex = 0;
    version.copy(encryptedColumnEncryptionKey, currentIndex, 0, version.length);
    currentIndex += version.length;

    keyPathLength.copy(
        encryptedColumnEncryptionKey, currentIndex, 0, keyPathLength.length);
    currentIndex += keyPathLength.length;

    cipherTextLength.copy(
        encryptedColumnEncryptionKey, currentIndex, 0, cipherTextLength.length);
    currentIndex += cipherTextLength.length;

    masterKeyPathBytes.copy(encryptedColumnEncryptionKey, currentIndex, 0,
        masterKeyPathBytes.length);
    currentIndex += masterKeyPathBytes.length;

    cipherText.copy(
        encryptedColumnEncryptionKey, currentIndex, 0, cipherText.length);
    currentIndex += cipherText.length;

    signedHash.copy(
        encryptedColumnEncryptionKey, currentIndex, 0, signedHash.length);

    return encryptedColumnEncryptionKey;
  }

  Future<KeyVaultKey> getMasterKey(String? masterKeyPath) async {
    if (masterKeyPath == null) {
      throw MTypeError('Master key path cannot be null or undefined');
    }
    final keyParts = _parsePath(masterKeyPath);

    createKeyClient(keyParts.vaultUrl);

    return await (keyClient as KeyClient)
        .getKey(keyParts.name, keyParts.version);
  }

  void createKeyClient(String? keyVaultUrl) {
    if (keyVaultUrl == null) {
      throw MTypeError(
          'Cannot create key client with null or undefined keyVaultUrl');
    }
    if (keyClient != null) {
      url = keyVaultUrl;
      keyClient = KeyClient(keyVaultUrl, credentials);
    }
  }

  //TODO:KeyVaultKey _createCryptoClient(CryptographyClient masterKey){}
  CryptographyClient _createCryptoClient(dynamic masterKey) {
    if (masterKey == null) {
      throw MTypeError(
          'Cannot create CryptographyClient with null or undefined masterKey');
    }
    return CryptographyClient(masterKey, credentials);
  }

  ParsedKeyPath _parsePath(String? masterKeyPath) {
    if (masterKeyPath == null || masterKeyPath.trim() == '') {
      throw MTypeError('Azure Key Vault key path cannot be null.');
    }
    Uri baseUri;
    try {
      baseUri = Uri.parse(masterKeyPath);
    } catch (e) {
      throw MTypeError(
          'Invalid keys identifier: $masterKeyPath. Not a valid URI');
    }
    final segments = baseUri.pathSegments;
    if (segments.length != 3 && segments.length != 4) {
      throw MTypeError(
          'Invalid keys identifier: $masterKeyPath. Bad number of segments: ${segments.length}');
    }

    if ('keys' != segments[1]) {
      throw MTypeError(
          'Invalid keys identifier: $masterKeyPath. segment [1] should be "keys", found "${segments[1]}"');
    }
    final vaultUrl = '${baseUri.scheme}//${baseUri.host}';
    final name = segments[2];
    final version = segments.length == 4 ? segments[3] : null;
    return ParsedKeyPath(
      vaultUrl: vaultUrl,
      name: name,
      version: version,
    );
  }

  Future<Buffer> _azureKeyVaultSignedHashedData(
    dynamic cryptoClient,
    Buffer dataToSign,
  ) async {
    if (cryptoClient == null) {
      throw MTypeError('Azure KVS Crypto Client is not defined.');
    }

    final signedData = await cryptoClient.sign('RS256', dataToSign);

    return Buffer.from(signedData.result);
  }

  Future<Buffer> _azureKeyVaultWrap(
    dynamic cryptoClient,
    //TODO: CrptographyClient? cryptoClient,
    String? encryptionAlgorithm,
    Buffer? encryptedColumnEncryptionKey,
  ) async {
    if (cryptoClient == null) {
      throw MTypeError('Azure KVS Crypto Client is not defined.');
    }

    if (encryptionAlgorithm == null) {
      throw MTypeError('Encryption Algorithm cannot be null or undefined');
    }

    if (encryptedColumnEncryptionKey == null) {
      throw MTypeError('Encrypted column encryption key cannot be null.');
    }

    final unwrappedKey = await cryptoClient.wrapKey(
        encryptionAlgorithm, encryptedColumnEncryptionKey);
    //TODO: encryptionAlgorithm as KeyWrapAlgorithm
    return Buffer.from(unwrappedKey.result);
  }

  Future<Buffer> _azureKeyVaultUnWrap(
    dynamic cryptoClient,
    //TODO: CrptographyClient? cryptoClient,
    String? encryptionAlgorithm,
    Buffer? encryptedColumnEncryptionKey,
  ) async {
    if (cryptoClient == null) {
      throw MTypeError('Azure KVS Crypto Client is not defined.');
    }

    if (encryptionAlgorithm == null) {
      throw MTypeError('Encryption Algorithm cannot be null or undefined');
    }

    if (encryptedColumnEncryptionKey == null) {
      throw MTypeError('Encrypted column encryption key cannot be null.');
    }

    if (encryptedColumnEncryptionKey.length == 0) {
      throw MTypeError(
          'Encrypted Column Encryption Key length should not be zero.');
    }

    final unwrappedKey = await cryptoClient.unwrapKey(
        encryptionAlgorithm, encryptedColumnEncryptionKey);
    //TODO: encryptionAlgorithm as KeyWrapAlgorithm
    return Buffer.from(unwrappedKey.result);
  }

  int _getAKVKeySize(dynamic retrievedKey) {
    //TODO:KeyVaultKey retreivedKey
    if (retrievedKey == null) {
      throw MTypeError('Retrieved key cannot be null or undefined');
    }
    final key = retrievedKey.key;

    if (key == null) {
      throw MTypeError('Key does not exist ${retrievedKey.name}');
    }

    final String? kty = key + key.kty + key.kty.toString().toUpperCase();

    if (kty == null || 'RSA'.localeCompare(kty, 'en') != 0) {
      throw MTypeError('Cannot use a non-RSA key: $kty.');
    }

    final keyLength = (key + key.n + key.n).length;

    return keyLength == 0 ? 0 : keyLength;
  }

  String _validateEncryptionAlgorithm(String? encryptionAlgorithm) {
    //TODO:implement locale compare
    if (encryptionAlgorithm == null) {
      throw MTypeError('Key encryption algorithm cannot be null.');
    }
    if ('RSA_OAEP'.localeCompare(encryptionAlgorithm.toUpperCase(), 'en') ==
        0) {
      encryptionAlgorithm = 'RSA-OAEP';
    }

    if (rsaEncryptionAlgorithmWithOAEPForAKV.localeCompare(
            encryptionAlgorithm.trim().toUpperCase(), 'en') !=
        0) {
      throw MTypeError(
          'Invalid key encryption algorithm specified: $encryptionAlgorithm. Expected value: $rsaEncryptionAlgorithmWithOAEPForAKV.');
    }

    return encryptionAlgorithm;
  }
}
