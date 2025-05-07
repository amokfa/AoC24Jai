
main :: () {
  codes := P1.parse(INPUT);
  grid1_paths := P1.get_possible_paths(GRID1);
  grid2_paths := P1.get_possible_paths(GRID2);
  grid2_cache: Table(CacheKey, string);
  result := 0;
  for code: codes {
    minmom := 99999999;
    e1s: [..] string;
    defer {
      array_free(e1s);
    };
    P1.expand(*grid1_paths, char("A"), code, "", *e1s);
    for e1: e1s {
      e2s: [..] string;
      defer {
        array_free(e2s);
      };
      expand(*grid2_paths, char("A"), e1, "", *e2s, *grid2_cache);
      for e2: e2s {
        e3s: [..] string;
        defer {
          array_free(e3s);
        };
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

CacheKey :: struct { start, end, depth: u8; }

expand :: (paths: *Table(SE, [..] string), curr_char: u8, code: string, prefix: string, depth: u8, cache: *Table(CacheKey, string)) -> string {
  ck := CacheKey.{curr_char, code[0], depth};
  value, found := table_find(cache, ck);
  if found {
    return value;
  }

  if code.count < 1 {}

  table_set(cache, ck, result);
  return result;

  if code.count < 1 {
    it: [..]u8;
    array_copy(*it, cast([]u8, prefix));
    its: string; its.data = it.data; its.count = it.count;
    array_add(result, its);
    table_set();
    return;
  };
  new_prefix: [..] u8; defer array_free(new_prefix);
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

expand_inner :: (paths: *Table(SE, [..] string), curr_char: u8, code: string, prefix: string, result: *[..] string) {
  if code.count < 1 {
    it: [..]u8;
    array_copy(*it, cast([]u8, prefix));
    its: string; its.data = it.data; its.count = it.count;
    array_add(result, its);
    return;
  };
  new_prefix: [..] u8; defer array_free(new_prefix);
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

P1 :: #import,file "part1.jai";
#import "STL";
#import "Basic";