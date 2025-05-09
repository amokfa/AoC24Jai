
main :: () {
  r1 := open("/home/sagartiwari/src/dotfiles/finances.db");
  assert(r1.tag == .Ok);
  db := r1.data.ok;
  r2 := prepare(db, "SELECT id FROM tags WHERE name like ?");
  if r2.tag != .Ok dbg(r2.data.err);
  assert(r2.tag == .Ok);
  stmt := r2.data.ok;
  r3 := bind(stmt, 1, "groceries");
  assert(r3.tag == .Ok);
  while true {
    r4 := step(stmt);
    if r4.tag == {
      case .Done; break;
      case .Row;
        print("id = %\n", column(stmt, 0, int));
      case .Busy;
      case .Err;
        print("error = %\n", r4.data.Err);
    }
  }
}

#import,file "./module.jai";
#import "Print_Vars";
#import "Basic";
#import "Math";
#import "STL";