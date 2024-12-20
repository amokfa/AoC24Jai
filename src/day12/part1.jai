#import "STL";
#import "Basic";
#import "Hash_Table";

main :: () {
  grid := parse_grid(INPUT);
  R, C := grid.count, grid[0].count;
  seen := create_bitmap(R, C);
  result := 0;
  while true {
    pt := find_next_region(seen);
    if pt.a == -1 {
      break;
    }
    area, circum := walk_region(grid, pt, *seen);
    result += area * circum;
  }
  dbg(result);
}

create_bitmap :: (h: int, w: int) -> [..][..]bool {
  result: [..][..]bool;
  array_reserve(*result, h);
  for 1..h {
    row: [..]bool;
    array_reserve(*row, w);
    for 1..w {
      array_add(*row, false);
    }
    array_add(*result, row);
  }
  return result;
}

find_next_region :: (seen: [][..]bool) -> Pair {
  for r: 0..seen.count-1 {
    for c: 0..seen[0].count-1 {
      if !seen[r][c] {
        return .{r, c};
      }
    }
  }
  return .{-1, -1};
}

walk_region :: (grid: [][]u8, start: Pair, seen: *[..][..]bool) -> int, int {
  left_nodes: [..]Pair;
  seen_nodes: Table(Pair, bool);
  array_add(*left_nodes, start);
  area := 0;
  circumference := 0;
  curr_type := grid[start.a][start.b];
  while left_nodes.count > 0 {
    next := pop(*left_nodes);
    if table_contains(*seen_nodes, next) || !grid_contains(grid, next.a, next.b) {
      continue;
    }
    area += 1;
    table_set(*seen_nodes, next, true);
    grid_set(<<seen, next.a, next.b, true);
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

    if grid_get(grid, left(next)) != curr_type {
      circumference += 1;
    }
    if grid_get(grid, right(next)) != curr_type {
      circumference += 1;
    }
    if grid_get(grid, up(next)) != curr_type {
      circumference += 1;
    }
    if grid_get(grid, down(next)) != curr_type {
      circumference += 1;
    }
  }
  return area, circumference;
}

