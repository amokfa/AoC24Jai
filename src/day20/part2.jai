main :: () {
  grid, start, end := D16.parse(INPUT);
  gwc := GridWithCheat.{ grid, .{-1, -1} };

  mapping := dijkstra(*gwc, start, get_neighbours);
  finish, found := table_find(*mapping, end);
  assert(found);
  legal_time := finish.distance;

  result := 0;
  for r: Range.{1, grid.rows-1} {
    for c: Range.{1, grid.cols-1} {
      if get(*grid, .{r, c}) != char("#") continue;
      gwc := GridWithCheat.{ grid, .{r, c} };
      mapping := dijkstra(*gwc, start, get_neighbours);
      finish, found := table_find(*mapping, end);
      assert(found);
      cheat_time := finish.distance;
      if legal_time - cheat_time >= 100 {
        result += 1;
      }
    }
  }
  dbg(result);
}

GridWithCheat :: struct {
  grid: Grid(u8);
  cheat_start: Pair;
  cheat_end: Pair;
}

get_neighbours :: (grid: *GridWithCheat, node: Pair) -> [..] NS(Pair) {
  result: [..] NS(Pair);
  for 0..3 {
    dir := cast(D16.Direction, it);
    front: Pair;
    if dir == {
      case .East; front = right(node);
      case .West; front = left(node);
      case .North; front = up(node);
      case .South; front = down(node);
    }
    if front == grid.cheat || get(*grid.grid, front) != char("#") {
      array_add(*result, .{ front, 1 });
    }
  }
  return result;
}

D16 :: #import,file "../day16/part1.jai";
#import "STL";
#import "Basic";
#import "Print_Vars";
#import "Hash_Table";