main :: () {
  locks, keys := parse_input(INPUT);
  result := 0;
  for lock: locks {
    for key: keys {
      if fit(key, lock) {
        result += 1;
      }
    }
  }
  dbg(result);
}

fit :: (lock: HInfo, key: HInfo) -> bool {
  for idx: Range.{0, 5} {
    if lock[idx] + key[idx] > 5 {
      return false;
    }
  }
  return true;
}

parse_input :: (input: string) -> locks: [..] HInfo, keys: [..] HInfo {
  all_locks, all_keys: [..] HInfo;
  curr_lock, curr_key: HInfo;
  using enum { Lock; Key; Nothing; };
  parsing_rn := Nothing;
  for line: Spliterator.{source=input, split_at=char("\n"), skip_empty=false} {
    if line.count == 0 {
      if parsing_rn == {
        case Lock;
          array_add(*all_locks, curr_lock);
          curr_lock = MT;
        case Key;
          for * curr_key
            it.* -= 1;
          array_add(*all_keys, curr_key);
          curr_key = MT;
      }
      parsing_rn = Nothing;
      continue;
    }
    if parsing_rn == {
      case Nothing;
        if line[0] == char("#") {
          parsing_rn = Lock;
        } else if line[0] == char(".") {
          parsing_rn = Key;
        } else {
          panic(false, "boo");
        }
      case Lock;
        for Range.{0, 5} {
          if line[it] == {
            case #run char("#"); curr_lock[it] += 1;
            case #run char("."); ;
            case; panic(false, "boo");
          }
        }
      case Key;
        for Range.{0, 5} {
          if line[it] == {
            case #run char("#"); curr_key[it] += 1;
            case #run char("."); ;
            case; panic(false, "boo");
          }
        }
    }
  }
  return all_locks, all_keys;
}

HInfo :: [5]u8;
MT :: u8.[0, 0, 0, 0, 0];

#import "STL";
#import "Basic";
