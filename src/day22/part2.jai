main :: () {
  inits := P1.parse(INPUT);
  seq_to_value: Table(int, int);
  for idx: Range.{0, inits.count} {
    secrets: [2001] int;
    occurances: [..] int;
    del_1, del_2, del_3, del_4: int = 0;
    secrets[0] = inits[idx];
    for s_idx: Range.{0, 2000} {
      secrets[s_idx+1] = P1.get_next(secrets[s_idx]);
      del_1 = del_2;
      del_2 = del_3;
      del_3 = del_4;
      del_4 = secrets[s_idx+1]%10 - secrets[s_idx]%10;
      s: struct { a, b, c, d: int; } = .{del_1, del_2, del_3, del_4};
      sequence := get_hash(s);
      if s_idx > 2 {
        if !array_find(occurances, sequence) {
          ptr, is_new := find_or_add(*seq_to_value, sequence);
          if is_new ptr.* = 0;
          ptr.* += secrets[s_idx+1]%10;
          array_add(*occurances, sequence);
        }
      }
    }
  }

  max := 0;
  for value, seq: *seq_to_value {
    if value > max max = value;
  }
  dbg(max);
}

P1 :: #import,file "part1.jai";
#import "Hash_Table";
#import "STL";
#import "Basic";