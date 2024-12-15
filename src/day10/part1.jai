#import "STL";
#import "Basic";
#import "Hash_Table";

main :: () {
  input := parse_grid(INPUT);
  result := 0;
  found_trailheads: Table(u64, bool);
  init(*found_trailheads);
  find_trailheads(input, 0, 2, *found_trailheads);
  for row, row_idx: input {
    for cell, col_idx: row {
      if cell == char("0") {
        table_reset(*found_trailheads);
        find_trailheads(input, row_idx, col_idx, *found_trailheads);
        result += found_trailheads.count;
      }
    }
  }
  dbg(result);
}

find_trailheads :: (grid: [][]u8, row: int, col: int, found: *Table(u64, bool)) {
  curr := grid_get(grid, row, col);
  if curr == char("9") {
    table_set(found, nums_to_key(xx row, xx col), true);
  } else {
    if grid_get(grid, row-1, col) == curr+1 {
      find_trailheads(grid, row-1, col, found);
    }
    if grid_get(grid, row+1, col) == curr+1 {
      find_trailheads(grid, row+1, col, found);
    }
    if grid_get(grid, row, col-1) == curr+1 {
      find_trailheads(grid, row, col-1, found);
    }
    if grid_get(grid, row, col+1) == curr+1 {
      find_trailheads(grid, row, col+1, found);
    }
  }
}

nums_to_key :: (a: u32, b: u32) -> u64 {
  return (cast(u64) (cast(u32) a)) | ((cast(u64) (cast(u32) b)) << 32);
}
