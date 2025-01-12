
main :: () {
  grid, moves, bot := parse(INPUT);
  dbg(bot);
  print(grid);
  for move: moves {
    delta: Pair;
    if move == {
      case #run char("^"); delta = .{-1, 0};
      case #run char("v"); delta = .{1, 0};
      case #run char("<"); delta = .{0, -1};
      case #run char(">"); delta = .{0, 1};
      case; assert(false);
    }
    next_bot_pos := bot + delta;
    next_pos_state := grid_get(grid, next_bot_pos);
    if next_pos_state == {
      case #char ".";
        bot = next_bot_pos;
      case #char "["; #through;
      case #char "]";
        if check_obstacle(*grid, next_bot_pos, delta) {
          move_boxes(*grid, next_bot_pos, delta);
          bot = next_bot_pos;
        }
    }
  }
  dbg(bot);
  print(grid);
  sum := 0;
  for line, y: grid {
    for block, x: line {
      if block == char("[") {
        sum += 100 * y + x;
      }
    }
  }
  dbg(sum);
}

check_obstacle :: (grid: *[..][]u8, bot_pos: Pair, delta: Pair) -> bool {
  lt, rt: Pair;
  if grid_get(grid.*, bot_pos) == {
    case #char "["; lt = bot_pos; rt = right(bot_pos);
    case #char "]"; lt = left(bot_pos); rt = bot_pos;
    case #char "."; return true;
    case #char "#"; return false;
    case; assert(false);
  }
  if delta.b != 0 {
    return check_obstacle(grid, bot_pos + delta, delta);
  } else if grid_get(grid.*, lt+delta) == #char "[" {
    return check_obstacle(grid, lt + delta, delta);
  } else {
    return check_obstacle(grid, lt+delta, delta) && check_obstacle(grid, rt+delta, delta);
  }
}

move_boxes :: (grid: *[..][]u8, bot_pos: Pair, delta: Pair) {
  lt, rt: Pair;
  if grid_get(grid.*, bot_pos) == {
    case #char "["; lt = bot_pos; rt = right(bot_pos);
    case #char "]"; lt = left(bot_pos); rt = bot_pos;
    case #char "."; return;
    case; assert(false);
  }

  if delta.b != 0 {
    move_boxes(grid, bot_pos + delta * 2, delta);
  } else {
    move_boxes(grid, lt+delta, delta);
    move_boxes(grid, rt+delta, delta);
  }

  grid_set(grid.*, lt, #char ".");
  grid_set(grid.*, rt, #char ".");
  grid_set(grid.*, lt+delta, #char "[");
  grid_set(grid.*, rt+delta, #char "]");
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
        bot = .{bot_y, bot_x * 2};
      }
      builder: String_Builder;
      for line {
        if it == {
          case #run char("."); #through;
          case #run char("@");
            for 0..1 append(*builder, char("."));
          case #run char("#");
            for 0..1 append(*builder, char("#"));
          case #run char("O");
            append(*builder, char("["));
            append(*builder, char("]"));
        }
      }
      array_add(*grid, cast([]u8) builder_to_string(*builder));
    } else {
      for line {
        array_add(*moves, it);
      }
    }
  }
  return grid, moves, bot;
}

P1 :: #import,file "part1.jai";
#import "Basic";
#import "STL";
#import "String";
