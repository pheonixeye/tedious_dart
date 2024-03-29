// ignore_for_file: constant_identifier_names

enum Procedures {
  Sp_Cursor(1),
  Sp_CursorOpen(2),
  Sp_CursorPrepare(3),
  Sp_CursorExecute(4),
  Sp_CursorPrepExec(5),
  Sp_CursorUnprepare(6),
  Sp_CursorFetch(7),
  Sp_CursorOption(8),
  Sp_CursorClose(9),
  Sp_ExecuteSql(10),
  Sp_Prepare(11),
  Sp_Execute(12),
  Sp_PrepExec(13),
  Sp_PrepExecRpc(14),
  Sp_Unprepare(15);

  final int value;
  const Procedures(this.value);
}
