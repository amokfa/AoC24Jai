open :: (path: string) -> Result(Db, string) {
  result: Db;
  exit_code := sqlite3_open(temp_c_string(path), *result);
  if exit_code != SQLITE_OK {
    err := sqlite3_errmsg(result);
    return .{ .Err, .{ Err = from_c_string(err) }};
  }
  return .{ .Ok, .{ Ok = result }};
}

exec :: (db: Db, query: string, params: [] Any = .[], $output: Type = void) -> Result([..] output, string) {
  ti :: type_info(output);
  assert(ti.type == .VOID || ti.type == .STRUCT);
  if ti.type == .STRUCT {
    tis := cast(*Type_Info_Struct, ti);
    for field: tis.members {
      assert(
        field.type.type == .STRING ||
        (field.type.type == .INTEGER && field.type.runtime_size == 8 && cast(*Type_Info_Integer, field.type).signed));
    }
  }

  r1 := prepare(db, query);
  if r1.tag != .Ok return .{.Err, .{Err = tprint("invalid query: %", r1.data.Err)}};
  stmt := r1.data.Ok;
  defer destroy(stmt);
  for param: params {
    r2 := bind(stmt, xx(it_index+1), param);
    if r2.tag != .Ok return .{.Err, .{Err = tprint("binding param(%) failed: %", it_index, r2.data.Err)}};
  }

  result: [..] output;
  while true {
    r3 := step(stmt);
    if r3.tag == {
      case .Done; break;
      case .Row;
        if ti.type == .STRUCT {
          tis := cast(*Type_Info_Struct, ti);
          row: output;
          for field: tis.members {
            if field.type.type == {
              case .STRING;
                fptr := cast(*string, cast(*void, *row) + field.offset_in_bytes);
                fptr.* = column(stmt, xx it_index, string);
              case .INTEGER;
                fptr := cast(*s64, cast(*void, *row) + field.offset_in_bytes);
                fptr.* = column(stmt, xx it_index, s64);
            }
          }
          array_add(*result, row);
        }
      case .Busy;
      case .Err;
        return .{.Err, .{Err = tprint("stepping failed: %", r3.data.Err)}};
    }
  }
  return .{.Ok, .{Ok = result}};
}

exec_value :: (db: Db, query: string, params: [] Any, $output: Type) -> Result(output, string) {
  ti :: type_info(output);
  assert(ti.type == .STRING || (ti.type == .INTEGER && ti.runtime_size == 8 && cast(*Type_Info_Integer, ti).signed));

  r1 := prepare(db, query);
  if r1.tag != .Ok return .{.Err, .{Err = tprint("invalid query: %", r1.data.Err)}};
  stmt := r1.data.Ok;
  defer destroy(stmt);
  for param: params {
    r2 := bind(stmt, xx(it_index+1), param);
    if r2.tag != .Ok return .{.Err, .{Err = tprint("binding param(%) failed: %", it_index, r2.data.Err)}};
  }

  while true {
    r3 := step(stmt);
    if r3.tag == {
      case .Done; break;
      case .Row;
        #if ti.type == {
          case .STRING;
            return .{.Ok, .{Ok = column(stmt, xx 0, string)}};
          case .INTEGER;
            return .{.Ok, .{Ok = column(stmt, xx 0, s64)}};
        }
      case .Busy;
      case .Err;
        return .{.Err, .{Err = tprint("stepping failed: %", r3.data.Err)}};
    }
  }
  return .{.Err, .{Err = "no rows found"}};
}

Db :: *sqlite3;
Stmt :: struct {
  inner: *sqlite3_stmt;
  db: Db;
};
Result :: struct ($T: Type, $E: Type) {
  tag: enum { Ok; Err; };
  data: union { Ok: T; Err: E; };
}

unwrap :: (r: Result($T, $E)) -> T {
  if r.tag != .Ok {
    println("ERROR: %", r.data.Err);
    print_stack_trace(context.stack_trace);
    exit(1);
  }
  return r.data.Ok;
}

#scope_file

from_c_string :: (ptr: *u8) -> string {
  len := c_style_strlen(ptr);
  return .{ data = ptr, count = len };
}

prepare :: (db: Db, query: string) -> Result(Stmt, string) {
  stmt: *sqlite3_stmt;
  exit_code := sqlite3_prepare_v2(db, temp_c_string(query), xx query.count, *stmt, null);
  if exit_code != SQLITE_OK {
    err := sqlite3_errmsg(db);
    return .{ .Err, .{ Err = from_c_string(err) }};
  }
  return .{ .Ok, .{ Ok = .{stmt, db} }};
}

destroy :: (stmt: Stmt) {
  sqlite3_finalize(stmt.inner);
}

bind :: (stmt: Stmt, index: s32, value: Any) -> Result(void, string) {
  exit_code: s32;
  ifx value.type.type == {
    case .VOID; exit_code = sqlite3_bind_null(stmt.inner, index);
    case .INTEGER;
      ok, value := parse_int(value);
      if !ok return .{ .Err, .{Err = tprint("integer argument does not fit in s64")}};
      exit_code = sqlite3_bind_int64(stmt.inner, index, value);
    case .STRING;
      s := cast(*string, value.value_pointer).*;
      exit_code = sqlite3_bind_text(stmt.inner, index, xx s.data, xx s.count, null);
    case .ARRAY; return .{ .Err, .{ Err = tprint("I'm not using blobs right now so don't need to figure these out ATM: %", value) }};
    case; return .{ .Err, .{ Err = tprint("invalid bind parameter: %", value) }};
  };
  if exit_code != SQLITE_OK {
    err := sqlite3_errmsg(stmt.db);
    return .{ .Err, .{ Err = from_c_string(err) }};
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
      return tprint("%", from_c_string(cs));
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

Query :: struct ($output: Type) {
  query: string;
  params: [] Any;
}

#import,file "./sqlite3.jai";
#import "Basic";
#import "STL";
