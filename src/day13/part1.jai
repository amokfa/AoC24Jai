
main :: () {
  result := 0;
  for cfg: parse_input(INPUT) {
    result += optimize(cfg);
  }
  dbg(result);
}

optimize :: (cfg: Cfg) -> int {
  a := (cfg.bb.b * cfg.prize.a
        - cfg.bb.a * cfg.prize.b)
       / (cfg.ba.a * cfg.bb.b
          - cfg.ba.b * cfg.bb.a);

  b := (cfg.prize.a - cfg.ba.a * a) / cfg.bb.a;

  if a <= 0
      || b <= 0
      || cfg.prize != cfg.ba * a + cfg.bb * b
  {
      return 0;
  }
  else {
      return 3 * a + b;
  }
}

parse_input :: (input: string) -> [..] Cfg {
  result: [..] Cfg;
  pa: Pair;
  pb: Pair;
  pc: Pair;
  for Spliterator.{source=input, split_at=char("\n"), skip_empty=true} {
    if it_index % 3 == {
      case 0;
        n1, _ok, left := string_to_int(subs(it, 12, it.count));
        n2 := string_to_int(subs(left, 4, left.count));
        pa = .{n1, n2};
      case 1;
        n1, _ok, left := string_to_int(subs(it, 12, it.count));
        n2 := string_to_int(subs(left, 4, left.count));
        pb = .{n1, n2};
      case 2;
        n1, _ok, left := string_to_int(subs(it, 9, it.count));
        n2 := string_to_int(subs(left, 4, left.count));
        pc = .{n1, n2};
    }
    if it_index % 3 == 2 {
      array_add(*result, .{pa, pb, pc});
    }
  }
  return result;
}

Cfg :: struct {
  ba: Pair;
  bb: Pair;
  prize: Pair;
}

#import "Basic";
#import "STL";
#import "Print_Vars";
