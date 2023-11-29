class Abdo {
  void testIt(String value) {
    print(value);
  }
}

void main(List<String> args) {
  Map<String, Function> fns = {};

  final abdo = Abdo();

  fns.addAll({"testIt": abdo.testIt});

  print(fns);

  fns['testIt']!("value");
}
