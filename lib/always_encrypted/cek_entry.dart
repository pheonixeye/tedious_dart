// ignore_for_file: unnecessary_this

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/always_encrypted/types.dart';

class CEKEntry {
  late List<EncryptionKeyInfo> columnEncryptionKeyValues;
  late num ordinal;
  late num databaseId;
  late num cekId;
  late num cekVersion;
  late Buffer? cekMdVersion;

  CEKEntry(num ordinalVal) {
    ordinal = ordinalVal;
    databaseId = 0;
    cekId = 0;
    cekVersion = 0;
    cekMdVersion = Buffer.alloc(0);
    columnEncryptionKeyValues = [];
  }

  void add(
    Buffer encryptedKey,
    num dbId,
    num keyId,
    num keyVersion,
    Buffer? mdVersion,
    String keyPath,
    String keyStoreName,
    String algorithmName,
  ) {
    final EncryptionKeyInfo encryptionKey = EncryptionKeyInfo(
      encryptedKey: encryptedKey,
      dbId: dbId,
      keyId: keyId,
      keyVersion: keyVersion,
      mdVersion: mdVersion,
      keyPath: keyPath,
      keyStoreName: keyStoreName,
      algorithmName: algorithmName,
    );

    this.columnEncryptionKeyValues.add(encryptionKey);

    if (this.databaseId == 0) {
      this.databaseId = dbId;
      this.cekId = keyId;
      this.cekVersion = keyVersion;
      this.cekMdVersion = mdVersion;
    } else if ((this.databaseId != dbId) ||
        (this.cekId != keyId) ||
        (this.cekVersion != keyVersion) ||
        this.cekMdVersion != null ||
        mdVersion != null ||
        this.cekMdVersion!.length != mdVersion!.length) {
      throw AssertionError(
          'Invalid databaseId, cekId, cekVersion or cekMdVersion.');
    }
  }
}
