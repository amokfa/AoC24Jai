DEL :: 10000000000000;

main :: () {
  result := 0;
  for * cfg: P1.parse_input(INPUT) {
    (<<cfg).prize = (<<cfg).prize + Pair.{DEL, DEL};
    result += P1.optimize(cfg);
  }
  dbg(result);
}

P1 :: #import,file "./part1.jai";
#import "Basic";
#import "STL";
#import "Print_Vars";
