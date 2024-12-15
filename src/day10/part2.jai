#import "STL";
#import "Basic";
#import "Hash_Table";

main :: () {
  input := parse_grid(INPUT);
  result := 0;
  found_trails: Table(u32, bool);
  init(*found_trails);
  for row, row_idx: input {
    for cell, col_idx: row {
      if cell == char("0") {
        table_reset(*found_trails);
        arr: [..]Pair;
        find_trailheads(input, row_idx, col_idx, arr, *found_trails);
        result += found_trails.count;
      }
    }
  }
  dbg(result);
}

find_trailheads :: (grid: [][]u8, row: int, col: int, trail: [..]Pair, found: *Table(u32, bool)) {
  array_add(*trail, .{row, col});
  curr := grid_get(grid, row, col);
  if curr == char("9") {
    #import "Hash";
    table_set(found, get_hash(trail), true);
  } else {
    if grid_get(grid, row-1, col) == curr+1 {
      find_trailheads(grid, row-1, col, marray_copy(trail), found);
    }
    if grid_get(grid, row+1, col) == curr+1 {
      find_trailheads(grid, row+1, col, marray_copy(trail), found);
    }
    if grid_get(grid, row, col-1) == curr+1 {
      find_trailheads(grid, row, col-1, marray_copy(trail), found);
    }
    if grid_get(grid, row, col+1) == curr+1 {
      find_trailheads(grid, row, col+1, marray_copy(trail), found);
    }
  }
}

hash :: (value: $T) -> u64 {
  return fnv1a_hash(*value, size_of(T));
}

nums_to_key :: (a: u32, b: u32) -> u64 {
  return (cast(u64) (cast(u32) a)) | ((cast(u64) (cast(u32) b)) << 32);
}

marray_copy :: (arr: [] $T) -> [..]T {
  result: [..]T;
  array_copy(*result, arr);
  return result;
}
