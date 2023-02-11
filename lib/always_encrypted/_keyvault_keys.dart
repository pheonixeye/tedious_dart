//ignore_for_file:slash_for_doc_comments;, slash_for_doc_comments, prefer_typing_uninitialized_variables, body_might_complete_normally_nullable, unused_element, constant_identifier_names

import 'dart:typed_data';

/**
 * Decryption parameters for AES-CBC encryption algorithms.
 */
abstract class AesCbcDecryptParameters {
  AesCbcDecryptParameters(this.algorithm, this.ciphertext, this.iv);
  /**
     * The encryption algorithm to use.
     */
  AesCbcEncryptionAlgorithm algorithm;
  /**
     * The initialization vector used during encryption.
     */

  /**
     * The ciphertext to decrypt.
     */
  Uint8List ciphertext;
  /**
     * The initialization vector generated during encryption.
     */
  Uint8List iv;
}
/**
 * A union type representing all supported AES-CBC encryption algorithms.
 */

/**
 * Encryption parameters for AES-CBC encryption algorithms.
 */
abstract class AesCbcEncryptParameters {
  AesCbcEncryptParameters(this.algorithm, this.iv, this.plaintext);
  /**
     * The encryption algorithm to use.
     */
  AesCbcEncryptionAlgorithm algorithm;
  /**
     * The plain text to encrypt.
     */
  Uint8List plaintext;
  /**
     * The initialization vector used for encryption. If omitted we will attempt to generate an IV using crypto's `randomBytes` functionality.
     * An error will be thrown if creating an IV fails, and you may recover by passing in your own cryptographically secure IV.
     */
  Uint8List iv;
}

class AesCbcEncryptionAlgorithm {}

/**
 * Decryption parameters for AES-GCM encryption algorithms.
 */
abstract class AesGcmDecryptParameters {
  AesGcmDecryptParameters(
    this.additionalAuthenticatedData,
    this.algorithm,
    this.authenticationTag,
    this.ciphertext,
    this.iv,
  );
  /**
     * The encryption algorithm to use.
     */
  AesGcmEncryptionAlgorithm algorithm;
  /**
     * The ciphertext to decrypt.
     */
  Uint8List ciphertext;
  /**
     * The initialization vector (or nonce) generated during encryption.
     */
  Uint8List iv;
  /**
     * The authentication tag generated during encryption.
     */
  Uint8List authenticationTag;
  /**
     * Optional data that is authenticated but not encrypted.
     */
  Uint8List additionalAuthenticatedData;
}
/**
 * A union type representing all supported AES-GCM encryption algorithms.
 */

/**
 * Encryption parameters for AES-GCM encryption algorithms.
 */
abstract class AesGcmEncryptParameters {
  AesGcmEncryptParameters(
    this.additionalAuthenticatedData,
    this.algorithm,
    this.plaintext,
  );
  /**
     * The encryption algorithm to use.
     */
  AesGcmEncryptionAlgorithm algorithm;
  /**
     * The plain text to encrypt.
     */
  Uint8List plaintext;
  /**
     * Optional data that is authenticated but not encrypted.
     */
  Uint8List additionalAuthenticatedData;
}

class AesGcmEncryptionAlgorithm {}

/**
 * Options for [backupKey].
 */
abstract class BackupKeyOptions implements OperationOptions {}

class OperationOptions {}

/**
 * An interface representing the optional parameters that can be
 * passed to [beginDeleteKey]
 */
abstract class BeginDeleteKeyOptions implements KeyPollerOptions {}

/**
 * An interface representing the optional parameters that can be
 * passed to [beginRecoverDeletedKey]
 */
abstract class BeginRecoverDeletedKeyOptions implements KeyPollerOptions {}

/**
 * An interface representing the optional parameters that can be
 * passed to [createEcKey]
 */
abstract class CreateEcKeyOptions implements CreateKeyOptions {}

/**
 * An interface representing the optional parameters that can be
 * passed to [createKey]
 */
abstract class CreateKeyOptions implements OperationOptions {
  /**
     * Application specific metadata in the form of key-value pairs.
     */
  Map<String, String> get tags;
  /**
     * Json web key operations. For more
     * information on possible key operations, see KeyOperation.
     */
  List<KeyOperation> get keyOps;
  /**
     * Determines whether the object is enabled.
     */
  bool get enabled;
  /**
     * Not before DateTime in UTC.
     */
  DateTime get notBefore;
  /**
     * Expiry DateTime in UTC.
     */
  DateTime get expiresOn;
  /**
     * The key size in bits. For example: 2048, 3072, or 4096 for RSA.
     */
  num get keySize;
  /**
     * Elliptic curve name. For valid values, see KeyCurveName.
     * Possible values include: 'P-256', 'P-384', 'P-521', 'P-256K'
     */
  KeyCurveName get curve;
  /**
     * Whether to import as a hardware key (HSM) or software key.
     */
  bool get hsm;
  /**
     * Indicates whether the private key can be exported.
     */
  bool get exportable;
  /**
     * A [KeyReleasePolicy] object specifying the rules under which the key can be exported.
     */
  KeyReleasePolicy get releasePolicy;
}

/**
 * An interface representing the optional parameters that can be
 * passed to [createOctKey]
 */
abstract class CreateOctKeyOptions implements CreateKeyOptions {}

/**
 * An interface representing the optional parameters that can be
 * passed to [createRsaKey]
 */
abstract class CreateRsaKeyOptions implements CreateKeyOptions {
  /** The public exponent for a RSA key. */
  num get publicExponent;
}

/**
 * A client used to perform cryptographic operations on an Azure Key vault key
 * or a local [JsonWebKey].
 */
class _CryptographyClient {
  _CryptographyClient(
      this.key_2,
      this.key,
      TokenCredential credential,
      CryptographyClientOptions pipelineOptions,
      this.keyID,
      this.remoteProvider,
      this.vaultUrl);
  /**
     * The key the CryptographyClient currently holds.
     */
  KeyVaultKey key;
  /**
     * The remote provider, which would be undefined if used in local mode.
     */
  var remoteProvider;

  JsonWebKey_2 key_2;
  /**
     * The base URL to the vault. If a local [JsonWebKey] is used vaultUrl will be empty.
     */
  String vaultUrl;
  /**
     * The ID of the key used to perform cryptographic operations for the client.
     */
  String keyID;
}

class TokenCredential {}
/**
     * Encrypts the given plaintext with the specified encryption parameters.
     * Depending on the algorithm set in the encryption parameters, the set of possible encryption parameters will change.
     *
     * Example usage:
     * ```ts
     * let client = new CryptographyClient(keyVaultKey, credentials);
     * let result = await client.encrypt({ algorithm: "RSA1_5", plaintext: Buffer.from("My Message")});
     * let result = await client.encrypt({ algorithm: "A256GCM", plaintext: Buffer.from("My Message"), additionalAuthenticatedData: Buffer.from("My authenticated data")});
     * ```
     * 
     * 
     */

Future<EncryptResult> encrypt(EncryptParameters encryptParameters,
    [EncryptOptions? options]) {
  // TODO: implement encrypt
  throw UnimplementedError();
}

/**
     * Encrypts the given plaintext with the specified cryptography algorithm
     *
     * Example usage:
     * ```ts
     * let client = new CryptographyClient(keyVaultKey, credentials);
     * let result = await client.encrypt("RSA1_5", Buffer.from("My Message"));
     * ```
     * 
     * 
     * 
     *  Use `encrypt({ algorithm, plaintext }, options)` instead.
     */
@override
Future<EncryptResult>? _encrypt(
    EncryptionAlgorithm algorithm, Uint8List plaintext,
    [EncryptOptions? options]) {}

var initializeIV;
/**
     * Standardizes the arguments of multiple overloads into a single shape.
     * 
     */
var disambiguateEncryptArguments;
/**
     * Decrypts the given ciphertext with the specified decryption parameters.
     * Depending on the algorithm used in the decryption parameters, the set of possible decryption parameters will change.
     *
     * Example usage:
     * ```ts
     * let client = new CryptographyClient(keyVaultKey, credentials);
     * let result = await client.decrypt({ algorithm: "RSA1_5", ciphertext: encryptedBuffer });
     * let result = await client.decrypt({ algorithm: "A256GCM", iv: ivFromEncryptResult, authenticationTag: tagFromEncryptResult });
     * ```
     * 
     * 
     */
Future<DecryptResult> decrypt(DecryptParameters decryptParameters,
    [DecryptOptions? options]) {
  // TODO: implement decrypt
  throw UnimplementedError();
}

/**
     * Decrypts the given ciphertext with the specified cryptography algorithm
     *
     * Example usage:
     * ```ts
     * let client = new CryptographyClient(keyVaultKey, credentials);
     * let result = await client.decrypt("RSA1_5", encryptedBuffer);
     * ```
     * 
     * 
     * 
     *  Use `decrypt({ algorithm, ciphertext }, options)` instead.
     */
Future<DecryptResult>? decrypt_(
    EncryptionAlgorithm algorithm, Uint8List ciphertext,
    [DecryptOptions? options]) {}
/**
     * Standardizes the arguments of multiple overloads into a single shape.
     * 
     */
var disambiguateDecryptArguments;
/**
     * Wraps the given key using the specified cryptography algorithm
     *
     * Example usage:
     * ```ts
     * let client = new CryptographyClient(keyVaultKey, credentials);
     * let result = await client.wrapKey("RSA1_5", keyToWrap);
     * ```
     * 
     * 
     * 
     */
Future<WrapResult> wrapKey(KeyWrapAlgorithm algorithm, Uint8List key,
    [WrapKeyOptions? options]) {
  // TODO: implement wrapKey
  throw UnimplementedError();
}

/**
     * Unwraps the given wrapped key using the specified cryptography algorithm
     *
     * Example usage:
     * ```ts
     * let client = new CryptographyClient(keyVaultKey, credentials);
     * let result = await client.unwrapKey("RSA1_5", keyToUnwrap);
     * ```
     * 
     * 
     * 
     */
Future<UnwrapResult> unwrapKey(
    KeyWrapAlgorithm algorithm, Uint8List encryptedKey,
    [UnwrapKeyOptions? options]) {
  // TODO: implement unwrapKey
  throw UnimplementedError();
}

/**
     * Cryptographically sign the digest of a message
     *
     * Example usage:
     * ```ts
     * let client = new CryptographyClient(keyVaultKey, credentials);
     * let result = await client.sign("RS256", digest);
     * ```
     * 
     * 
     * 
     */
Future<SignResult> sign(SignatureAlgorithm algorithm, Uint8List digest,
    [SignOptions? options]) {
  // TODO: implement sign
  throw UnimplementedError();
}

/**
     * Verify the signed message digest
     *
     * Example usage:
     * ```ts
     * let client = new CryptographyClient(keyVaultKey, credentials);
     * let result = await client.verify("RS256", signedDigest, signature);
     * ```
     * 
     * 
     * 
     * 
     */
Future<VerifyResult> verify(
    SignatureAlgorithm algorithm, Uint8List digest, Uint8List signature,
    [VerifyOptions? options]) {
  // TODO: implement verify
  throw UnimplementedError();
}

/**
     * Cryptographically sign a block of data
     *
     * Example usage:
     * ```ts
     * let client = new CryptographyClient(keyVaultKey, credentials);
     * let result = await client.signData("RS256", message);
     * ```
     * 
     * 
     * 
     */
Future<SignResult> signData(SignatureAlgorithm algorithm, Uint8List data,
    [SignOptions? options]) {
  // TODO: implement signData
  throw UnimplementedError();
}

/**
     * Verify the signed block of data
     *
     * Example usage:
     * ```ts
     * let client = new CryptographyClient(keyVaultKey, credentials);
     * let result = await client.verifyData("RS256", signedMessage, signature);
     * ```
     * 
     * 
     * 
     * 
     */
Future<VerifyResult> verifyData(
    SignatureAlgorithm algorithm, Uint8List data, Uint8List signature,
    [VerifyOptions? options]) {
  // TODO: implement verifyData
  throw UnimplementedError();
}

/**
     * Retrieves the [JsonWebKey] from the Key Vault.
     *
     * Example usage:
     * ```ts
     * let client = new CryptographyClient(keyVaultKey, credentials);
     * let result = await client.getKeyMaterial();
     * ```
     */
var getKeyMaterial;
/**
     * Returns the underlying key used for cryptographic operations.
     * If needed, fetches the key from KeyVault and exchanges the ID for the actual key.
     * 
     */
var fetchKey;
var providers;
/**
     * Gets the provider that support this algorithm and operation.
     * The available providers are ordered by priority such that the first provider that supports this
     * operation is the one we should use.
     * 
     * 
     */
var getProvider;
var ensureValid;

class EncryptParameters {}

class DecryptParameters {}

/**
 * The optional parameters accepted by the KeyVault's CryptographyClient
 */
abstract class CryptographyClientOptions implements KeyClientOptions {}

/**
 * An interface representing the options of the cryptography API methods, go to the [CryptographyClient] for more information.
 */
abstract class CryptographyOptions implements OperationOptions {}

/**
 * Options for [decrypt].
 */
abstract class DecryptOptions implements CryptographyOptions {}
/**
 * A type representing all currently supported decryption parameters as they apply to different encryption algorithms.
 */

/**
 * Result of the [decrypt] operation.
 */
abstract class DecryptResult {
  /**
     * Result of the [decrypt] operation in bytes.
     */
  Uint8List get result;
  /**
     * The ID of the Key Vault Key used to decrypt the encrypted data.
     */
  String get keyID;
  /**
     * The [EncryptionAlgorithm] used to decrypt the encrypted data.
     */
  EncryptionAlgorithm get algorithm;
}

/**
 * An interface representing a deleted Key Vault Key.
 */
abstract class DeletedKey {
  /**
     * The key value.
     */
  JsonWebKey_2 get key;
  /**
     * The name of the key.
     */
  String get name;
  /**
     * Key identifier.
     */
  String get id;
  /**
     * JsonWebKey Key Type (kty), as defined in
     * https://tools.ietf.org/html/draft-ietf-jose-json-web-algorithms-40. Possible values include:
     * 'EC', 'EC-HSM', 'RSA', 'RSA-HSM', 'oct', "oct-HSM"
     */
  KeyType_2 get keyType;
  /**
     * Operations allowed on this key
     */
  List<KeyOperation> get keyOperations;
  /**
     * The properties of the key.
     */
  dynamic properties;
}
/**
 * Defines values for DeletionRecoveryLevel. \
 * [KnownDeletionRecoveryLevel] can be used interchangeably with DeletionRecoveryLevel,
 *  this enum contains the known values that the service supports.
 * ### Known values supported by the service
 * **Purgeable**: Denotes a vault state in which deletion is an irreversible operation, without the possibility for recovery. This level corresponds to no protection being available against a Delete operation; the data is irretrievably lost upon accepting a Delete operation at the entity level or higher (vault, resource group, subscription etc.) \
 * **Recoverable+Purgeable**: Denotes a vault state in which deletion is recoverable, and which also permits immediate and permanent deletion (i.e. purge). This level guarantees the recoverability of the deleted entity during the retention interval (90 days), unless a Purge operation is requested, or the subscription is cancelled. System wil permanently delete it after 90 days, if not recovered \
 * **Recoverable**: Denotes a vault state in which deletion is recoverable without the possibility for immediate and permanent deletion (i.e. purge). This level guarantees the recoverability of the deleted entity during the retention interval(90 days) and while the subscription is still available. System wil permanently delete it after 90 days, if not recovered \
 * **Recoverable+ProtectedSubscription**: Denotes a vault and subscription state in which deletion is recoverable within retention interval (90 days), immediate and permanent deletion (i.e. purge) is not permitted, and in which the subscription itself  cannot be permanently canceled. System wil permanently delete it after 90 days, if not recovered \
 * **CustomizedRecoverable+Purgeable**: Denotes a vault state in which deletion is recoverable, and which also permits immediate and permanent deletion (i.e. purge when 7<= SoftDeleteRetentionInDays < 90). This level guarantees the recoverability of the deleted entity during the retention interval, unless a Purge operation is requested, or the subscription is cancelled. \
 * **CustomizedRecoverable**: Denotes a vault state in which deletion is recoverable without the possibility for immediate and permanent deletion (i.e. purge when 7<= SoftDeleteRetentionInDays < 90).This level guarantees the recoverability of the deleted entity during the retention interval and while the subscription is still available. \
 * **CustomizedRecoverable+ProtectedSubscription**: Denotes a vault and subscription state in which deletion is recoverable, immediate and permanent deletion (i.e. purge) is not permitted, and in which the subscription itself cannot be permanently canceled when 7<= SoftDeleteRetentionInDays < 90. This level guarantees the recoverability of the deleted entity during the retention interval, and also reflects the fact that the subscription itself cannot be cancelled.
 */

/**
 * Defines values for JsonWebKeyEncryptionAlgorithm. \
 * [KnownJsonWebKeyEncryptionAlgorithm] can be used interchangeably with JsonWebKeyEncryptionAlgorithm,
 *  this enum contains the known values that the service supports.
 * ### Known values supported by the service
 * **RSA-OAEP** \
 * **RSA-OAEP-256** \
 * **RSA1_5** \
 * **A128GCM** \
 * **A192GCM** \
 * **A256GCM** \
 * **A128KW** \
 * **A192KW** \
 * **A256KW** \
 * **A128CBC** \
 * **A192CBC** \
 * **A256CBC** \
 * **A128CBCPAD** \
 * **A192CBCPAD** \
 * **A256CBCPAD**
 */

/**
 * Options for [encrypt].
 */
abstract class EncryptOptions implements CryptographyOptions {}
/**
 * A type representing all currently supported encryption parameters as they apply to different encryption algorithms.
 */

/**
 * Result of the [encrypt] operation.
 */
abstract class EncryptResult {
  /**
     * Result of the [encrypt] operation in bytes.
     */
  Uint8List get result;
  /**
     * The [EncryptionAlgorithm] used to encrypt the data.
     */
  EncryptionAlgorithm get algorithm;
  /**
     * The ID of the Key Vault Key used to encrypt the data.
     */
  String get keyID;
  /**
     * The initialization vector used for encryption.
     */
  Uint8List get iv;
  /**
     * The authentication tag resulting from encryption with a symmetric key including A128GCM, A192GCM, and A256GCM.
     */
  Uint8List get authenticationTag;
  /**
     * Additional data that is authenticated during decryption but not encrypted.
     */
  Uint8List get additionalAuthenticatedData;
}

class EncryptionAlgorithm {}

/**
 * Options for [KeyClient.getCryptographyClient].
 */
abstract class GetCryptographyClientOptions {
  /**
     * The version of the key to use for cryptographic operations.
     *
     * When undefined, the latest version of the key will be used.
     */
  String get keyVersion;
}

/**
 * Options for [getDeletedKey].
 */
abstract class GetDeletedKeyOptions implements OperationOptions {}

/**
 * Options for [getKey].
 */
abstract class GetKeyOptions implements OperationOptions {
  /**
     * The version of the secret to retrieve. If not
     * specified the latest version of the secret will be retrieved.
     */
  String get version;
}

/**
 * Options for [KeyClient.getRotationPolicy]
 */
abstract class GetKeyRotationPolicyOptions implements OperationOptions {}

/**
 * Options for [KeyClient.getRandomBytes]
 */
abstract class GetRandomBytesOptions implements OperationOptions {}

/**
 * An interface representing the optional parameters that can be
 * passed to [importKey]
 */
abstract class ImportKeyOptions implements OperationOptions {
  /**
     * Application specific metadata in the form of key-value pairs.
     */
  Map<String, String> get tags;
  /**
     * Whether to import as a hardware key (HSM) or software key.
     */
  bool get hardwareProtected;
  /**
     * Determines whether the object is enabled.
     */
  bool get enabled;
  /**
     * Not before DateTime in UTC.
     */
  DateTime get notBefore;
  /**
     * Expiry DateTime in UTC.
     */
  DateTime get expiresOn;
  /**
     * Indicates whether the private key can be exported.
     */
  bool get exportable;
  /**
     * A [KeyReleasePolicy] object specifying the rules under which the key can be exported.
     */
  KeyReleasePolicy get releasePolicy;
}

/**
 * As of http://tools.ietf.org/html/draft-ietf-jose-json-web-key-18
 */
abstract class JsonWebKey_2 {
  /**
     * Key identifier.
     */
  String get kid;
  /**
     * JsonWebKey Key Type (kty), as defined in
     * https://tools.ietf.org/html/draft-ietf-jose-json-web-algorithms-40. Possible values include:
     * 'EC', 'EC-HSM', 'RSA', 'RSA-HSM', 'oct', "oct-HSM"
     */
  KeyType_2 get kty;
  /**
     * Json web key operations. For more
     * information on possible key operations, see KeyOperation.
     */
  List<KeyOperation> get keyOps;
  /**
     * RSA modulus.
     */
  Uint8List get n;
  /**
     * RSA public exponent.
     */
  Uint8List get e;
  /**
     * RSA private exponent, or the D component of an EC private key.
     */
  Uint8List get d;
  /**
     * RSA private key parameter.
     */
  Uint8List get dp;
  /**
     * RSA private key parameter.
     */
  Uint8List get dq;
  /**
     * RSA private key parameter.
     */
  Uint8List get qi;
  /**
     * RSA secret prime.
     */
  Uint8List get p;
  /**
     * RSA secret prime, with `p < q`.
     */
  Uint8List get q;
  /**
     * Symmetric key.
     */
  Uint8List get k;
  /**
     * HSM Token, used with 'Bring Your Own Key'.
     */
  Uint8List get t;
  /**
     * Elliptic curve name. For valid values, see KeyCurveName. Possible values include:
     * 'P-256', 'P-384', 'P-521', 'P-256K'
     */
  KeyCurveName get crv;
  /**
     * X component of an EC public key.
     */
  Uint8List get x;
  /**
     * Y component of an EC public key.
     */
  Uint8List get y;
}

class KeyCurveName {}

/**
 * The KeyClient provides methods to manage [KeyVaultKey] in the
 * Azure Key Vault. The client supports creating, retrieving, updating,
 * deleting, purging, backing up, restoring and listing KeyVaultKeys. The
 * client also supports listing [DeletedKey] for a soft-delete enabled Azure Key
 * Vault.
 */
class KeyClient {
  /**
     * The base URL to the vault
     */
  String vaultUrl;
  /**
     * A reference to the auto-generated Key Vault HTTP client.
     */
  var client;
  /**
     * A reference to the credential that was used to construct this client.
     * Later used to instantiate a [CryptographyClient] with the same credential.
     */
  TokenCredential credential;
  /**
     * Creates an instance of KeyClient.
     *
     * Example usage:
     * ```ts
     * import { KeyClient } from "@azure/keyvault-keys";
     * import { DefaultAzureCredential } from "@azure/identity";
     *
     * let vaultUrl = `https://<MY KEYVAULT HERE>.vault.azure.net`;
     * let credentials = new DefaultAzureCredential();
     *
     * let client = new KeyClient(vaultUrl, credentials);
     * ```
     * 
     * 
     * 
     */
  KeyClient(this.vaultUrl, this.credential, KeyClientOptions pipelineOptions) {}
  /**
     * The create key operation can be used to create any key type in Azure Key Vault. If the named key
     * already exists, Azure Key Vault creates a new version of the key. It requires the keys/create
     * permission.
     *
     * Example usage:
     * ```ts
     * let client = new KeyClient(url, credentials);
     * // Create an elliptic-curve key:
     * let result = await client.createKey("MyKey", "EC");
     * ```
     * Creates a new key, stores it, then returns key parameters and properties to the client.
     * 
     * 
     * 
     */
  Future<KeyVaultKey> createKey(String name, KeyType_2 keyType,
      [CreateKeyOptions? options]) {
    // TODO: implement createKey
    throw UnimplementedError();
  }

  /**
     * The createEcKey method creates a new elliptic curve key in Azure Key Vault. If the named key
     * already exists, Azure Key Vault creates a new version of the key. It requires the keys/create
     * permission.
     *
     * Example usage:
     * ```ts
     * let client = new KeyClient(url, credentials);
     * let result = await client.createEcKey("MyKey", { curve: "P-256" });
     * ```
     * Creates a new key, stores it, then returns key parameters and properties to the client.
     * 
     * 
     */
  Future<KeyVaultKey> createEcKey(String name, [CreateEcKeyOptions? options]) {
    // TODO: implement createEcKey
    throw UnimplementedError();
  }

  /**
     * The createRSAKey method creates a new RSA key in Azure Key Vault. If the named key
     * already exists, Azure Key Vault creates a new version of the key. It requires the keys/create
     * permission.
     *
     * Example usage:
     * ```ts
     * let client = new KeyClient(url, credentials);
     * let result = await client.createRsaKey("MyKey", { keySize: 2048 });
     * ```
     * Creates a new key, stores it, then returns key parameters and properties to the client.
     * 
     * 
     */
  Future<KeyVaultKey> createRsaKey(String name,
      [CreateRsaKeyOptions? options]) {
    // TODO: implement createRsaKey
    throw UnimplementedError();
  }

  /**
     * The createOctKey method creates a new OCT key in Azure Key Vault. If the named key
     * already exists, Azure Key Vault creates a new version of the key. It requires the keys/create
     * permission.
     *
     * Example usage:
     * ```ts
     * let client = new KeyClient(url, credentials);
     * let result = await client.createOctKey("MyKey", { hsm: true });
     * ```
     * Creates a new key, stores it, then returns key parameters and properties to the client.
     * 
     * 
     */
  Future<KeyVaultKey> createOctKey(String name,
      [CreateOctKeyOptions? options]) {
    // TODO: implement createOctKey
    throw UnimplementedError();
  }

  /**
     * The import key operation may be used to import any key type into an Azure Key Vault. If the
     * named key already exists, Azure Key Vault creates a new version of the key. This operation
     * requires the keys/import permission.
     *
     * Example usage:
     * ```ts
     * let client = new KeyClient(url, credentials);
     * // Key contents in myKeyContents
     * let result = await client.importKey("MyKey", myKeyContents);
     * ```
     * Imports an externally created key, stores it, and returns key parameters and properties
     * to the client.
     * 
     * 
     * 
     */
  Future<KeyVaultKey> importKey(String name, JsonWebKey_2 key,
      [ImportKeyOptions? options]) {
    // TODO: implement importKey
    throw UnimplementedError();
  }

  /**
     * Gets a [CryptographyClient] for the given key.
     *
     * Example usage:
     * ```ts
     * let client = new KeyClient(url, credentials);
     * // get a cryptography client for a given key
     * let cryptographyClient = client.getCryptographyClient("MyKey");
     * ```
     * 
     * 
     * 
     */
  _CryptographyClient getCryptographyClient(String keyName,
      [GetCryptographyClientOptions? options]) {
    // TODO: implement getCryptographyClient
    throw UnimplementedError();
  }

  /**
     * The delete operation applies to any key stored in Azure Key Vault. Individual versions
     * of a key can not be deleted, only all versions of a given key at once.
     *
     * This function returns a Long Running Operation poller that allows you to wait indefinitely until the key is deleted.
     *
     * This operation requires the keys/delete permission.
     *
     * Example usage:
     * ```ts
     * const client = new KeyClient(url, credentials);
     * await client.createKey("MyKey", "EC");
     * const poller = await client.beginDeleteKey("MyKey");
     *
     * // Serializing the poller
     * const serialized = poller.toString();
     * // A new poller can be created with:
     * // await client.beginDeleteKey("MyKey", { resumeFrom: serialized });
     *
     * // Waiting until it's done
     * const deletedKey = await poller.pollUntilDone();
     * console.log(deletedKey);
     * ```
     * Deletes a key from a specified key vault.
     * 
     * 
     */
  Future<PollerLike<PollOperationState<DeletedKey>, DeletedKey>> beginDeleteKey(
      String name,
      [BeginDeleteKeyOptions? options]) {
    // TODO: implement beginDeleteKey
    throw UnimplementedError();
  }

  /**
     * The upDateTimeKeyProperties method changes specified properties of an existing stored key. Properties that
     * are not specified in the request are left unchanged. The value of a key itself cannot be
     * changed. This operation requires the keys/set permission.
     *
     * Example usage:
     * ```ts
     * let keyName = "MyKey";
     * let client = new KeyClient(vaultUrl, credentials);
     * let key = await client.getKey(keyName);
     * let result = await client.upDateTimeKeyProperties(keyName, key.properties.version, { enabled: false });
     * ```
     * UpDateTimes the properties associated with a specified key in a given key vault.
     * 
     * 
     * 
     */
  Future<KeyVaultKey> upDateTimeKeyProperties(String name, String keyVersion,
      [UpDateTimeKeyPropertiesOptions? options]) {
    // TODO: implement upDateTimeKeyProperties
    throw UnimplementedError();
  }

  /**
     * The upDateTimeKeyProperties method changes specified properties of the latest version of an existing stored key. Properties that
     * are not specified in the request are left unchanged. The value of a key itself cannot be
     * changed. This operation requires the keys/set permission.
     *
     * Example usage:
     * ```ts
     * let keyName = "MyKey";
     * let client = new KeyClient(vaultUrl, credentials);
     * let key = await client.getKey(keyName);
     * let result = await client.upDateTimeKeyProperties(keyName, { enabled: false });
     * ```
     * UpDateTimes the properties associated with a specified key in a given key vault.
     * 
     * 
     * 
     */
  Future<KeyVaultKey> upDateKeyProperties(String name,
      [UpDateTimeKeyPropertiesOptions? options]) {
    // TODO: implement upDateTimeKeyProperties
    throw UnimplementedError();
  }

  /**
     * Standardizes an overloaded arguments collection for the upDateTimeKeyProperties method.
     *
     * 
     * 
     */
  var disambiguateUpDateTimeKeyPropertiesArgs;
  /**
     * The getKey method gets a specified key and is applicable to any key stored in Azure Key Vault.
     * This operation requires the keys/get permission.
     *
     * Example usage:
     * ```ts
     * let client = new KeyClient(url, credentials);
     * let key = await client.getKey("MyKey");
     * ```
     * Get a specified key from a given key vault.
     * 
     * 
     */
  Future<KeyVaultKey> getKey(String name, [GetKeyOptions? options]) {
    // TODO: implement getKey
    throw UnimplementedError();
  }

  /**
     * The getDeletedKey method returns the specified deleted key along with its properties.
     * This operation requires the keys/get permission.
     *
     * Example usage:
     * ```ts
     * let client = new KeyClient(url, credentials);
     * let key = await client.getDeletedKey("MyDeletedKey");
     * ```
     * Gets the specified deleted key.
     * 
     * 
     */
  Future<DeletedKey> getDeletedKey(String name,
      [GetDeletedKeyOptions? options]) {
    // TODO: implement getDeletedKey
    throw UnimplementedError();
  }

  /**
     * The purge deleted key operation removes the key permanently, without the possibility of
     * recovery. This operation can only be enabled on a soft-delete enabled vault. This operation
     * requires the keys/purge permission.
     *
     * Example usage:
     * ```ts
     * const client = new KeyClient(url, credentials);
     * const deletePoller = await client.beginDeleteKey("MyKey")
     * await deletePoller.pollUntilDone();
     * await client.purgeDeletedKey("MyKey");
     * ```
     * Permanently deletes the specified key.
     * 
     * 
     */
  Future purgeDeletedKey(String name, [PurgeDeletedKeyOptions? options]) {
    // TODO: implement purgeDeletedKey
    throw UnimplementedError();
  }

  /**
     * Recovers the deleted key in the specified vault. This operation can only be performed on a
     * soft-delete enabled vault.
     *
     * This function returns a Long Running Operation poller that allows you to wait indefinitely until the deleted key is recovered.
     *
     * This operation requires the keys/recover permission.
     *
     * Example usage:
     * ```ts
     * const client = new KeyClient(url, credentials);
     * await client.createKey("MyKey", "EC");
     * const deletePoller = await client.beginDeleteKey("MyKey");
     * await deletePoller.pollUntilDone();
     * const poller = await client.beginRecoverDeletedKey("MyKey");
     *
     * // Serializing the poller
     * const serialized = poller.toString();
     * // A new poller can be created with:
     * // await client.beginRecoverDeletedKey("MyKey", { resumeFrom: serialized });
     *
     * // Waiting until it's done
     * const key = await poller.pollUntilDone();
     * console.log(key);
     * ```
     * Recovers the deleted key to the latest version.
     * 
     * 
     */
  Future<PollerLike<PollOperationState<DeletedKey>, DeletedKey>>
      beginRecoverDeletedKey(String name,
          [BeginRecoverDeletedKeyOptions? options]) {
    // TODO: implement beginRecoverDeletedKey
    throw UnimplementedError();
  }

  /**
     * Requests that a backup of the specified key be downloaded to the client. All versions of the
     * key will be downloaded. This operation requires the keys/backup permission.
     *
     * Example usage:
     * ```ts
     * let client = new KeyClient(url, credentials);
     * let backupContents = await client.backupKey("MyKey");
     * ```
     * Backs up the specified key.
     * 
     * 
     */
  Future<Uint8List> backupKey(String name, [BackupKeyOptions? options]) {
    // TODO: implement backupKey
    throw UnimplementedError();
  }

  /**
     * Restores a backed up key, and all its versions, to a vault. This operation requires the
     * keys/restore permission.
     *
     * Example usage:
     * ```ts
     * let client = new KeyClient(url, credentials);
     * let backupContents = await client.backupKey("MyKey");
     * // ...
     * let key = await client.restoreKeyBackup(backupContents);
     * ```
     * Restores a backed up key to a vault.
     * 
     * 
     */
  Future<KeyVaultKey> restoreKeyBackup(Uint8List backup,
      [RestoreKeyBackupOptions? options]) {
    // TODO: implement restoreKeyBackup
    throw UnimplementedError();
  }

  /**
     * Gets the requested number of bytes containing random values from a managed HSM.
     * This operation requires the managedHsm/rng permission.
     *
     * Example usage:
     * ```ts
     * let client = new KeyClient(vaultUrl, credentials);
     * let { bytes } = await client.getRandomBytes(10);
     * ```
     * 
     * 
     */
  Future<Uint8List> getRandomBytes(num count,
      [GetRandomBytesOptions? options]) {
    // TODO: implement getRandomBytes
    throw UnimplementedError();
  }

  /**
     * Rotates the key based on the key policy by generating a new version of the key. This operation requires the keys/rotate permission.
     *
     * Example usage:
     * ```ts
     * let client = new KeyClient(vaultUrl, credentials);
     * let key = await client.rotateKey("MyKey");
     * ```
     *
     * 
     * 
     */
  Future<KeyVaultKey> rotateKey(String name, [RotateKeyOptions? options]) {
    // TODO: implement rotateKey
    throw UnimplementedError();
  }

  /**
     * Releases a key from a managed HSM.
     *
     * The release key operation is applicable to all key types. The operation requires the key to be marked exportable and the keys/release permission.
     *
     * Example usage:
     * ```ts
     * let client = new KeyClient(vaultUrl, credentials);
     * let result = await client.releaseKey("myKey", target)
     * ```
     *
     * 
     * 
     * 
     */
  Future<ReleaseKeyResult> releaseKey(
      String name, String targetAttestationToken,
      [ReleaseKeyOptions? options]) {
    // TODO: implement releaseKey
    throw UnimplementedError();
  }

  /**
     * Gets the rotation policy of a Key Vault Key.
     * By default, all keys have a policy that will notify 30 days before expiry.
     *
     * This operation requires the keys/get permission.
     * Example usage:
     * ```ts
     * let client = new KeyClient(vaultUrl, credentials);
     * let result = await client.getKeyRotationPolicy("myKey");
     * ```
     *
     * 
     * 
     */
  Future<KeyRotationPolicy> getKeyRotationPolicy(String keyName,
      [GetKeyRotationPolicyOptions? options]) {
    // TODO: implement getKeyRotationPolicy
    throw UnimplementedError();
  }

  /**
     * UpDateTimes the rotation policy of a Key Vault Key.
     * This operation requires the keys/upDateTime permission.
     *
     * Example usage:
     * ```ts
     * let client = new KeyClient(vaultUrl, credentials);
     * const setPolicy = await client.upDateTimeKeyRotationPolicy("MyKey", myPolicy);
     * ```
     *
     * 
     * 
     * 
     */
  Future<KeyRotationPolicy> upDateTimeKeyRotationPolicy(
      String keyName, KeyRotationPolicyProperties policy,
      [UpDateTimeKeyRotationPolicyOptions? options]) {
    // TODO: implement upDateTimeKeyRotationPolicy
    throw UnimplementedError();
  }

  /**
     * Deals with the pagination of [listPropertiesOfKeyVersions].
     * 
     * 
     * 
     */
  var listPropertiesOfKeyVersionsPage;
  /**
     * Deals with the iteration of all the available results of [listPropertiesOfKeyVersions].
     * 
     * 
     */
  var listPropertiesOfKeyVersionsAll;
  /**
     * Iterates all versions of the given key in the vault. The full key identifier, properties, and tags are provided
     * in the response. This operation requires the keys/list permission.
     *
     * Example usage:
     * ```ts
     * let client = new KeyClient(url, credentials);
     * for await (const keyProperties of client.listPropertiesOfKeyVersions("MyKey")) {
     *   const key = await client.getKey(keyProperties.name);
     *   console.log("key version: ", key);
     * }
     * ```
     * 
     * 
     */
  PagedAsyncIterableIterator<KeyProperties> listPropertiesOfKeyVersions(
      String name,
      [ListPropertiesOfKeyVersionsOptions? options]) {
    // TODO: implement listPropertiesOfKeyVersions
    throw UnimplementedError();
  }

  /**
     * Deals with the pagination of [listPropertiesOfKeys].
     * 
     * 
     */
  var listPropertiesOfKeysPage;
  /**
     * Deals with the iteration of all the available results of [listPropertiesOfKeys].
     * 
     */
  var listPropertiesOfKeysAll;

  PagedAsyncIterableIterator<KeyProperties> listPropertiesOfKeys(
      [ListPropertiesOfKeysOptions? options]) {
    // TODO: implement listPropertiesOfKeys
    throw UnimplementedError();
  }

  var listDeletedKeysPage;

  var listDeletedKeysAll;
  PagedAsyncIterableIterator<DeletedKey> listDeletedKeys(
      [ListDeletedKeysOptions? options]) {
    // TODO: implement listDeletedKeys
    throw UnimplementedError();
  }
}

class PollOperationState<T> {}

class PagedAsyncIterableIterator<T> {}

class PollerLike<T, E> {}

/**
 * The optional parameters accepted by the KeyVault's KeyClient
 */
abstract class KeyClientOptions implements PipelineOptions {
  /**
     * The version of the KeyVault's service API to make calls against.
     */
  String get serviceVersion;
}

class PipelineOptions {}
/**
 * Defines values for JsonWebKeyCurveName. \
 * [KnownJsonWebKeyCurveName] can be used interchangeably with JsonWebKeyCurveName,
 *  this enum contains the known values that the service supports.
 * ### Known values supported by the service
 * **P-256**: The NIST P-256 elliptic curve, AKA SECG curve SECP256R1. \
 * **P-384**: The NIST P-384 elliptic curve, AKA SECG curve SECP384R1. \
 * **P-521**: The NIST P-521 elliptic curve, AKA SECG curve SECP521R1. \
 * **P-256K**: The SECG SECP256K1 elliptic curve.
 */

/**
 * Defines values for KeyEncryptionAlgorithm.
 * [KnownKeyExportEncryptionAlgorithm] can be used interchangeably with KeyEncryptionAlgorithm,
 *  this enum contains the known values that the service supports.
 * ### Known values supported by the service
 * **CKM_RSA_AES_KEY_WRAP** \
 * **RSA_AES_KEY_WRAP_256** \
 * **RSA_AES_KEY_WRAP_384**
 */

/**
 * Defines values for JsonWebKeyOperation. \
 * [KnownJsonWebKeyOperation] can be used interchangeably with JsonWebKeyOperation,
 *  this enum contains the known values that the service supports.
 * ### Known values supported by the service
 * **encrypt** \
 * **decrypt** \
 * **sign** \
 * **verify** \
 * **wrapKey** \
 * **unwrapKey** \
 * **import** \
 * **export**
 */

/**
 * An interface representing the optional parameters that can be
 * passed to [beginDeleteKey] and [beginRecoverDeletedKey]
 */
abstract class KeyPollerOptions implements OperationOptions {
  /**
     * Time between each polling
     */
  num get intervalInMs;
  /**
     * A serialized poller, used to resume an existing operation
     */
  String get resumeFrom;
}

/**
 * An interface representing the Properties of [KeyVaultKey]
 */
abstract class KeyProperties {
  /**
     * Key identifier.
     */
  String get id;
  /**
     * The name of the key.
     */
  String get name;
  /**
     * The vault URI.
     */
  String get vaultUrl;
  /**
     * The version of the key. May be undefined.
     */
  String get version;
  /**
     * Determines whether the object is enabled.
     */
  bool get enabled;
  /**
     * Not before DateTime in UTC.
     */
  DateTime get notBefore;
  /**
     * Expiry DateTime in UTC.
     */
  DateTime get expiresOn;
  /**
     * Application specific metadata in the form of key-value pairs.
     */
  Map<String, String> get tags;
  /**
     * Creation time in UTC.
     * **NOTE: This property will not be serialized. It can only be populated by
     * the server.**
     */
  DateTime get createdOn;
  /**
     * Last upDateTimed time in UTC.
     * **NOTE: This property will not be serialized. It can only be populated by
     * the server.**
     */
  DateTime get upDateTimedOn;
  /**
     * Reflects the deletion recovery level currently in effect for keys in the current vault.
     * If it contains 'Purgeable' the key can be permanently deleted by a privileged
     * user; otherwise, only the system can purge the key, at the end of the
     * retention interval. Possible values include: 'Purgeable',
     * 'Recoverable+Purgeable', 'Recoverable',
     * 'Recoverable+ProtectedSubscription'
     * **NOTE: This property will not be serialized. It can only be populated by
     * the server.**
     */
  DeletionRecoveryLevel get recoveryLevel;
  /**
     * The retention DateTimes of the softDelete data.
     * The value should be `>=7` and `<=90` when softDelete enabled.
     * **NOTE: This property will not be serialized. It can only be populated by the server.**
     */
  num get recoverableDays;
  /**
     * True if the secret's lifetime is managed by
     * key vault. If this is a secret backing a certificate, then managed will be
     * true.
     * **NOTE: This property will not be serialized. It can only be populated by
     * the server.**
     */
  bool get managed;
  /**
     * Indicates whether the private key can be exported.
     */
  bool get exportable;
  /**
     * A [KeyReleasePolicy] object specifying the rules under which the key can be exported.
     */
  KeyReleasePolicy get releasePolicy;
}

class DeletionRecoveryLevel {}

/**
 * The policy rules under which a key can be exported.
 */
abstract class KeyReleasePolicy {
  /**
     * Content type and version of key release policy.
     *
     * Defaults to "application/json; charset=utf-8" if omitted.
     */
  String get contentType;
  /**
     * The policy rules under which the key can be released. Encoded based on the [KeyReleasePolicy.contentType].
     *
     * For more information regarding the release policy grammar for Azure Key Vault, please refer to:
     * - https://aka.ms/policygrammarkeys for Azure Key Vault release policy grammar.
     * - https://aka.ms/policygrammarmhsm for Azure Managed HSM release policy grammar.
     */
  Uint8List get encodedPolicy;
  /** Marks a release policy as immutable. An immutable release policy cannot be changed or upDateTimed after being marked immutable. */
  bool get immutable;
}

/**
 * An action and its corresponding trigger that will be performed by Key Vault over the lifetime of a key.
 */
abstract class KeyRotationLifetimeAction {
  /**
     * Time after creation to attempt the specified action, defined as an ISO 8601 duration.
     */
  String get timeAfterCreate;
  /**
     * Time before expiry to attempt the specified action, defined as an ISO 8601 duration.
     */
  String get timeBeforeExpiry;
  /**
     * The action that will be executed.
     */
  KeyRotationPolicyAction get action;
}

class KeyRotationPolicyAction {}

/**
 * The complete key rotation policy that belongs to a key.
 */
abstract class KeyRotationPolicy implements KeyRotationPolicyProperties {
  /**
     * The identifier of the Key Rotation Policy.
     * May be undefined if a policy has not been explicitly set.
     */
  String get id;
  /**
     * The created time in UTC.
     * May be undefined if a policy has not been explicitly set.
     */
  DateTime get createdOn;
  /**
     * The last upDateTimed time in UTC.
     * May be undefined if a policy has not been explicitly set.
     */
  DateTime get upDateTimedOn;
}
/**
 * The action that will be executed.
 */

/**
 * The properties of a key rotation policy that the client can set for a given key.
 *
 * You may also reset the key rotation policy to its default values by setting lifetimeActions to an empty array.
 */
abstract class KeyRotationPolicyProperties {
  /**
     * Optional key expiration period used to define the duration after which a newly rotated key will expire, defined as an ISO 8601 duration.
     */
  String get expiresIn;
  /**
     * Actions that will be performed by Key Vault over the lifetime of a key.
     *
     * You may also pass an empty array to restore to its default values.
     */
  List<KeyRotationLifetimeAction> get lifetimeActions;
}
/**
 * Defines values for JsonWebKeyType. \
 * [KnownJsonWebKeyType] can be used interchangeably with JsonWebKeyType,
 *  this enum contains the known values that the service supports.
 * ### Known values supported by the service
 * **EC**: Elliptic Curve. \
 * **EC-HSM**: Elliptic Curve with a private key which is stored in the HSM. \
 * **RSA**: RSA (https:\/\/tools.ietf.org\/html\/rfc3447) \
 * **RSA-HSM**: RSA with a private key which is stored in the HSM. \
 * **oct**: Octet sequence (used to represent symmetric keys) \
 * **oct-HSM**: Octet sequence (used to represent symmetric keys) which is stored the HSM.
 */

/**
 * An interface representing a Key Vault Key, with its name, value and [KeyProperties].
 */
abstract class _KeyVaultKey {
  _KeyVaultKey();
  /**
     * The key value.
     */
  JsonWebKey_2? get key;
  /**
     * The name of the key.
     */
  String? get name;
  /**
     * Key identifier.
     */
  String? get id;
  /**
     * JsonWebKey Key Type (kty), as defined in
     * https://tools.ietf.org/html/draft-ietf-jose-json-web-algorithms-40. Possible values include:
     * 'EC', 'EC-HSM', 'RSA', 'RSA-HSM', 'oct', "oct-HSM"
     */
  KeyType_2? get keyType;
  /**
     * Operations allowed on this key
     */
  List<KeyOperation>? get keyOperations;
  /**
     * The properties of the key.
     */
  KeyProperties? get properties;
}

class KeyVaultKey extends _KeyVaultKey {
  KeyVaultKey(
    this.id,
    this.key,
    this.keyOperations,
    this.keyType,
    this.name,
    this.properties,
  ) : super();
  @override
  // TODO: implement id
  final String? id;

  @override
  // TODO: implement key
  final JsonWebKey_2? key;

  @override
  // TODO: implement keyOperations
  final List<KeyOperation>? keyOperations;

  @override
  // TODO: implement keyType
  final KeyType_2? keyType;

  @override
  // TODO: implement name
  final String? name;

  @override
  // TODO: implement properties
  final KeyProperties? properties;
}

class KeyType_2 {}

/**
 * Represents the segments that compose a Key Vault Key Id.
 */
abstract class KeyVaultKeyIdentifier {
  /**
     * The complete representation of the Key Vault Key Id. For example:
     *
     *   https://<keyvault-name>.vault.azure.net/keys/<key-name>/<unique-version-id>
     *
     */
  String get sourceId;
  /**
     * The URL of the Azure Key Vault instance to which the Key belongs.
     */
  String get vaultUrl;
  /**
     * The version of Key Vault Key. Might be undefined.
     */
  String get version;
  /**
     * The name of the Key Vault Key.
     */
  String get name;
}
/**
 * Supported algorithms for key wrapping/unwrapping
 */

/** Known values of [DeletionRecoveryLevel] that the service accepts. */
enum KnownDeletionRecoveryLevel {
  /** Denotes a vault state in which deletion is an irreversible operation, without the possibility for recovery. This level corresponds to no protection being available against a Delete operation; the data is irretrievably lost upon accepting a Delete operation at the entity level or higher (vault, resource group, subscription etc.) */
  Purgeable,
  /** Denotes a vault state in which deletion is recoverable, and which also permits immediate and permanent deletion (i.e. purge). This level guarantees the recoverability of the deleted entity during the retention interval (90 days), unless a Purge operation is requested, or the subscription is cancelled. System wil permanently delete it after 90 days, if not recovered */
  RecoverablePurgeable,
  /** Denotes a vault state in which deletion is recoverable without the possibility for immediate and permanent deletion (i.e. purge). This level guarantees the recoverability of the deleted entity during the retention interval(90 days) and while the subscription is still available. System wil permanently delete it after 90 days, if not recovered */
  Recoverable,
  /** Denotes a vault and subscription state in which deletion is recoverable within retention interval (90 days), immediate and permanent deletion (i.e. purge) is not permitted, and in which the subscription itself  cannot be permanently canceled. System wil permanently delete it after 90 days, if not recovered */
  RecoverableProtectedSubscription,
  /** Denotes a vault state in which deletion is recoverable, and which also permits immediate and permanent deletion (i.e. purge when 7<= SoftDeleteRetentionInDays < 90). This level guarantees the recoverability of the deleted entity during the retention interval, unless a Purge operation is requested, or the subscription is cancelled. */
  CustomizedRecoverablePurgeable,
  /** Denotes a vault state in which deletion is recoverable without the possibility for immediate and permanent deletion (i.e. purge when 7<= SoftDeleteRetentionInDays < 90).This level guarantees the recoverability of the deleted entity during the retention interval and while the subscription is still available. */
  CustomizedRecoverable,
  /** Denotes a vault and subscription state in which deletion is recoverable, immediate and permanent deletion (i.e. purge) is not permitted, and in which the subscription itself cannot be permanently canceled when 7<= SoftDeleteRetentionInDays < 90. This level guarantees the recoverability of the deleted entity during the retention interval, and also reflects the fact that the subscription itself cannot be cancelled. */
  CustomizedRecoverableProtectedSubscription
}

/** Known values of [EncryptionAlgorithm] that the service accepts. */
enum KnownEncryptionAlgorithms {
  /** Encryption Algorithm - RSA-OAEP */
  RSAOaep,
  /** Encryption Algorithm - RSA-OAEP-256 */
  RSAOaep256,
  /** Encryption Algorithm - RSA1_5 */
  RSA15,
  /** Encryption Algorithm - A128GCM */
  A128GCM,
  /** Encryption Algorithm - A192GCM */
  A192GCM,
  /** Encryption Algorithm - A256GCM */
  A256GCM,
  /** Encryption Algorithm - A128KW */
  A128KW,
  /** Encryption Algorithm - A192KW */
  A192KW,
  /** Encryption Algorithm - A256KW */
  A256KW,
  /** Encryption Algorithm - A128CBC */
  A128CBC,
  /** Encryption Algorithm - A192CBC */
  A192CBC,
  /** Encryption Algorithm - A256CBC */
  A256CBC,
  /** Encryption Algorithm - A128CBCPAD */
  A128Cbcpad,
  /** Encryption Algorithm - A192CBCPAD */
  A192Cbcpad,
  /** Encryption Algorithm - A256CBCPAD */
  A256Cbcpad
}

/** Known values of [JsonWebKeyCurveName] that the service accepts. */
enum KnownKeyCurveNames {
  /** The NIST P-256 elliptic curve, AKA SECG curve SECP256R1. */
  P256,
  /** The NIST P-384 elliptic curve, AKA SECG curve SECP384R1. */
  P384,
  /** The NIST P-521 elliptic curve, AKA SECG curve SECP521R1. */
  P521,
  /** The SECG SECP256K1 elliptic curve. */
  P256K
}

/** Known values of [KeyExportEncryptionAlgorithm] that the service accepts. */
enum KnownKeyExportEncryptionAlgorithm {
  /** CKM_RSA_AES_KEY_WRAP Key Export Encryption Algorithm */
  CkmRsaAesKeyWrap,
  /** RSA_AES_KEY_WRAP_256 Key Export Encryption Algorithm */
  RsaAesKeyWrap256,
  /** RSA_AES_KEY_WRAP_384 Key Export Encryption Algorithm */
  RsaAesKeyWrap384
}

/** Known values of [KeyOperation] that the service accepts. */
enum KnownKeyOperations {
  /** Key operation - encrypt */
  Encrypt,
  /** Key operation - decrypt */
  Decrypt,
  /** Key operation - sign */
  Sign,
  /** Key operation - verify */
  Verify,
  /** Key operation - wrapKey */
  WrapKey,
  /** Key operation - unwrapKey */
  UnwrapKey,
  /** Key operation - import */
  Import
}

/** Known values of [JsonWebKeyType] that the service accepts. */
enum KnownKeyTypes {
  /** Elliptic Curve. */
  EC,
  /** Elliptic Curve with a private key which is stored in the HSM. */
  ECHSM,
  /** RSA (https://tools.ietf.org/html/rfc3447) */
  RSA,
  /** RSA with a private key which is stored in the HSM. */
  RSAHSM,
  /** Octet sequence (used to represent symmetric keys) */
  Oct,
  /** Octet sequence (used to represent symmetric keys) which is stored the HSM. */
  OctHSM
}

/** Known values of [JsonWebKeySignatureAlgorithm] that the service accepts. */
enum KnownSignatureAlgorithms {
  /** RSASSA-PSS using SHA-256 and MGF1 with SHA-256, as described in https://tools.ietf.org/html/rfc7518 */
  PS256,
  /** RSASSA-PSS using SHA-384 and MGF1 with SHA-384, as described in https://tools.ietf.org/html/rfc7518 */
  PS384,
  /** RSASSA-PSS using SHA-512 and MGF1 with SHA-512, as described in https://tools.ietf.org/html/rfc7518 */
  PS512,
  /** RSASSA-PKCS1-v1_5 using SHA-256, as described in https://tools.ietf.org/html/rfc7518 */
  RS256,
  /** RSASSA-PKCS1-v1_5 using SHA-384, as described in https://tools.ietf.org/html/rfc7518 */
  RS384,
  /** RSASSA-PKCS1-v1_5 using SHA-512, as described in https://tools.ietf.org/html/rfc7518 */
  RS512,
  /** Reserved */
  Rsnull,
  /** ECDSA using P-256 and SHA-256, as described in https://tools.ietf.org/html/rfc7518. */
  ES256,
  /** ECDSA using P-384 and SHA-384, as described in https://tools.ietf.org/html/rfc7518 */
  ES384,
  /** ECDSA using P-521 and SHA-512, as described in https://tools.ietf.org/html/rfc7518 */
  ES512,
  /** ECDSA using P-256K and SHA-256, as described in https://tools.ietf.org/html/rfc7518 */
  ES256K
}

/**
 * An interface representing optional parameters for KeyClient paged operations passed to [listDeletedKeys].
 */
abstract class ListDeletedKeysOptions implements OperationOptions {}

/**
 * An interface representing optional parameters for KeyClient paged operations passed to [listPropertiesOfKeys].
 */
abstract class ListPropertiesOfKeysOptions implements OperationOptions {}

/**
 * An interface representing optional parameters for KeyClient paged operations passed to [listPropertiesOfKeyVersions].
 */
abstract class ListPropertiesOfKeyVersionsOptions implements OperationOptions {}

/**
 * The \@azure/logger configuration for this package.
 */
/**
 * Parses the given Key Vault Key Id. An example is:
 *
 *   https://<keyvault-name>.vault.azure.net/keys/<key-name>/<unique-version-id>
 *
 * On parsing the above Id, this function returns:
 *```ts
 *   {
 *      sourceId: "https://<keyvault-name>.vault.azure.net/keys/<key-name>/<unique-version-id>",
 *      vaultUrl: "https://<keyvault-name>.vault.azure.net",
 *      version: "<unique-version-id>",
 *      name: "<key-name>"
 *   }
 *```
 * 
 */
KeyVaultKeyIdentifier? parseKeyVaultKeyIdentifier(String id) {}

/**
 * Options for [purgeDeletedKey].
 */
abstract class PurgeDeletedKeyOptions implements OperationOptions {}

/**
 * Options for [KeyClient.releaseKey]
 */
abstract class ReleaseKeyOptions implements OperationOptions {
  /** A client provided nonce for freshness. */
  String get nonce;
  /** The [KeyExportEncryptionAlgorithm] to for protecting the exported key material. */
  KeyExportEncryptionAlgorithm get algorithm;
  /**
     * The version of the key to release. Defaults to the latest version of the key if omitted.
     */
  String get version;
}

class KeyExportEncryptionAlgorithm {}

/**
 * Result of the [KeyClient.releaseKey] operation.
 */
abstract class ReleaseKeyResult {
  /** A signed token containing the released key. */
  String get value;
}

/**
 * Options for [restoreKeyBackup].
 */
abstract class RestoreKeyBackupOptions implements OperationOptions {}

/**
 * Options for [KeyClient.rotateKey]
 */
abstract class RotateKeyOptions implements OperationOptions {}

/**
 * Decryption parameters for RSA encryption algorithms.
 */
abstract class RsaDecryptParameters {
  /**
     * The encryption algorithm to use.
     */
  RsaEncryptionAlgorithm get algorithm;
  /**
     * The ciphertext to decrypt.
     */
  Uint8List get ciphertext;
}
/**
 * A union type representing all supported RSA encryption algorithms.
 */

/**
 * Encryption parameters for RSA encryption algorithms.
 */
abstract class RsaEncryptParameters {
  /**
     * The encryption algorithm to use.
     */
  RsaEncryptionAlgorithm get algorithm;
  /**
     * The plain text to encrypt.
     */
  Uint8List get plaintext;
}

class RsaEncryptionAlgorithm {}
/**
 * Defines values for JsonWebKeySignatureAlgorithm. \
 * [KnownJsonWebKeySignatureAlgorithm] can be used interchangeably with JsonWebKeySignatureAlgorithm,
 *  this enum contains the known values that the service supports.
 * ### Known values supported by the service
 * **PS256**: RSASSA-PSS using SHA-256 and MGF1 with SHA-256, as described in https:\/\/tools.ietf.org\/html\/rfc7518 \
 * **PS384**: RSASSA-PSS using SHA-384 and MGF1 with SHA-384, as described in https:\/\/tools.ietf.org\/html\/rfc7518 \
 * **PS512**: RSASSA-PSS using SHA-512 and MGF1 with SHA-512, as described in https:\/\/tools.ietf.org\/html\/rfc7518 \
 * **RS256**: RSASSA-PKCS1-v1_5 using SHA-256, as described in https:\/\/tools.ietf.org\/html\/rfc7518 \
 * **RS384**: RSASSA-PKCS1-v1_5 using SHA-384, as described in https:\/\/tools.ietf.org\/html\/rfc7518 \
 * **RS512**: RSASSA-PKCS1-v1_5 using SHA-512, as described in https:\/\/tools.ietf.org\/html\/rfc7518 \
 * **RSNULL**: Reserved \
 * **ES256**: ECDSA using P-256 and SHA-256, as described in https:\/\/tools.ietf.org\/html\/rfc7518. \
 * **ES384**: ECDSA using P-384 and SHA-384, as described in https:\/\/tools.ietf.org\/html\/rfc7518 \
 * **ES512**: ECDSA using P-521 and SHA-512, as described in https:\/\/tools.ietf.org\/html\/rfc7518 \
 * **ES256K**: ECDSA using P-256K and SHA-256, as described in https:\/\/tools.ietf.org\/html\/rfc7518
 */

/**
 * Options for [sign].
 */
abstract class SignOptions implements CryptographyOptions {}

/**
 * Result of the [sign] operation.
 */
abstract class SignResult {
  /**
     * Result of the [sign] operation in bytes.
     */
  Uint8List get result;
  /**
     * The ID of the Key Vault Key used to sign the data.
     */
  String get keyID;
  /**
     * The [EncryptionAlgorithm] used to sign the data.
     */
  SignatureAlgorithm get algorithm;
}

class SignatureAlgorithm {}

/**
 * Options for [unwrapKey].
 */
abstract class UnwrapKeyOptions implements CryptographyOptions {}

/**
 * Result of the [unwrap] operation.
 */
abstract class UnwrapResult {
  /**
     * Result of the [unwrap] operation in bytes.
     */
  Uint8List get result;
  /**
     * The ID of the Key Vault Key used to unwrap the data.
     */
  String get keyID;
  /**
     * The [KeyWrapAlgorithm] used to unwrap the data.
     */
  KeyWrapAlgorithm get algorithm;
}

/**
 * Options for [upDateTimeKeyProperties].
 */
abstract class UpDateTimeKeyPropertiesOptions implements OperationOptions {
  /**
     * Json web key operations. For more
     * information on possible key operations, see KeyOperation.
     */
  List<KeyOperation> get keyOps;
  /**
     * Determines whether the object is enabled.
     */
  bool get enabled;
  /**
     * Not before DateTime in UTC.
     */
  DateTime get notBefore;
  /**
     * Expiry DateTime in UTC.
     */
  DateTime get expiresOn;
  /**
     * Application specific metadata in the form of key-value pairs.
     */
  Map<String, String> get tags;
  /**
     * A [KeyReleasePolicy] object specifying the rules under which the key can be exported.
     * Only valid if the key is marked exportable, which cannot be changed after key creation.
     */
  KeyReleasePolicy get releasePolicy;
}

class KeyOperation {}

/**
 * Options for [KeyClient.upDateTimeKeyRotationPolicy]
 */
abstract class UpDateTimeKeyRotationPolicyOptions implements OperationOptions {}

/**
 * Options for [verifyData]
 */
abstract class VerifyDataOptions implements CryptographyOptions {}

/**
 * Options for [verify].
 */
abstract class VerifyOptions implements CryptographyOptions {}

/**
 * Result of the [verify] operation.
 */
abstract class VerifyResult {
  /**
     * Result of the [verify] operation in bytes.
     */
  bool get result;
  /**
     * The ID of the Key Vault Key used to verify the data.
     */
  String get keyID;
}

/**
 * Options for [wrapKey].
 */
abstract class WrapKeyOptions implements CryptographyOptions {}

/**
 * Result of the [wrap] operation.
 */
abstract class WrapResult {
  /**
     * Result of the [wrap] operation in bytes.
     */
  Uint8List get result;
  /**
     * The ID of the Key Vault Key used to wrap the data.
     */
  String get keyID;
  /**
     * The [EncryptionAlgorithm] used to wrap the data.
     */
  KeyWrapAlgorithm get algorithm;
}

class KeyWrapAlgorithm {}


//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IiIsImZpbGUiOiJrZXl2YXVsdC1rZXlzLnRzLmRhcnQiLCJzb3VyY2VzQ29udGVudCI6W119
