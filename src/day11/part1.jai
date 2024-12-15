#import "STL";
#import "Basic";

main :: () {
  arr := parse_line(INPUT);
  for 1..25 {
    narr: [..]int;
    array_reserve(*narr, arr.count * 2);
    for arr {
      if it == 0 {
        array_add(*narr, 1);
      } else {
        len := num_digs(it);
        if len % 2 == 0 {
          pt := pow(10, len/2);
          array_add(*narr, it / pt);
          array_add(*narr, it % pt);
        } else {
          array_add(*narr, it * 2024);
        }
      }
    }
    array_free(arr);
    arr = narr;
  }
  dbg(arr.count);
}
