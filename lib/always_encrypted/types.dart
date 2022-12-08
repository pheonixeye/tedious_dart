// ignore_for_file: constant_identifier_names, unnecessary_this

import 'package:tedious_dart/always_encrypted/cek_entry.dart';

import '../models/buffer.dart';

enum SQLServerEncryptionType {
  Deterministic(1),
  Randomized(2),
  PlainText(0);

  final int value;

  const SQLServerEncryptionType(this.value);
}

class EncryptionKeyInfo {
  Buffer? encryptedKey;
  late num dbId;
  late num keyId;
  late num keyVersion;
  Buffer? mdVersion;
  late String keyPath;
  late String keyStoreName;
  late String algorithmName;

  EncryptionKeyInfo({
    this.encryptedKey,
    this.dbId = 0,
    this.keyId = 0,
    this.keyVersion = 0,
    this.mdVersion,
    this.keyPath = '',
    this.keyStoreName = '',
    this.algorithmName = '',
  });
}

abstract class EncryptionAlgorithm {
  Buffer? encryptData(Buffer plainText);
  Buffer? decryptData(Buffer cipherText);
}

class CryptoMetadata {
  CEKEntry? cekEntry;
  num cipherAlgorithmId;
  String? cipherAlgorithmName;
  Buffer? normalizationRuleVersion;
  EncryptionKeyInfo? encryptionKeyInfo;
  num ordinal;
  SQLServerEncryptionType encryptionType;
  EncryptionAlgorithm? cipherAlgorithm;
  //! metadata-parser.ts
  BaseMetadata? baseTypeInfo;

  CryptoMetadata({
    this.cekEntry,
    this.cipherAlgorithmId = 0,
    this.cipherAlgorithmName,
    this.normalizationRuleVersion,
    this.encryptionKeyInfo,
    this.ordinal = 0,
    this.encryptionType = SQLServerEncryptionType.Randomized,
    this.cipherAlgorithm,
    this.baseTypeInfo,
  });
}

typedef HashMap<T> = Map<String, T>;

// Fields in the first resultset of "sp_describe_parameter_encryption"
// We expect the server to return the fields in the resultset in the same order as mentioned below.
// If the server changes the below order, then transparent parameter encryption will break.
enum DescribeParameterEncryptionResultSet1 {
  KeyOrdinal,
  DbId,
  KeyId,
  KeyVersion,
  KeyMdVersion,
  EncryptedKey,
  ProviderName,
  KeyPath,
  KeyEncryptionAlgorithm
}

// Fields in the second resultset of "sp_describe_parameter_encryption"
// We expect the server to return the fields in the resultset in the same order as mentioned below.
// If the server changes the below order, then transparent parameter encryption will break.
enum DescribeParameterEncryptionResultSet2 {
  ParameterOrdinal,
  ParameterName,
  ColumnEncryptionAlgorithm,
  ColumnEncrytionType,
  ColumnEncryptionKeyOrdinal,
  NormalizationRuleVersion
}

enum SQLServerStatementColumnEncryptionSetting {
  // if "Column Encryption Setting=Enabled" in the connection string, use Enabled. Otherwise, maps to Disabled.
  UseConnectionSetting,
  // Enables TCE for the command. Overrides the connection level setting for this command.
  Enabled,
  //Parameters will not be encrypted, only the ResultSet will be decrypted. This is an optimization for queries that
  //do not pass any encrypted input parameters. Overrides the connection level setting for this command.
  ResultSetOnly,
  // Disables TCE for the command.Overrides the connection level setting for this command.
  Disabled,
}
