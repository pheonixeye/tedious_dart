import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/token/token.dart';

class UnexpectedTokenError extends MTypeError {
  UnexpectedTokenError(Token token)
      : super('Unexpected token ${token.name} in ${token.handlerName}');
}

class TokenHandler {
  onInfoMessage(InfoMessageToken token) {
    throw UnexpectedTokenError(token);
  }

  onErrorMessage(ErrorMessageToken token) {
    throw UnexpectedTokenError(token);
  }

  onSSPI(SSPIToken token) {
    throw UnexpectedTokenError(token);
  }

  onDatabaseChange(DatabaseEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  onLanguageChange(LanguageEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  onCharsetChange(CharsetEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  onSqlCollationChange(CollationChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  onRoutingChange(RoutingEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  onPacketSizeChange(PacketSizeEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  onResetConnection(ResetConnectionEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  onBeginTransaction(BeginTransactionEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  onCommitTransaction(CommitTransactionEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  onRollbackTransaction(RollbackTransactionEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }

  onFedAuthInfo(FedAuthInfoToken token) {
    throw UnexpectedTokenError(token);
  }

  onFeatureExtAck(FeatureExtAckToken token) {
    throw UnexpectedTokenError(token);
  }

  onLoginAck(LoginAckToken token) {
    throw UnexpectedTokenError(token);
  }

  onColMetadata(ColMetadataToken token) {
    throw UnexpectedTokenError(token);
  }

  onOrder(OrderToken token) {
    throw UnexpectedTokenError(token);
  }

  onRow(RowToken token) {
    throw UnexpectedTokenError(token);
  }

  onNBCRow(NBCRowToken token) {
    throw UnexpectedTokenError(token);
  }

  onReturnStatus(ReturnStatusToken token) {
    throw UnexpectedTokenError(token);
  }

  onReturnValue(ReturnValueToken token) {
    throw UnexpectedTokenError(token);
  }

  onDoneProc(DoneProcToken token) {
    throw UnexpectedTokenError(token);
  }

  onDoneInProc(DoneInProcToken token) {
    throw UnexpectedTokenError(token);
  }

  onDone(DoneToken token) {
    throw UnexpectedTokenError(token);
  }

  onDatabaseMirroringPartner(DatabaseMirroringPartnerEnvChangeToken token) {
    throw UnexpectedTokenError(token);
  }
}
