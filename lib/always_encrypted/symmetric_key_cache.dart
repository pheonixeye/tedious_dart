import 'package:dcache/dcache.dart';
import 'package:node_interop/node_interop.dart';
import 'package:tedious_dart/always_encrypted/symmetric_key.dart';
import 'package:tedious_dart/always_encrypted/types.dart';
import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/models/errors.dart';

final cache = SimpleCache(storage: InMemoryStorage<String, SymmetricKey>(0));

Future<SymmetricKey> getKey(
    EncryptionKeyInfo keyInfo, ConnectionOptions options) async {
  if (options.trustedServerNameAE == null) {
    throw MTypeError('Server name should not be null in getKey');
  }

  String serverName = options.trustedServerNameAE!;

  var keyLookupValue =
      "$serverName:${Buffer.from(keyInfo.encryptedKey).toString('base64')}:${keyInfo.keyStoreName}";

  if (cache.containsKey(keyLookupValue)) {
    return cache.get(keyLookupValue) as SymmetricKey;
  } else {
    dynamic provider = //options.encryptionKeyStoreProviders &&
        options.encryptionKeyStoreProviders[keyInfo.keyStoreName];
    if (provider == null) {
      throw MTypeError(
          "Failed to decrypt a column encryption key. Invalid key store provider name: ${keyInfo.keyStoreName}. A key store provider name must denote either a system key store provider or a registered custom key store provider. Valid (currently registered) custom key store provider names are: ${options.encryptionKeyStoreProviders}. Please verify key store provider information in column master key definitions in the database, and verify all custom key store providers used in your application are registered properly.");
    }

    Buffer plaintextKey = await provider.decryptColumnEncryptionKey(
        keyInfo.keyPath, keyInfo.algorithmName, keyInfo.encryptedKey);

    final encryptionKey = SymmetricKey(plaintextKey);

    if (options.columnEncryptionKeyCacheTTL > 0) {
      cache.set(keyLookupValue, encryptionKey).expiration =
          Duration(seconds: options.columnEncryptionKeyCacheTTL as int);
    }

    return encryptionKey;
  }
}
