
main :: () {
  ap, rp := P1.parse(INPUT);
  count := 0;
  count_cache: Table(string, int);
  for pattern: rp {
    count += do_it(pattern, ap, *count_cache);
  }
  dbg(count);
}

do_it :: (pattern: string, available_patterns: [] string, result_cache: *Table(string, int)) -> int {
  result, found := table_find(result_cache, pattern);
  if found return result;

  count := 0;
  if pattern.count == 0 return 1;
  for part: available_patterns {
    if pattern.count >= part.count && subs(pattern, 0, part.count) == part {
      left := subs(pattern, part.count);
      count += do_it(left, available_patterns, result_cache);
    }
  }
  table_set(result_cache, pattern, count);
  return count;
}

ts :: (arr: [] int) -> string {
  result: String_Builder;
  for arr {
    append(*result, tprint("%", it));
    if it_index != arr.count-1 {
      append(*result, ",");
    }
  }
  return builder_to_string(*result);
}

operator == :: (a: [..]int, b: [..]int) -> bool {
  if a.count != b.count return false;
  for idx: Range.{0, a.count} {
    if a[idx] != b[idx] return false;
  }
  return true;
}
#poke_name (#import "Basic") operator==;
#poke_name (#import "Hash_Table") operator==;

P1 :: #import,file "part1.jai";
#import "Hash_Table";
#import "STL";
#import "Basic";
#import "Hash";