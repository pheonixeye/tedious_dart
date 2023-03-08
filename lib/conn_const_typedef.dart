// ignore_for_file: constant_identifier_names

import 'package:magic_buffer/magic_buffer.dart';
import 'package:tedious_dart/always_encrypted/keystore_provider_azure_key_vault.dart';
import 'package:tedious_dart/metadata_parser.dart';

typedef BeginTransactionCallback = void Function(
    {Error? err, Buffer? transactionDescriptor});

typedef SaveTransactionCallback = void Function({Error? err});

typedef CommitTransactionCallback = void Function({Error? err});

typedef RollbackTransactionCallback = void Function({Error? err});

typedef ResetCallback = void Function({Error? err});

typedef TransactionDoneCallback<T> = void Function(
    {Error? err, T done, List<CallbackParameters<T>>? args});

typedef CallbackParameters<T> = T? Function({Error? err, Map? args});

typedef TransactionDone<T> = void Function(
    {Error? err, T done, CallbackParameters<T> callbackParameters});

typedef TransactionCallback<T> = void Function(
    {Error? err, TransactionDone<T>? txDone});

const KEEP_ALIVE_INITIAL_DELAY = 30 * 1000;

const DEFAULT_CONNECT_TIMEOUT = 15 * 1000;

const DEFAULT_CLIENT_REQUEST_TIMEOUT = 15 * 1000;

const DEFAULT_CANCEL_TIMEOUT = 5 * 1000;

const DEFAULT_CONNECT_RETRY_INTERVAL = 500;

const DEFAULT_PACKET_SIZE = 4 * 1024;

const DEFAULT_TEXTSIZE = 2147483647;

const DEFAULT_DATEFIRST = 7;

const DEFAULT_PORT = 1433;

const DEFAULT_TDS_VERSION = '7_4';

const DEFAULT_LANGUAGE = 'us_english';

const DEFAULT_DATEFORMAT = 'mdy';

typedef ColumnNameReplacer = String? Function(
    {String? colName, num? index, Metadata? metadata});

typedef KeyStoreProviderMap
    = Map<String, ColumnEncryptionAzureKeyVaultProvider>;

// class AuthenticationOptions {
//   AuthenticationType? type;
//   dynamic options;
//   AuthenticationOptions({
//     this.type,
//     this.options,
//   });
// }

const Map<String, int> CLEANUP_TYPE = {
  'NORMAL': 0,
  'REDIRECT': 1,
  'RETRY': 2,
};
