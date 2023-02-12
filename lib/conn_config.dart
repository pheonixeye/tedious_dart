import 'package:tedious_dart/conn_authentication.dart';
import 'package:tedious_dart/conn_config_internal.dart';

class ConnectionOptions extends InternalConnectionOptions {
  ConnectionOptions({
    super.abortTransactionOnError,
    super.appName,
    super.camelCaseColumns,
    super.cancelTimeout,
    super.columnEncryptionKeyCacheTTL,
    super.columnEncryptionSetting,
    super.columnNameReplacer,
    super.connectionRetryInterval,
    super.connectTimeout,
    super.cryptoCredentialsDetails,
    super.database,
    super.datefirst,
    super.dateFormat,
    super.debug,
    super.enableAnsiNull,
    super.enableAnsiNullDefault,
    super.enableAnsiPadding,
    super.enableAnsiWarnings,
    super.enableArithAbort,
    super.enableConcatNullYieldsNull,
    super.enableCursorCloseOnCommit,
    super.enableImplicitTransactions,
    super.enableNumericRoundabort,
    super.enableQuotedIdentifier,
    super.encrypt,
    super.encryptionKeyStoreProviders,
    super.fallbackToDefaultDb,
    super.instanceName,
    super.language,
    super.localAddress,
    super.maxRetriesOnTransientErrors,
    super.multiSubnetFailover,
    super.packetSize,
    super.port,
    super.readOnlyIntent,
    super.requestTimeout,
    super.rowCollectionOnDone,
    super.rowCollectionOnRequestCompletion,
    super.serverName,
    super.serverSupportsColumnEncryption,
    super.tdsVersion,
    super.textsize,
    super.trustedServerNameAE,
    super.trustServerCertificate,
    super.useColumnNames,
    super.useUTC,
    super.workstationId,
    super.lowerCaseGuids,
    super.isolationLevel,
    super.connectionIsolationLevel,
  });
}

class ConnectionConfiguration {
  final String server;
  final ConnectionOptions options;
  final AuthenticationType authentication;

  ConnectionConfiguration({
    required this.server,
    required this.options,
    required this.authentication,
  });
}
