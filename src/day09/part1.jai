#import "STL";
#import "Basic";
#import "String";
#import "File";

main :: () {
  input := parse_input(INPUT);
  layout := generate_layout(input);

  empty_slot := 0;
  occupied_slot := layout.count - 1;

  while true {
    while layout[empty_slot] != -1 empty_slot += 1;
    while layout[occupied_slot] == -1 occupied_slot -= 1;
    if empty_slot > occupied_slot break;
    layout[empty_slot], layout[occupied_slot] = layout[occupied_slot], layout[empty_slot];
  }

  dbg(calculate_checksum(layout));

}

parse_input :: (INPUT: string) -> [..]u8 {
  input: [..]u8;
  array_reserve(*input, INPUT.count+1);
  for trim(INPUT) {
    array_add(*input, xx it - char("0"));
  }
  if input.count % 2 != 0 {
    array_add(*input, 0);
  }
  return input;
}

generate_layout :: (input: []u8) -> [..] s16 {
  buf_size := 0;
  for input buf_size += it;
  layout: [..] s16;
  array_reserve(*layout, buf_size);
  id := 0;
  for 0..(input.count / 2) {
    for 1..(input.data[2*it]) {
      array_add(*layout, xx id);
    }
    for 1..(input.data[2*it+1]) {
      array_add(*layout, -1);
    }
    id += 1;
  }
  return layout;
}

calculate_checksum :: (layout: []s16) -> int {
  result := 0;

  for layout {
    if it == -1 {
      continue;
    }
    result += it * it_index;
  }

  return result;
}
