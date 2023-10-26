// ignore_for_file: constant_identifier_names

import 'package:equatable/equatable.dart';

enum CSE implements Equatable {
  INITIALIZED('Initialized'),
  CONNECTING('Connecting'),
  SENT_PRELOGIN('SentPrelogin'),
  REROUTING('ReRouting'),
  TRANSIENT_FAILURE_RETRY('TRANSIENT_FAILURE_RETRY'),
  SENT_TLSSSLNEGOTIATION('SentTLSSSLNegotiation'),
  SENT_LOGIN7_WITH_STANDARD_LOGIN('SentLogin7WithStandardLogin'),
  SENT_LOGIN7_WITH_NTLM('SentLogin7WithNTLMLogin'),
  SENT_LOGIN7_WITH_FEDAUTH('SentLogin7Withfedauth'),
  LOGGED_IN_SENDING_INITIAL_SQL('LoggedInSendingInitialSql'),
  LOGGED_IN('LoggedIn'),
  SENT_CLIENT_REQUEST('SentClientRequest'),
  SENT_ATTENTION('SentAttention'),
  FINAL('Final');

  final String value;

  const CSE(this.value);

  @override
  List get props => [value];

  @override
  bool get stringify => false;
}
