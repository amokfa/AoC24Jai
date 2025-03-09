
open :: (path: string) -> DbOpenResult {
  db: *sqlite3;
  result := sqlite3_open_v2(temp_c_string(path), *db, SQLITE_OPEN_READWRITE, null);
  handle(result);
  er := exec(db, "SELECT 1");
  if er.tag == {
    case .Ok; return .{ .Ok, .{ Ok = db }};
    case .Err; return .{ .Err, .{ Err= er.data.Err }};
  }
}

exec :: (db: Db, query: string, $result_type: Type, params: ..Any) -> DbExecResult {
  stmt: *sqlite3_stmt;
  result := sqlite3_prepare_v2(db, query.data, query.count, *stmt);
  handle(result);
  return .{ tag = .Ok };
}

Db :: *sqlite3;

#insert #run gen_enum(
  "DbOpenResult",
  .[
    .{ "Ok", Db },
    .{ "Err", string },
  ],
);

#insert #run gen_enum(
  "DbExecResult",
  .[
    .{ "Ok", void },
    .{ "Err", string },
  ],
);

#scope_file

from_c_string :: (ptr: *u8) -> string {
  len := c_style_strlen(ptr);
  return .{ data = ptr, count = len };
}

handle :: (result: int) #expand {
  if result != SQLITE_OK {
    return .{ .Err, .{ Err = from_c_string(sqlite3_errmsg(db)) }};
  }
}

#import,file "bindings.jai";
#import "Basic";
#import "Print_Vars";
#import,file "tagged_enum.jai";