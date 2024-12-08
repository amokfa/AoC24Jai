#import "STL";
#import "Basic";
#import "POSIX";
P1 :: #import,file "part1.jai";

main2 :: () {
  dbg(loops(8, 3));
}

main :: () {
  result := 0;
  grid := P1.parse_input(INPUT);
  for row, row_idx: grid {
    for cell, col_idx: row {
      if cell == #run char(".") {
        if loops(row_idx, col_idx) {
          result += 1;
        }
      }
    }
  }
  dbg(result);
}

GuardState :: struct {y: int; x: int; dir: P1.Direction;}

loops :: (row_idx: int, col_idx: int) -> bool {
  grid := P1.parse_input(INPUT);
  grid[row_idx][col_idx] = #run char("#");
  m0y, m0x, dir := P1.find_guard(grid);
  grid[m0y][m0x] = char("X");

  past_states: [..] GuardState;
  array_add(*past_states, .{m0y, m0x, dir});
  while true {
    finished, next_y, next_x, next_dir := P1.move_guard_until_turn(grid, m0y, m0x, dir);
    if finished {
      return false;
    }
    for past_states {
      if it.y == next_y && it.x == next_x && it.dir == next_dir {
        return true;
      }
    }
    m0x, m0y = next_x, next_y;
    dir = next_dir;
    array_add(*past_states, .{m0y, m0x, dir});
  }
  return false;
}
