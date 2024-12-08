#import "STL";
#import "String";

main :: () {
  processing_pairs := true;
  orderings: [..] Pair;
  sequences: [..][..] int;
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
    if ok {
      result += sequence[sequence.count/2];
    }
  }
  dbg(result);
}