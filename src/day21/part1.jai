
main :: () {
  codes := parse(INPUT);
  grid1_paths := get_possible_paths(GRID1);
  grid2_paths := get_possible_paths(GRID2);
  result := 0;
  for code: codes {
    minmom := 99999999;
    e1s: [..] string; defer array_free(e1s);
    expand(*grid1_paths, char("A"), code, "", *e1s);
    for e1: e1s {
      e2s: [..] string; defer array_free(e2s);
      expand(*grid2_paths, char("A"), e1, "", *e2s);
      for e2: e2s {
        e3s: [..] string; defer array_free(e3s);
        expand(*grid2_paths, char("A"), e2, "", *e3s);
        for e3: e3s {
          if e3.count < minmom minmom = e3.count;
        }
      }
    }
    prod := string_to_int(subs(code, 0, 3)) * minmom;
    result += prod;
  }
  dbg(result);
}

expand :: (paths: *Table(SE, [..] string), curr_char: u8, code: string, prefix: string, result: *[..] string) {
  if code.count < 1 {
    it: [..]u8;
    array_copy(*it, cast([]u8, prefix));
    its: string; its.data = it.data; its.count = it.count;
    array_add(result, its);
    return;
  };
  new_prefix: [..] u8;
  array_copy(*new_prefix, cast([]u8, prefix));
  for part: table_find(paths, .{curr_char, code[0]}) {
    for part array_add(*new_prefix, it);
    new_code := code;
    new_code.data += 1;
    new_code.count -= 1;
    new_prefix_s: string; new_prefix_s.data = new_prefix.data; new_prefix_s.count = new_prefix.count;
    expand(paths, code[0], new_code, new_prefix_s, result);
    new_prefix.count -= part.count;
  }
}

del_r_paths :: #run () -> [3]u8 { return .[char("^"), 0, char("v")]; }();
del_c_paths :: #run () -> [3]u8 { return .[char("<"), 0, char(">")]; }();
SE :: struct { s, e: u8; }
get_possible_paths :: (grid: [$R][$C]u8) -> Table(SE, [..] string) {
  result: Table(SE, [..] string);
  for row, row1_idx: grid {
    for cell1, col1_idx: row {
      if cell1 == 0 continue;
      for row, row2_idx: grid {
        for cell2, col2_idx: row {
          if cell2 == 0 continue;
          paths: [..] string;
          del_r := row2_idx - row1_idx;
          del_c := col2_idx - col1_idx;
          r_char := del_r_paths[signum(del_r)+1];
          c_char := del_c_paths[signum(del_c)+1];
          prospects := get_combs(r_char, abs(del_r), c_char, abs(del_c));
          // print_vars(cell1, cell2, del_r, r_char, del_c, c_char, prospects);
          for path: prospects {
            ok := true;
            curr := Pair.{row1_idx, col1_idx};
            for instr: path {
              if instr == {
                case #run char("<"); curr = left(curr);
                case #run char(">"); curr = right(curr);
                case #run char("^"); curr = up(curr);
                case #run char("v"); curr = down(curr);
                case #run char("A"); ;
                case; assert(false, path);
              }
              if grid[curr.a][curr.b] == 0 {
                ok = false;
                break;
              }
            }
            if ok array_add(*paths, path);
          }
          table_set(*result, .{cell1, cell2}, paths);
        }
      }
    }
  }
  return result;
}

GRID1: [4][3]u8 : #run () -> [4][3]u8 {
  return .[.[char("7"), char("8"), char("9")],
           .[char("4"), char("5"), char("6")],
           .[char("1"), char("2"), char("3")],
           .[0        , char("0"), char("A")]];
}();
GRID2: [2][3]u8 : #run () -> [2][3]u8 {
  return .[.[0        , char("^"), char("A")],
           .[char("<"), char("v"), char(">")]];
}();

parse :: (s: string) -> [..] string {
  result: [..] string;
  for Spliterator.{ source=s, skip_empty=true } {
    array_add(*result, it);
  }
  return result;
}

get_combs :: (c1: u8, n1: int, c2: u8, n2: int) -> [..] string {
  result: [..] string;
  current: [..] u8;
  hilfer :: (c1: u8, n1: int, c2: u8, n2: int, current: *[..] u8, result: *[..] string) {
    if n1 == 0 && n2 == 0 {
      it: [..]u8;
      array_copy(*it, current.*);
      array_add(*it, char("A"));
      its: string;
      its.data = it.data;
      its.count = it.count;
      array_add(result, its);
      return;
    }
    if n1 > 0 && c1 != 0 {
      array_add(current, c1);
      hilfer(c1, n1-1, c2, n2, current, result);
      pop(current);
    }
    if n2 > 0 && c2 != 0 {
      array_add(current, c2);
      hilfer(c1, n1, c2, n2-1, current, result);
      pop(current);
    }
  }
  hilfer(c1, n1, c2, n2, *current, *result);
  return result;
}

#import "STL";
#import "Basic";
#import "Math";
#import "Hash_Table";
#import "Print_Vars";