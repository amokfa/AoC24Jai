open :: (path: string) -> Result(Db, string) {
  result: Db;
  exit_code := sqlite3_open(temp_c_string(path), *result);
  if exit_code != SQLITE_OK {
    err := sqlite3_errmsg(result);
    return .{ .Err, .{ err = from_c_string(err) }};
  }
  return .{ .Ok, .{ ok = result }};
}

prepare :: (db: Db, query: string) -> Result(Stmt, string) {
  stmt: *sqlite3_stmt;
  exit_code := sqlite3_prepare_v2(db, temp_c_string(query), xx query.count, *stmt, null);
  if exit_code != SQLITE_OK {
    err := sqlite3_errmsg(db);
    return .{ .Err, .{ err = from_c_string(err) }};
  }
  return .{ .Ok, .{ ok = .{stmt, db} }};
}

destroy :: (stmt: Stmt) {
  sqlite3_finalize(stmt);
}

bind :: (stmt: Stmt, index: s32, value: Any) -> Result(void, string) {
  exit_code: s32;
  ifx value.type.type == {
    case .VOID; exit_code = sqlite3_bind_null(stmt.inner, index);
    case .INTEGER;
      ok, value := parse_int(value);
      if !ok return .{ .Err, .{err = tprint("integer argument does not fit in s64")}};
      exit_code = sqlite3_bind_int64(stmt.inner, index, value);
    case .STRING;
      s := cast(*string, value.value_pointer).*;
      exit_code = sqlite3_bind_text(stmt.inner, index, xx s.data, xx s.count, null);
    case .ARRAY; return .{ .Err, .{ err = tprint("I'm not using blobs right now so don't need to figure these out ATM: %", value) }};
    case; return .{ .Err, .{ err = tprint("invalid bind parameter: %", value) }};
  };
  if exit_code != SQLITE_OK {
    err := sqlite3_errmsg(stmt.db);
    return .{ .Err, .{ err = from_c_string(err) }};
  }
  return .{.Ok, .{}};
}

step :: (stmt: Stmt) -> StepResult {
  exit_code := sqlite3_step(stmt.inner);
  if exit_code == {
    case SQLITE_ROW;
      return .{tag = .Row};
    case SQLITE_DONE;
      return .{tag = .Done};
    case SQLITE_BUSY;
      return .{tag = .Busy};
    case;
      err := sqlite3_errmsg(stmt.db);
      return .{ .Err, .{ Err = from_c_string(err) }};
  }
}

#insert #run gentenum_impl(
  "StepResult",
  .[
    .{"Row", void},
    .{"Done", void},
    .{"Busy", void},
    .{"Err", string},
  ]
);

column :: (stmt: Stmt, index: s32, $type: Type) -> type {
  ti :: type_info(type);

  #if ti.type == {
    case .INTEGER;
      tii := cast(*Type_Info_Integer, ti);
      assert(tii.runtime_size == 8 && tii.signed);
      return sqlite3_column_int64(stmt.inner, index);
    case .STRING;
      cs := sqlite3_column_text(stmt.inner, index);
      return from_c_string(cs);
    case;
      assert(false, "don't support anything else rn coz I don't need anything else right now");
  }
}

parse_int :: (value: Any) -> ok: bool, value: s64 {
  if value.type.type != .INTEGER {
    return false, 0;
  }
  info := cast(*Type_Info_Integer, value.type);
  if info.signed == {
    case true;
    if info.runtime_size == {
      case 1;
        return true, xx cast(*s8, value.value_pointer).*;
      case 2;
        return true, xx cast(*s16, value.value_pointer).*;
      case 4;
        return true, xx cast(*s32, value.value_pointer).*;
      case 8;
        return true, cast(*s64, value.value_pointer).*;
    }
    case false;
    if info.runtime_size == {
      case 1;
        return true, xx cast(*u8, value.value_pointer).*;
      case 2;
        return true, xx cast(*u16, value.value_pointer).*;
      case 4;
        return true, xx cast(*u32, value.value_pointer).*;
      case 8;
        return false, 0;
    }
  }
  assert(false);
  return false, 0;
}

Db :: *sqlite3;
Stmt :: struct {
  inner: *sqlite3_stmt;
  db: Db;
};

Result :: struct ($T: Type, $E: Type) {
  tag: enum { Ok; Err; };
  data: union { ok: T; err: E; };
}

#scope_file

from_c_string :: (ptr: *u8) -> string {
  len := c_style_strlen(ptr);
  return .{ data = ptr, count = len };
}

#import,file "./sqlite3.jai";
#import "Basic";
#import "STL";
