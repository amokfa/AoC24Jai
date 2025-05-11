
main :: () {
  r1 := open("/home/sagartiwari/src/dotfiles/finances.db");
  assert(r1.tag == .Ok);
  db := r1.data.Ok;
  query := "SELECT id, name FROM tags ORDER BY id DESC LIMIT 20";

  q := Query(struct {id: int; name: string;}).{db, query, .[]};
  it := exec(db, query, .[], struct{id: int; name: string;});
  if it.tag == {
    case .Ok; dbg(it.data.Ok);
    case .Err; println("ERROR: %", it.data.Err); return;
  }
  dbg("this prints");
}

m2 :: () {
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