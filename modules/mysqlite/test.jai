
main :: () {
  out: *SQ.sqlite3;
  result := SQ.sqlite3_open("t.db", *out);
  print_vars(result, out);
}

SQ :: #import,file "./sqlite3.jai";
#import "Print_Vars";