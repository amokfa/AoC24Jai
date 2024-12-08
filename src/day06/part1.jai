#import "STL";
#import "Basic";
#import "String";

main :: () {
  grid: [..][] u8;
  width: int;
  for Spliterator.{source=copy_string(INPUT), skip_empty=true} {
    if width == 0 {
      width = it.count;;
    }
    panic(width == it.count, "non uniform grid");
    array_add(*grid, cast([]u8) it);
  }

  pos_y, pos_x, dir := find_guard(grid);
  grid[pos_y][pos_x] = char("X");
  while true {
    finished, end_y, end_x, end_dir := move_guard_until_turn(grid, pos_y, pos_x, dir);
    if finished {
      break;
    }
    pos_y = end_y;
    pos_x = end_x;
    dir = end_dir;
  }
  
  result := 0;
  for grid {
    for it {
      if it == char("X") {
        result += 1;
      }
    }
  }
  dbg(result);
}

Direction :: enum {
  Up;
  Right;
  Down;
  Left;
}

turn :: (d: Direction) -> Direction {
  return cast(Direction) (cast(u8) d + 1)%4;
}

delta :: (d: Direction) -> int, int {
  if d == {
    case .Up;
      return -1, 0;
    case .Down;
      return 1, 0;
    case .Left;
      return 0, -1;
    case .Right;
      return 0, 1;
  }
  panic(false, "Direction: %", d);
  return -1, -1;
}

move_guard_until_turn :: (grid: [..][]u8, start_y: int, start_x: int, direction: Direction) -> finished: bool, end_y: int, end_x: int, dir: Direction {
  curr_y, curr_x, curr_dir := start_y, start_x, direction;
  while true {
    finished, next_y, next_x, next_dir := move_guard(grid, curr_y, curr_x, curr_dir);
    if finished {
      return finished, next_y, next_x, next_dir;
    }
    if next_dir != curr_dir {
      return false, next_y, next_x, next_dir;
    }
    curr_y, curr_x = next_y, next_x;
  }
}

move_guard :: (grid: [..][]u8, start_y: int, start_x: int, direction: Direction) -> finished: bool, end_y: int, end_x: int, dir: Direction {
  del_y, del_x := delta(direction);
  next_y := start_y + del_y;
  next_x := start_x + del_x;
  if grid_get(grid, next_y, next_x) == {
    case #run char("#");
      return false, start_y, start_x, turn(direction);
    case 0;
      return true, -1, -1, .Up;
    case;
      grid[next_y][next_x] = #run char("X");
      return false, next_y, next_x, direction;

  }
  return true, -1, -1, .Up;
}

find_guard :: (grid: [..][]u8) -> int, int, Direction {
  for row, row_idx: grid {
    for cell, col_idx: row {
      idx := find_index_from_left("^>v<", cell);
      if idx != -1 {
        return row_idx, col_idx, cast(Direction) idx;
      }
    }
  }
  panic(false, "boo");
  return -1, -1, .Up;
}
