#import "STL";
#import "String";
#import "Math";
#import "Basic";

main :: () {
  result := 0;
  for Spliterator.{source=INPUT, skip_empty=true} {
    lhs, rhs := parse_expr(it);
    if valid(lhs, rhs) {
      result += lhs;
    }
  }
  dbg(result);
}

valid :: (lhs: int, rhs: []int) -> bool {
  for pattern: 0..pow(2, rhs.count)-1 {
    pattern_result := rhs[0];
    for idx: 1..rhs.count-1 {
      operation := pattern >> idx & 1;
      if operation == 0 {
        pattern_result += rhs[idx];
      } else {
        pattern_result *= rhs[idx];
      }
    }
    if pattern_result == lhs {
      return true;
    }
  }
  return false;
}

parse_expr :: (line: string) -> int, [..] int {
  colon := find_index_from_left(line, ":");
  panic(colon != -1, "there must be a colon");
  num_part := subs(line, 0, colon);
  lhs, success := string_to_int(num_part);
  panic(success, "invalid num: %", num_part);
  parts: [..] int;
  for Spliterator.{source=subs(line, colon+1, line.count), split_at=char(" "), skip_empty=true} {
    res, success := string_to_int(it);
    panic(success, "invalid num: %", it);
    array_add(*parts, res);
  }
  return lhs, parts;
}
