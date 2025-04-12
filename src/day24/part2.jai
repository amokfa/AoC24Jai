
main :: () {
  _values, gates := P1.parse(INPUT);
  test_values: Table(string, int);
  table_set(*test_values, "x00", 1);
  table_set(*test_values, "y00", 1);
  P1.run_circuit(*test_values, gates);
  dbg(table_find(*test_values, "z00"));
}

P1 :: #import,file "part1.jai";
#import "Hash_Table";
#import "STL";