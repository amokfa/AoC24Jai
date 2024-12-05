#import "STL";
using Basic :: #import "Basic";
#import "String";
P1 :: #import,file "./part1.jai";


main :: () {
  processing_pairs := true;
  sequences: [..][..] int;
  orderings: [..] P1.Pair;
  for Spliterator.{source=INPUT} {
    if it.count == 0 {
      processing_pairs = false;
      continue;
    }
    if processing_pairs {
      pair: StackRArr(2, int);
      for Spliterator.{source=it, split_at=cast(u8) #char "|"} {
        array_add(*pair, parse_int(*it));
      }
      panic(pair.count == 2, "not enough elements in line: %", it);
      array_add(*orderings, .{pair.data[0], pair.data[1]});
    } else {
      sequence: [..]int;
      for Spliterator.{source=it, split_at=cast(u8) #char ","} {
        array_add(*sequence, parse_int(*it));
      }
      array_add(*sequences, sequence);
    }
  }
  result := 0;
  for sequence: sequences {
    ok := true;
    for idx: 0..sequence.count-2 {
      curr := sequence[idx];
      next := sequence[idx+1];
      if !array_find(orderings, .{curr, next}) {
        ok = false;
        break;
      }
    }
    if !ok {
      while true {
        did_swap := false;
        for idx: 0..sequence.count-2 {
          curr := sequence[idx];
          next := sequence[idx+1];
          if !array_find(orderings, .{curr, next}) {
            sequence[idx] = next;
            sequence[idx+1] = curr;
            did_swap = true;
          }
        }
        if !did_swap {
          result += sequence[sequence.count/2];
          break;
        }
      }
    }
  }
  dbg(result);
}
