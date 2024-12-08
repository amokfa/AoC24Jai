#import "STL";
P1 :: #import,file "part1.jai";

main :: () {
  result := 0;
  for Spliterator.{source=INPUT, skip_empty=true} {
    lhs, rhs := P1.parse_expr(it);
    if valid(lhs, rhs) {
      result += lhs;
    }
  }
  dbg(result);
}

Op :: enum {
  Add;
  Mul;
  Cat;
}

from_int :: (i: int) -> Op {
  return cast(Op) (i % 3);
}

valid :: (lhs: int, rhs: [] int) -> bool {
  num_patterns := pow(3, rhs.count);
  for p_idx: 0..num_patterns-1 {
    acc := rhs[0];
    for 1..rhs.count-1 {
      if gen_op(p_idx, it-1) == {
        case .Add; acc += rhs[it];
        case .Mul; acc *= rhs[it];
        case .Cat; acc = acc * pow(10, num_digs(rhs[it])) + rhs[it];
      }
    }
    if acc == lhs {
      return true;
    }
  }
  return false;
}

gen_op :: (p_idx: int, op_idx: int) -> Op {
  divider := pow(3, op_idx);
  remdr := (p_idx / divider) % 3;
  return from_int(remdr);
}

num_digs :: (n: int) -> int {
  result := 1;
  while true {
    if n < 10 {
      break;
    }
    n /= 10;
  }
  return result;
}
