#import "STL";
#import "Basic";
#import "Hash_Table";

main :: () {
  counts: Table(int, int);
  init(*counts);
  for parse_line(INPUT) {
    add(*counts, it, 1);
  }
  for 1..75 {
    for v, k: copy(*counts) {
      if k == 0 {
        add(*counts, 1, v);
        sub(*counts, 0, v);
      } else {
        len := num_digs(k);
        if len % 2 == 0 {
          pt := pow(10, len/2);
          add(*counts, k/pt, v);
          add(*counts, k%pt, v);
        } else {
          add(*counts, k*2024, v);
        }
        sub(*counts, k, v);
      }
    }
  }
  result := 0;
  for counts {
    result += it;
  }
  dbg(result);
}

add :: (counts: *Table(int, int), k: int, v: int) {
  pv := find_or_add(counts, k);
  <<pv += v;
}

sub :: (counts: *Table(int, int), k: int, v: int) {
  pv := find_or_add(counts, k);
  <<pv -= v;
}

copy :: (table: *Table(int, int)) -> Table(int, int) {
  result: Table(int, int);
  init(*result);
  for v, k: table {
    table_set(*result, k, v);
  }
  return result;
}
