
main :: () {
  result := 0;
  for cfg: parse_input(INPUT) {
    result += optimize(cfg);
  }
  dbg(result);
}

optimize :: (cfg: Cfg) -> int {
  result := s64_MAX;

  a_max := cfg.prize.a / cfg.ba.a;
  for a_count: 0..a_max {
    leftover := cfg.prize - cfg.ba * a_count;
    if leftover.a % cfg.bb.a == 0 && leftover.b % cfg.bb.b == 0
      && leftover.a / cfg.bb.a == leftover.b / cfg.bb.b {
      b_count := leftover.a / cfg.bb.a;
      tokens := a_count * 3 + b_count;
      if tokens < result && tokens > 0 {
        result = tokens;
      }
    }
  }

  return ifx result == s64_MAX 0 else result;
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
