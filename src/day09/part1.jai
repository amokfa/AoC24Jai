#import "STL";
#import "Basic";

main :: () {
  buf_size := 0;
  for INPUT {
    buf_size += it - char("0");
  }
  dbg(buf_size);
  input: [..] u8;
  array_reserve(*input, buf_size);
  for 0..(INPUT.count / 2) {
    for 1..(INPUT.data[2*it] - char("0")) {
      array_add(*input, xx it);
    }
    for 1..(INPUT.data[2*it+1] - char("0")) {
      array_add(*input, 0);
    }
  }
  dbg(input);
}
