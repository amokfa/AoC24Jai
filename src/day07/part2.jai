#import "STL";
P1 :: #import,file "part1.jai";

main :: () {
  result := 0;
  for Spliterator.{source=INPUT, skip_empty=true} {
    lhs, rhs := P1.parse_expr(it);
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
    return is_solvable(lhs, rest, interm + next) || is_solvable(lhs, rest, interm * next) || is_solvable(lhs, rest, interm * pow(10, num_digs(next)) + next);
  }
}

