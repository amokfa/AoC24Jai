#import "STL";
#import "Basic";
#import "String";
#import "File";
P1 :: #import,file "part1.jai";

main :: () {
  input := P1.parse_input(INPUT);
  ids: [..]u16;
  for 0..input.count/2-1 {
    array_add(*ids, xx it);
  }
  curr_file := input.count - 2;

  while curr_file > 0 {
    curr_hole := 1;
    while curr_hole < curr_file {
      file_size := input[curr_file];
      hole_size := input[curr_hole];
      if hole_size >= file_size {
        println("putting file % in hole %", curr_file, curr_hole);
        // remove curr_file
        file_hole := input[curr_file+1];
        array_ordered_remove_by_index(*input, curr_file);
        // merge surrounding holes
        array_ordered_remove_by_index(*input, curr_file);
        input[curr_file-1] += file_hole;
        input[curr_file-1] += file_size;
        // reduce the hole size
        input[curr_hole] -= file_size;
        // put file in hole
        array_insert_at(*input, file_size, curr_hole);
        // put an empty hole before file
        array_insert_at(*input, 0, curr_hole);

        // move id to right place
        start_id_idx := curr_file / 2;
        start_id := ids[start_id_idx];
        end_id_idx := (curr_hole + 1) / 2;
        array_ordered_remove_by_index(*ids, start_id_idx);
        array_insert_at(*ids, start_id, end_id_idx);
      }
      curr_hole += 2;
    }
    curr_file -= 2;
  }
  dbg(input);
  dbg(ids);

  buf_size := 0;
  for input buf_size += it;
  layout: [..]s16;
  array_reserve(*layout, buf_size);
  for 0..(input.count / 2) {
    for k: 1..(input.data[2*it]) {
      array_add(*layout, xx ids[it]);
    }
    for k: 1..(input.data[2*it+1]) {
      array_add(*layout, -1);
    }
  }
  dbg(layout);

  dbg(P1.calculate_checksum(layout));
}

