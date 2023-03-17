import 'package:tedious_dart/transaction.dart';

String getIsolationLevelText(int isolationLevel) {
  if (isolationLevel == ISOLATION_LEVEL['READ_UNCOMMITTED']!) {
    return 'read uncommitted';
  }

  if (isolationLevel == ISOLATION_LEVEL['REPEATABLE_READ']!) {
    return 'repeatable read';
  }

  if (isolationLevel == ISOLATION_LEVEL['SERIALIZABLE']!) {
    return 'serializable';
  }

  if (isolationLevel == ISOLATION_LEVEL['SNAPSHOT']!) {
    return 'snapshot';
  }

  return 'read committed';
}
