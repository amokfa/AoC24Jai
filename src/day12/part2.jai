#import "STL";
#import "Basic";
#import "Hash_Table";
P1 :: #import,file "./part1.jai";

main :: () {
  grid := parse_grid(INPUT);
  R, C := grid.count, grid[0].count;
  seen := P1.create_bitmap(R, C);
  curr := P1.create_bitmap(R, C);
  result := 0;
  while true {
    pt := P1.find_next_region(seen);
    if pt.a == -1 {
      break;
    }
    area, circum := walk_region(grid, pt, *seen, *curr);
    result += area * circum;
  }
  dbg(result);
}

walk_region :: (grid: [][]u8, start: Pair, seen: *[..][..]bool, curr: *[..][..]bool) -> int, int {
  for r: 0..curr.count-1 {
    for c: 0..curr[0].count-1 {
      (<<curr)[r][c] = false;
    }
  }
  left_nodes: [..]Pair;
  seen_nodes: Table(Pair, bool);
  array_add(*left_nodes, start);
  area := 0;
  curr_type := grid[start.a][start.b];
  while left_nodes.count > 0 {
    next := pop(*left_nodes);
    if table_contains(*seen_nodes, next) || !grid_contains(grid, next.a, next.b) {
      continue;
    }
    area += 1;
    table_set(*seen_nodes, next, true);
    grid_set(<<seen, next.a, next.b, true);
    grid_set(<<curr, next.a, next.b, true);
    if grid_get(grid, left(next)) == curr_type && !table_contains(*seen_nodes, left(next)) {
      array_add(*left_nodes, left(next));
    }
    if grid_get(grid, right(next)) == curr_type && !table_contains(*seen_nodes, right(next)) {
      array_add(*left_nodes, right(next));
    }
    if grid_get(grid, up(next)) == curr_type && !table_contains(*seen_nodes, up(next)) {
      array_add(*left_nodes, up(next));
    }
    if grid_get(grid, down(next)) == curr_type && !table_contains(*seen_nodes, down(next)) {
      array_add(*left_nodes, down(next));
    }
  }

  corners := 0;
  for r: 0..curr.count-1 {
    for c: 0..curr[0].count-1 {
      if !(<<curr)[r][c] {
        continue;
      }
      next := Pair.{r, c};
      n1 := grid_get(<<curr, up(left(next)));
      n2 := grid_get(<<curr, up(next));
      n3 := grid_get(<<curr, up(right(next)));
      n4 := grid_get(<<curr, left(next));
      n5 := grid_get(<<curr, right(next));
      n6 := grid_get(<<curr, down(left(next)));
      n7 := grid_get(<<curr, down(next));
      n8 := grid_get(<<curr, down(right(next)));
      if !n2 && !n4 {
        corners += 1;
      }
      if !n2 && !n5 {
        corners += 1;
      }
      if !n4 && !n7 {
        corners += 1;
      }
      if !n7 && !n5 {
        corners += 1;
      }
      if !n1 && n2 && n4 {
        corners += 1;
      }
      if !n3 && n2 && n5 {
        corners += 1;
      }
      if !n6 && n4 && n7 {
        corners += 1;
      }
      if !n8 && n5 && n7 {
        corners += 1;
      }
    }
  }
  return area, corners;
}

