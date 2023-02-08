import 'dart:math';
import 'dart:typed_data';

class RandomBytes {
  static dynamic gen(
    int length, {
    bool secure = false,
    bool isString = false,
  }) {
    assert(length > 0);

    final random = secure ? Random.secure() : Random();
    final ret = Uint8List(length);

    for (var i = 0; i < length; i++) {
      ret[i] = random.nextInt(256);
    }

    StringBuffer sb = StringBuffer();
    for (var i = 0; i < length; i++) {
      sb.write(random.nextInt(265).toRadixString(16));
    }

    return isString ? sb.toString() : ret;
  }
}
