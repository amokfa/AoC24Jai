
main :: () {
  ap, rp := parse(INPUT);
  result := 0;
  for pattern: rp {
    if is_valid(pattern, ap) {
      result += 1;
    }
  }
  print_vars(result);
}

is_valid :: (pattern: string, available_patterns: [] string) -> bool {
  for part: available_patterns {
    if pattern.count >= part.count && subs(pattern, 0, part.count) == part {
      left := subs(pattern, part.count);
      if left.count == 0 {
        return true;
      } else {
        if is_valid(left, available_patterns) {
          return true;
        }
      }
    }
  }
  return false;
}

parse :: (s: string) -> [..] string, [..] string {
  state: enum { PART1; PART2; } = .PART1;
  available_patterns: [..] string;
  required_patterns: [..] string;
  for Spliterator.{ source=s, split_at=#char "\n", skip_empty=false } {
    if trim(it).count == 0 {
      state = .PART2;
    } else if state == .PART1 {
      for Spliterator.{source=it, split_at=#char ",", skip_empty=true} {
        array_add(*available_patterns, trim(it));
      }
    } else if state == .PART2 {
      array_add(*required_patterns, trim(it));
    }
  }
  return available_patterns, required_patterns;
}

#import "STL";
#import "String";
#import "Basic";
#import "Print_Vars";