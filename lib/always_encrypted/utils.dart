import 'package:tedious_dart/always_encrypted/types.dart';

bool shouldHonorAE(
    SQLServerStatementColumnEncryptionSetting stmtColumnEncryptionSetting,
    bool columnEncryptionSetting) {
  switch (stmtColumnEncryptionSetting) {
    case SQLServerStatementColumnEncryptionSetting.Disabled:
    case SQLServerStatementColumnEncryptionSetting.ResultSetOnly:
      return false;
    case SQLServerStatementColumnEncryptionSetting.Enabled:
      return true;
    default:
      return columnEncryptionSetting;
  }
}
