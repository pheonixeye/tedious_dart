enum BufferEncoding {
  ascii("ascii"),
  utf8("utf8"),
  utf_8("utf-8"),
  utf16le("utf16le"),
  ucs2("ucs2"),
  ucs_2("ucs-2"),
  base64("base64"),
  latin1("latin1"),
  binary("binary"),
  hex("hex");

  final String type;

  const BufferEncoding(this.type);
}
