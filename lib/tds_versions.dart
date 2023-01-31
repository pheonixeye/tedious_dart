const Map<String, int> versions = {
  '7_1': 0x71000001,
  '7_2': 0x72090002,
  '7_3_A': 0x730A0003,
  '7_3_B': 0x730B0003,
  '7_4': 0x74000004
};

final Map<int, String> versionsByValue =
    versions.map((key, value) => MapEntry(value, key));
