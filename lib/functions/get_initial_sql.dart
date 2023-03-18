import 'package:tedious_dart/conn_const_typedef.dart';
import 'package:tedious_dart/functions/get_isolation_level.dart';

String getInitialSql() {
  List options = [];

  // if (config.options.enableAnsiNull == true) {
  options.add('set ansi_nulls on');
  // } else if (config.options.enableAnsiNull == false) {
  // options.add('set ansi_nulls off');
  // }

  // if (config.options.enableAnsiNullDefault == true) {
  options.add('set ansi_null_dflt_on on');
  // } else if (config.options.enableAnsiNullDefault == false) {
  // options.add('set ansi_null_dflt_on off');
  // }

  // if (config.options.enableAnsiPadding == true) {
  options.add('set ansi_padding on');
  // } else if (config.options.enableAnsiPadding == false) {
  //   options.add('set ansi_padding off');
  // }

  // if (config.options.enableAnsiWarnings == true) {
  options.add('set ansi_warnings on');
  // } else if (config.options.enableAnsiWarnings == false) {
  //   options.add('set ansi_warnings off');
  // }

  // if (config.options.enableArithAbort == true) {
  options.add('set arithabort on');
  // } else if (config.options.enableArithAbort == false) {
  //   options.add('set arithabort off');
  // }

  // if (config.options.enableConcatNullYieldsNull == true) {
  options.add('set concat_null_yields_null on');
  // } else if (config.options.enableConcatNullYieldsNull == false) {
  //   options.add('set concat_null_yields_null off');
  // }

  // if (config.options.enableCursorCloseOnCommit == true) {
  options.add('set cursor_close_on_commit on');
  // } else if (config.options.enableCursorCloseOnCommit == false) {
  //   options.add('set cursor_close_on_commit off');
  // }

  // if (config.options.datefirst != null) {
  options.add('set datefirst $DEFAULT_DATEFIRST');
  // }

  // if (config.options.dateFormat != null) {
  options.add('set dateformat $DEFAULT_DATEFORMAT');
  // }

  // if (config.options.enableImplicitTransactions == true) {
  options.add('set implicit_transactions on');
  // } else if (config.options.enableImplicitTransactions == false) {
  //   options.add('set implicit_transactions off');
  // }

  // if (config.options.language != null) {
  options.add('set language $DEFAULT_LANGUAGE');
  // }

  // if (config.options.enableNumericRoundabort == true) {
  options.add('set numeric_roundabort on');
  // } else if (config.options.enableNumericRoundabort == false) {
  //   options.add('set numeric_roundabort off');
  // }

  // if (config.options.enableQuotedIdentifier == true) {
  options.add('set quoted_identifier on');
  // } else if (config.options.enableQuotedIdentifier == false) {
  //   options.add('set quoted_identifier off');
  // }

  // if (config.options.textsize != null) {
  options.add('set textsize $DEFAULT_TEXTSIZE');
  // }

  // if (config.options.connectionIsolationLevel != null) {
  options.add('set transaction isolation level ${getIsolationLevelText(0x02)}');
  // }

  // if (config.options.abortTransactionOnError == true) {
  options.add('set xact_abort on');
  // } else if (config.options.abortTransactionOnError == false) {
  //   options.add('set xact_abort off');
  // }

  return options.join('\n');
}
