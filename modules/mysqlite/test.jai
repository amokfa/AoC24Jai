
main :: () {
  r1 := open("/home/sagartiwari/src/dotfiles/finances.db");
  assert(r1.tag == .Ok);
  db := r1.data.Ok;
  result := exec_value(db, "SELECT name FROM tags WHERE id = ?", Any.[348], string);
  if result.tag != .Ok dbg(result.data.Err);
  dbg(result.data.Ok);
}

#import,file "./module.jai";
#import "Print_Vars";
#import "Basic";
#import "Math";
#import "STL";