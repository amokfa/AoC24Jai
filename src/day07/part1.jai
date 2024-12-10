#import "STL";
#import "String";
#import "Math";
#import "Basic";

main :: () {
  result := 0;
  for Spliterator.{source=INPUT, skip_empty=true} {
    lhs, rhs := parse_expr(it);
    if is_solvable(lhs, rhs, 0) {
      result += lhs;
    }
  }
  dbg(result);
}

is_solvable :: (lhs: int, rhs: [] int, interm: int) -> bool {
  if rhs.count == 0 {
    return lhs == interm;
  } else {
    next := rhs[0];
    rest := rhs; rest.count -= 1; rest.data += 1;
    return is_solvable(lhs, rest, interm + next) || is_solvable(lhs, rest, interm * next);
  }
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
