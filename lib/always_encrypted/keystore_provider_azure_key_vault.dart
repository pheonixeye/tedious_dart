import 'package:node_interop/buffer.dart';

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
class KeyClient {}

class ColumnEncryptionAzureKeyVaultProvider {
  String name;
  String? url;
  String rsaEncryptionAlgorithmWithOAEPForAKV;
  Buffer firstVersion;
  ClientSecretCredential credentials;
  String azureKeyVaultDomainName;
  KeyClient? keyClient;

  ColumnEncryptionAzureKeyVaultProvider(
      String clientId, String clientKey, String tenantId)
      : name = 'AZURE_KEY_VAULT',
        azureKeyVaultDomainName = 'vault.azure.net',
        rsaEncryptionAlgorithmWithOAEPForAKV = 'RSA-OAEP',
        firstVersion = Buffer.from([0x01]),
        credentials = ClientSecretCredential(
          clientId,
          clientKey,
          tenantId,
        );
}
//TODO: evaluate need