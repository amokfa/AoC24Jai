
main :: () {
  inits := parse(INPUT);
  for idx: Range.{0, inits.count} {
    for Range.{0, 2000} {
      inits[idx] = get_next(inits[idx]);
    }
  }
  sum := 0;
  for inits sum += it;
  dbg(sum);
}

get_next :: (n: int) -> int {
  secret := n;
  secret = mix(secret, secret << 6);
  secret = prune(secret);

  secret = mix(secret, secret >> 5);
  secret = prune(secret);

  secret = mix(secret, secret << 11);
  secret = prune(secret);

  return secret;
}

mix :: (a: int, b: int) -> int {
  return a ^ b;
}

prune :: (a: int) -> int {
  return a % 16777216;
}

parse :: (s: string) -> [..] int {
  result: [..] int;
  for Spliterator.{ source=s, skip_empty=true } {
    n, ok := string_to_int(it);
    assert(ok, it);
    array_add(*result, n);
  }
  return result;
}

#import "Basic";
#import "STL";
#import "Print_Vars";