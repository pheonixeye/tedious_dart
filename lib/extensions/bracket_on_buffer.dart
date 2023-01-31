// ignore_for_file: unnecessary_this

import 'package:node_interop/buffer.dart';

extension Brackets on Buffer {
  operator [](int index) => this.values().elementAt(index);
  operator []=(int index, dynamic value) => this.values().map((e) {
        if (this.values().elementAt(index) == e) {
          e = value;
        }
      }).toList();
}
