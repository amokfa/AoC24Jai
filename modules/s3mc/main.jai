
main :: () {
  dbr := DB.open("/home/sagartiwari/src/dotfies/finances.db");
  if dbr.tag == .Err {
    print("couldn't open database: %\n", dbr.data.Err);
    return;
  }
  db := dbr.data.Ok;
  er := DB.exec(db, "SELECT 1");
  if er.tag == .Err {
    print("exec error: %\n", er.data.Err);
  } else {
    print("ok");
  }
}

#scope_file

#import "Basic";
#import "Print_Vars";
DB :: #import,file "module.jai";
