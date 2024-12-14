#import "Basic";
#import "STL";
#import "Hash_Table";
P1 :: #import,file "part1.jai";

main :: () {
  input, R, C := P1.parse_input(INPUT);

  result := 0;
  for r: 0..R-1 {
    for c: 0..C-1 {
      loc := Pair.{r, c};
      for locs: input {
        b2 := false;
        for loc1: suba(locs, 0, locs.count) {
          b := false;
          for loc2: suba(locs, it_index+1, locs.count) {
            if are_in_line(loc1, loc, loc2) {
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

are_in_line :: (p1: Pair, p: Pair, p2: Pair) -> bool {
  d1 := p1 - p;
  d2 := p2 - p;
  if dot(d1, d2) < 0 {
    d1 *= -1;
  }
  if len2(d1) > len2(d2) {
    d1, d2 = d2, d1;
  }
  return d1.a * d2.b == d1.b * d2.a;
}
