import 'package:tedious_dart/models/buffer.dart';

class SymmetricKey {
  Buffer? rootKey;

  SymmetricKey(this.rootKey) {
    if (rootKey == null) {
      throw AssertionError('Column encryption key cannot be null.');
    } else if (rootKey!.length == 0) {
      throw AssertionError('Empty column encryption key specified.');
    }
    rootKey = rootKey;
  }

  zeroOutKey() {
    rootKey = Buffer.fromList([rootKey!.length]);
  }
}
