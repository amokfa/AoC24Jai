/*
 mysqlite != mysql + sqlite
 mysqlite == my sqlite bindings
 */

#scope_export

Db :: struct {
  inner: *sys.db,
}

open :: (path: string) -> success, Db {
  db: Db;
  result := sqlite3_open(temp_c_string(path), *db.inner);
  if result != SQLITE_OK {
    log_error_msg(*db);
    return false, result;
  }
  result = sqlite3_extended_result_codes(*db.inner, 1);
  if result != SQLITE_OK {
    log_error_msg(*db);
    return false, result;
  }
  return true, db;
}

``

close :: (db: *Db) -> {
}


#scope_file

#import,file "sys/linux.jai";

log_error_msg :: (db: *Db) {
  msg := from_c_string(sqlite3_errmsg(*db.inner));
  print("ERROR::mysqlite : %\n", msg);
}

bail :: () #expand {
  if result != SQLITE_OK {
    msg := from_c_string(sqlite3_errmsg(*db.inner));
    print("ERROR::mysqlite : %\n", msg);
    return false;
  }
}
