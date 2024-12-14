#import "Basic";
#import "STL";
#import "Hash_Table";


main :: () {
  input, R, C := parse_input(INPUT);

  result := 0;
  for r: 0..R-1 {
    for c: 0..C-1 {
      loc := Pair.{r, c};
      for locs: input {
        b2 := false;
        for loc1: suba(locs, 0, locs.count) {
          b := false;
          for loc2: suba(locs, it_index+1, locs.count) {
            del1 := loc1 - loc;
            del2 := loc2 - loc;
            if del1 * 2 == del2 || del2 * 2 == del1 || del1 * -2 == del2 || del2 * -2 == del1 {
              result += 1;
              b = true;
              break;
            }
          }
          if b {
            b2 = true;
            break;
          }
        }
        if b2 {
          break;
        }
      }
    }
  }
  dbg(result);
}

parse_input :: (INPUT: string) -> Table(u8, [..]Pair), int, int {
  result: Table(u8, [..]Pair);
  init(*result);
  row_count := 0;
  col_count := 0;
  for row, row_idx: Spliterator.{source=INPUT, split_at=char("\n"), skip_empty=true} {
    row_count = row_idx+1;
    col_count = row.count;
    for col, col_idx: row {
      if col != char(".") {
        if ! table_contains(*result, col) {
          list: [..]Pair;
          table_set(*result, col, list);
        }
        list := table_find_pointer(*result, col);
        array_add(list, .{row_idx, col_idx});
      }
    }
  }
  return result, row_count, col_count;
}
