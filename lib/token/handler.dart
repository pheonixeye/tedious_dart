// ignore_for_file: non_constant_identifier_names

import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/request.dart';
import 'package:tedious_dart/token/colmetadata_token_parser.dart';
import 'package:tedious_dart/token/token.dart';

class UnexpectedTokenError extends MTypeError {
  UnexpectedTokenError(Token token)
      : super('Unexpected token ${token.name} in ${token.handlerName}');
}

Map<String, Function> TOKEN_FUNCTIONS = {};

//!
abstract class _Handler {
  onInfoMessage(InfoMessageToken token);

  onErrorMessage(ErrorMessageToken token);

  onSSPI(SSPIToken token);

  onDatabaseChange(DatabaseEnvChangeToken token);

  onLanguageChange(LanguageEnvChangeToken token);

  onCharsetChange(CharsetEnvChangeToken token);

  onSqlCollationChange(CollationChangeToken token);

  onRoutingChange(RoutingEnvChangeToken token);

  onPacketSizeChange(PacketSizeEnvChangeToken token);

  onResetConnection(ResetConnectionEnvChangeToken token);

  onBeginTransaction(BeginTransactionEnvChangeToken token);

  onCommitTransaction(CommitTransactionEnvChangeToken token);

  onRollbackTransaction(RollbackTransactionEnvChangeToken token);

  onFedAuthInfo(FedAuthInfoToken token);

  onFeatureExtAck(FeatureExtAckToken token);

  onLoginAck(LoginAckToken token);

  onColMetadata(ColMetadataToken token);

  onOrder(OrderToken token);

  onRow(RowToken token);

  onNBCRow(NBCRowToken token);

  onReturnStatus(ReturnStatusToken token);

  onReturnValue(ReturnValueToken token);

  onDoneProc(DoneProcToken token);

  onDoneInProc(DoneInProcToken token);

  onDone(DoneToken token);

  onDatabaseMirroringPartner(DatabaseMirroringPartnerEnvChangeToken token);
}

//!
class TokenHandler implements _Handler {
  @override
  onInfoMessage(InfoMessageToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onErrorMessage(ErrorMessageToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onSSPI(SSPIToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onDatabaseChange(DatabaseEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onLanguageChange(LanguageEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onCharsetChange(CharsetEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onSqlCollationChange(CollationChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onRoutingChange(RoutingEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onPacketSizeChange(PacketSizeEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onResetConnection(ResetConnectionEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onBeginTransaction(BeginTransactionEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onCommitTransaction(CommitTransactionEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onRollbackTransaction(RollbackTransactionEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onFedAuthInfo(FedAuthInfoToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onFeatureExtAck(FeatureExtAckToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onLoginAck(LoginAckToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onColMetadata(ColMetadataToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onOrder(OrderToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onRow(RowToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onNBCRow(NBCRowToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onReturnStatus(ReturnStatusToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onReturnValue(ReturnValueToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onDoneProc(DoneProcToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onDoneInProc(DoneInProcToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onDone(DoneToken token) {
    throw UnexpectedTokenError(token);
  }

  @override
  onDatabaseMirroringPartner(DatabaseMirroringPartnerEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }
}

//!
class InitialSqlTokenHandler implements TokenHandler {
  final Connection connection;
  InitialSqlTokenHandler(this.connection) : super();
  @override
  onBeginTransaction(BeginTransactionEnvChangeToken token) {
    connection.transactionDescriptors.add(token.newValue);
    connection.inTransaction = true;
  }

  @override
  onCharsetChange(CharsetEnvChangeToken token) {
    connection.emit('charsetChange', token.newValue);
  }

  @override
  onColMetadata(ColMetadataToken token) {
    connection.emit(
        'error',
        MTypeError(
          "Received 'columnMetadata' when no sqlRequest is in progress",
        ));
    connection.close();
  }

  @override
  onCommitTransaction(CommitTransactionEnvChangeToken token) {
    connection.transactionDescriptors.length = 1;
    connection.inTransaction = false;
  }

  @override
  onDatabaseChange(DatabaseEnvChangeToken token) {
    connection.emit('databaseChange', token.newValue);
  }

  @override
  onDatabaseMirroringPartner(DatabaseMirroringPartnerEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onDone(DoneToken token) {}

  @override
  onDoneInProc(DoneInProcToken token) {}

  @override
  onDoneProc(DoneProcToken token) {}

  @override
  onErrorMessage(ErrorMessageToken token) {
    connection.emit('errorMessage', token);
  }

  @override
  onFeatureExtAck(FeatureExtAckToken token) {
    throw UnimplementedError();
  }

  @override
  onFedAuthInfo(FedAuthInfoToken token) {
    throw UnimplementedError();
  }

  @override
  onInfoMessage(InfoMessageToken token) {
    connection.emit('infoMessage', token);
  }

  @override
  onLanguageChange(LanguageEnvChangeToken token) {
    connection.emit('languageChange', token.newValue);
  }

  @override
  onLoginAck(LoginAckToken token) {
    throw UnimplementedError();
  }

  @override
  onNBCRow(NBCRowToken token) {
    connection.emit('error',
        MTypeError("Received 'row' when no sqlRequest is in progress"));
    connection.close();
  }

  @override
  onOrder(OrderToken token) {
    connection.emit('error',
        MTypeError("Received 'order' when no sqlRequest is in progress"));
    connection.close();
  }

  @override
  onPacketSizeChange(PacketSizeEnvChangeToken token) {
    connection.messageIo.packetSize([token.newValue as int]);
  }

  @override
  onResetConnection(ResetConnectionEnvChangeToken token) {
    connection.emit('resetConnection');
  }

  @override
  onReturnStatus(ReturnStatusToken token) {}

  @override
  onReturnValue(ReturnValueToken token) {}

  @override
  onRollbackTransaction(RollbackTransactionEnvChangeToken token) {
    connection.transactionDescriptors.length = 1;
    // An outermost transaction was rolled back. Reset the transaction counter
    connection.inTransaction = false;
    connection.emit('rollbackTransaction');
  }

  @override
  onRoutingChange(RoutingEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onRow(RowToken token) {
    connection.emit('error',
        MTypeError("Received 'row' when no sqlRequest is in progress"));
    connection.close();
  }

  @override
  onSSPI(SSPIToken token) {
    throw UnimplementedError();
  }

  @override
  onSqlCollationChange(CollationChangeToken token) {
    connection.databaseCollation = token.newValue;
  }
}

//!
class Login7TokenHandler implements TokenHandler {
  final Connection connection;
  FedAuthInfoToken? fedAuthInfoToken;
  RoutingData? routingData;

  bool loginAckReceived = false;
  Login7TokenHandler(
    this.connection, {
    this.fedAuthInfoToken,
    this.loginAckReceived = false,
    this.routingData,
  });
  @override
  onBeginTransaction(BeginTransactionEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onCharsetChange(CharsetEnvChangeToken token) {
    connection.emit('charsetChange', token.newValue);
  }

  @override
  onColMetadata(ColMetadataToken token) {
    throw UnimplementedError();
  }

  @override
  onCommitTransaction(CommitTransactionEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onDatabaseChange(DatabaseEnvChangeToken token) {
    connection.emit('databaseChange', token.newValue);
  }

  @override
  onDatabaseMirroringPartner(DatabaseMirroringPartnerEnvChangeToken token) {}

  @override
  onDone(DoneToken token) {}

  @override
  onDoneInProc(DoneInProcToken token) {}

  @override
  onDoneProc(DoneProcToken token) {
    throw UnimplementedError();
  }

  @override
  onErrorMessage(ErrorMessageToken token) {
    connection.emit('errorMessage', token);

    final error = ConnectionError(token.message, 'ELOGIN');

    final isLoginErrorTransient =
        connection.transientErrorLookup.isTransientError(token.number as int);
    if (isLoginErrorTransient &&
        connection.curTransientRetryCount !=
            connection.config!.options!.maxRetriesOnTransientErrors) {
      error.isTransient = true;
    }

    connection.loginError = error;
  }

  @override
  onFeatureExtAck(FeatureExtAckToken token) {
    final authentication = connection.config!.authentication!;

    if (authentication.type == 'azure-active-directory-password' ||
        authentication.type == 'azure-active-directory-access-token' ||
        authentication.type == 'azure-active-directory-msi-vm' ||
        authentication.type == 'azure-active-directory-msi-app-service' ||
        authentication.type ==
            'azure-active-directory-service-principal-secret' ||
        authentication.type == 'azure-active-directory-default') {
      if (token.fedAuth == null) {
        connection.loginError = ConnectionError(
            'Did not receive Active Directory authentication acknowledgement');
      } else if (token.fedAuth!.length != 0) {
        connection.loginError = ConnectionError(
            'Active Directory authentication acknowledgment for ${authentication.type} authentication method includes extra data');
      }
    } else if (token.fedAuth == null && token.utf8Support == null) {
      connection.loginError =
          ConnectionError('Received acknowledgement for unknown feature');
    } else if (token.fedAuth != null) {
      connection.loginError = ConnectionError(
          'Did not request Active Directory authentication, but received the acknowledgment');
    }
  }

  @override
  onFedAuthInfo(FedAuthInfoToken token) {
    fedAuthInfoToken = token;
  }

  @override
  onInfoMessage(InfoMessageToken token) {
    connection.emit('infoMessage', token);
  }

  @override
  onLanguageChange(LanguageEnvChangeToken token) {
    connection.emit('languageChange', token.newValue);
  }

  @override
  onLoginAck(LoginAckToken token) {
    if (token.tdsVersion.isEmpty) {
      // unsupported TDS version
      connection.loginError =
          ConnectionError('Server responded with unknown TDS version.', 'ETDS');
      return;
    }

    if (token.interface.isEmpty) {
      // unsupported interface
      connection.loginError = ConnectionError(
          'Server responded with unsupported interface.', 'EINTERFACENOTSUPP');
      return;
    }

    // use negotiated version
    connection.config!.options!.tdsVersion = token.tdsVersion;

    loginAckReceived = true;
  }

  @override
  onNBCRow(NBCRowToken token) {
    throw UnimplementedError();
  }

  @override
  onOrder(OrderToken token) {
    throw UnimplementedError();
  }

  @override
  onPacketSizeChange(PacketSizeEnvChangeToken token) {
    connection.messageIo.packetSize([token.newValue as int]);
  }

  @override
  onResetConnection(ResetConnectionEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onReturnStatus(ReturnStatusToken token) {
    throw UnimplementedError();
  }

  @override
  onReturnValue(ReturnValueToken token) {
    throw UnimplementedError();
  }

  @override
  onRollbackTransaction(RollbackTransactionEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onRoutingChange(RoutingEnvChangeToken token) {
    // Removes instance name attached to the redirect url. E.g., redirect.db.net\instance1 --> redirect.db.net
    final List server = token.newValue!.server.split('\\');

    routingData = RoutingData(server: server.first, port: token.newValue!.port);
  }

  @override
  onRow(RowToken token) {
    throw UnimplementedError();
  }

  @override
  onSSPI(SSPIToken token) {
    if (token.ntlmpacket) {
      connection.ntlmpacket = token.ntlmpacket;
      connection.ntlmpacketBuffer = token.ntlmpacketBuffer;
    }
  }

  @override
  onSqlCollationChange(CollationChangeToken token) {
    connection.databaseCollation = token.newValue;
  }
}

//!
class RequestTokenHandler implements TokenHandler {
  Connection connection;
  dynamic request;
  // : Request | BulkLoad;
  List<RequestError> errors;
  RequestTokenHandler(this.connection, this.request, this.errors) {
    errors = [];
  }
  @override
  onBeginTransaction(BeginTransactionEnvChangeToken token) {
    connection.transactionDescriptors.add(token.newValue);
    connection.inTransaction = true;
  }

  @override
  onCharsetChange(CharsetEnvChangeToken token) {
    connection.emit('charsetChange', token.newValue);
  }

  @override
  onColMetadata(ColMetadataToken token) {
    if (!(request as Request).canceled) {
      if (connection.config!.options!.useColumnNames) {
        Map<String, ColumnMetadata> columns = {};

        for (int j = 0, len = token.columns.length; j < len; j++) {
          final col = token.columns[j];
          if (columns[col.colName] == null) {
            columns[col.colName] = col;
          }
        }

        request.emit('columnMetadata', columns);
      } else {
        request.emit('columnMetadata', token.columns);
      }
    }
  }

  @override
  onCommitTransaction(CommitTransactionEnvChangeToken token) {
    connection.transactionDescriptors.length = 1;
    connection.inTransaction = false;
  }

  @override
  onDatabaseChange(DatabaseEnvChangeToken token) {
    connection.emit('databaseChange', token.newValue);
  }

  @override
  onDatabaseMirroringPartner(DatabaseMirroringPartnerEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onDone(DoneToken token) {
    if (!(request as Request).canceled) {
      if (token.sqlError == true && (request as Request).error != null) {
        // check if the DONE_ERROR flags was set, but an ERROR token was not sent.
        (request as Request).error = RequestError(
            message: 'An unknown error has occurred.', code: 'UNKNOWN');
      }

      (request as Request)
          .emit('done', [token.rowCount, token.more, (request as Request).rst]);

      if (token.rowCount != null) {
        // (this.request as Request).rowCount! += token.rowCount;
        (request as Request)
            .setRowCount((request as Request).rowCount! + token.rowCount!);
      }

      if (connection.config!.options!.rowCollectionOnDone) {
        (request as Request).rst = [];
      }
    }
  }

  @override
  onDoneInProc(DoneInProcToken token) {
    if (!(request as Request).canceled) {
      (request as Request)
          .emit('doneInProc', [token.rowCount, token.more, request.rst]);

      if (token.rowCount != null) {
        (request as Request)
            .setRowCount((request as Request).rowCount! + token.rowCount!);
      }

      if (connection.config!.options!.rowCollectionOnDone) {
        request.rst = [];
      }
    }
  }

  @override
  onDoneProc(DoneProcToken token) {
    if (!(request as Request).canceled) {
      if (token.sqlError == true && (request as Request).error != null) {
        // check if the DONE_ERROR flags was set, but an ERROR token was not sent.
        request.error = RequestError(
            message: 'An unknown error has occurred.', code: 'UNKNOWN');
      }

      request.emit('doneProc', token.rowCount, token.more,
          connection.procReturnStatusValue, request.rst);

      connection.procReturnStatusValue = null;

      if (token.rowCount != null) {
        // (this.request as Request).rowCount! = (this.request as Request).rowCount!  + token.rowCount!;
        (request as Request)
            .setRowCount((request as Request).rowCount! + token.rowCount!);
      }

      if (connection.config!.options!.rowCollectionOnDone) {
        request.rst = [];
      }
    }
  }

  @override
  onErrorMessage(ErrorMessageToken token) {
    connection.emit('errorMessage', token);

    if (!(request as Request).canceled) {
      final error = RequestError(message: token.message, code: 'EREQUEST');

      error.number = token.number as int;
      error.state = token.state as int;
      error.Class = token.clazz as int;
      error.serverName = token.serverName;
      error.procName = token.procName;
      error.lineNumber = token.lineNumber as int;

      errors.add(error);
      request.error = error;
      if (request is Request && errors.length > 1) {
        request.error = MTypeError(errors.toString()); //TODO: aggregateError
      }
    }
  }

  @override
  onFeatureExtAck(FeatureExtAckToken token) {
    throw UnimplementedError();
  }

  @override
  onFedAuthInfo(FedAuthInfoToken token) {
    throw UnimplementedError();
  }

  @override
  onInfoMessage(InfoMessageToken token) {
    connection.emit('infoMessage', token);
  }

  @override
  onLanguageChange(LanguageEnvChangeToken token) {
    connection.emit('languageChange', token.newValue);
  }

  @override
  onLoginAck(LoginAckToken token) {
    throw UnimplementedError();
  }

  @override
  onNBCRow(NBCRowToken token) {
    if (!(request as Request).canceled) {
      if (connection.config!.options!.rowCollectionOnRequestCompletion) {
        (request as Request).rows!.add(token.columns);
      }

      if (connection.config!.options!.rowCollectionOnDone) {
        (request as Request).rst!.add(token.columns);
      }

      (request as Request).emit('row', token.columns);
    }
  }

  @override
  onOrder(OrderToken token) {
    if (!(request as Request).canceled) {
      (request as Request).emit('order', token.columns);
    }
  }

  @override
  onPacketSizeChange(PacketSizeEnvChangeToken token) {
    connection.messageIo.packetSize([token.newValue as int]);
  }

  @override
  onResetConnection(ResetConnectionEnvChangeToken token) {
    connection.emit('resetConnection');
  }

  @override
  onReturnStatus(ReturnStatusToken token) {
    if (!(request as Request).canceled) {
      // Keep value for passing in 'doneProc' event.
      connection.procReturnStatusValue = token.value;
    }
  }

  @override
  onReturnValue(ReturnValueToken token) {
    if (!(request as Request).canceled) {
      (request as Request)
          .emit('returnValue', [token.paramName, token.value, token.metadata]);
    }
  }

  @override
  onRollbackTransaction(RollbackTransactionEnvChangeToken token) {
    connection.transactionDescriptors.length = 1;
    // An outermost transaction was rolled back. Reset the transaction counter
    connection.inTransaction = false;
    connection.emit('rollbackTransaction');
  }

  @override
  onRoutingChange(RoutingEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onRow(RowToken token) {
    if (!(request as Request).canceled) {
      if (connection.config!.options!.rowCollectionOnRequestCompletion) {
        (request as Request).rows!.add(token.columns);
      }

      if (connection.config!.options!.rowCollectionOnDone) {
        (request as Request).rst!.add(token.columns);
      }

      (request as Request).emit('row', token.columns);
    }
  }

  @override
  onSSPI(SSPIToken token) {
    throw UnimplementedError();
  }

  @override
  onSqlCollationChange(CollationChangeToken token) {
    connection.databaseCollation = token.newValue;
  }
}

//!
class AttentionTokenHandler implements TokenHandler {
  Connection connection;
  dynamic request;
  //Request | BulkLoad
  bool attentionReceived = false;

  AttentionTokenHandler(
    this.connection,
    this.request,
  ) {
    attentionReceived = false;
  }

  @override
  onBeginTransaction(BeginTransactionEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onCharsetChange(CharsetEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onColMetadata(ColMetadataToken token) {
    throw UnimplementedError();
  }

  @override
  onCommitTransaction(CommitTransactionEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onDatabaseChange(DatabaseEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onDatabaseMirroringPartner(DatabaseMirroringPartnerEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onDone(DoneToken token) {
    if (token.attention == true) {
      attentionReceived = true;
    }
  }

  @override
  onDoneInProc(DoneInProcToken token) {
    throw UnimplementedError();
  }

  @override
  onDoneProc(DoneProcToken token) {
    throw UnimplementedError();
  }

  @override
  onErrorMessage(ErrorMessageToken token) {
    throw UnimplementedError();
  }

  @override
  onFeatureExtAck(FeatureExtAckToken token) {
    throw UnimplementedError();
  }

  @override
  onFedAuthInfo(FedAuthInfoToken token) {
    throw UnimplementedError();
  }

  @override
  onInfoMessage(InfoMessageToken token) {
    throw UnimplementedError();
  }

  @override
  onLanguageChange(LanguageEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onLoginAck(LoginAckToken token) {
    throw UnimplementedError();
  }

  @override
  onNBCRow(NBCRowToken token) {
    throw UnimplementedError();
  }

  @override
  onOrder(OrderToken token) {
    throw UnimplementedError();
  }

  @override
  onPacketSizeChange(PacketSizeEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onResetConnection(ResetConnectionEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onReturnStatus(ReturnStatusToken token) {
    throw UnimplementedError();
  }

  @override
  onReturnValue(ReturnValueToken token) {
    throw UnimplementedError();
  }

  @override
  onRollbackTransaction(RollbackTransactionEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onRoutingChange(RoutingEnvChangeToken token) {
    throw UnimplementedError();
  }

  @override
  onRow(RowToken token) {
    throw UnimplementedError();
  }

  @override
  onSSPI(SSPIToken token) {
    throw UnimplementedError();
  }

  @override
  onSqlCollationChange(CollationChangeToken token) {
    throw UnimplementedError();
  }
}
