main :: () {
  grid, moves, bot := parse(INPUT);
  for moves {
    move_bot(*grid, *bot, it);
  }
  sum := 0;
  for line, y: grid {
    for block, x: line {
      if block == char("O") {
        sum += 100 * y + x;
      }
    }
  }
  dbg(sum);
}

move_bot :: (grid: *[..][] u8, bot: *Pair, move: u8) {
  delta: Pair;
  if move == {
    case #run char("^"); delta = .{-1, 0};
    case #run char("v"); delta = .{1, 0};
    case #run char("<"); delta = .{0, -1};
    case #run char(">"); delta = .{0, 1};
    case; assert(false);
  }
  start := bot.*;
  curr := start;
  size := Pair.{grid[0].count, grid.count};
  while true {
    if !in_bounds(curr, size) return;
    if grid_get(grid.*, curr) == char("#") return;
    curr += delta;
    if grid_get(grid.*, curr) == char(".") break;
  }

  while curr != start {
    next := curr-delta;
    grid_set(grid.*, curr.a, curr.b, grid_get(grid.*, next));
    curr = next;
  }
  grid_set(grid.*, start.a, start.b, char("."));
  bot.* += delta;
}

parse :: (input: string) -> grid: [..][] u8, moves: [..] u8, bot: Pair {
  parsing_grid := true;
  bot: Pair;
  grid: [..][] u8;
  moves: [..] u8;
  for line, bot_y: Spliterator.{source=input, split_at=char("\n"), skip_empty=false} {
    if parsing_grid {
      if line.count == 0 {
        parsing_grid = false;
        continue;
      }
      bot_x := find_index_from_left(line, "@");
      if bot_x != -1 {
        bot = .{bot_x, bot_y};
      }
      array_add(*grid, cast([]u8) sprint(line));
    } else {
      for line {
        array_add(*moves, it);
      }
    }
  }
  return grid, moves, bot;
}

in_bounds :: (p: Pair, size: Pair) -> bool {
  return p.a >= 0 && p.b >= 0 && p.a < size.a && p.b < size.b;
}

#import "Basic";
#import "String";
#import "STL";
