
main :: () {
  drops := parse(INPUT);
  size := 0;
  for drops {
    if it.a > size size = it.a;
    if it.b > size size = it.b;
  }
  size += 1;
  grid_data: [..] u8;
  for Range.{0, size * size} {
    array_add(*grid_data, char("."));
  }
  grid := Grid(u8).{ grid_data, size, size };
  for Range.{0, min(drops.count, 1024)} {
    set(*grid, drops[it], char("#"));
  }
  mapping := dijkstra(*grid, Pair.{0, 0}, get_neighbours);
  result, found := table_find(*mapping, Pair.{grid.rows-1, grid.cols-1});
  assert(found);
  dbg(result.distance);
}

get_neighbours :: (grid: *Grid(u8), node: Pair) -> [..] NS(Pair) {
  result: [..] NS(Pair);
  if node.a > 0 && get(grid, up(node)) == char(".") array_add(*result, .{ up(node), 1 });
  if node.a < grid.rows-1 && get(grid, down(node)) == char(".") array_add(*result, .{ down(node), 1 });
  if node.b > 0 && get(grid, left(node)) == char(".") array_add(*result, .{ left(node), 1 });
  if node.b < grid.cols-1 && get(grid, right(node)) == char(".") array_add(*result, .{ right(node), 1 });
  return result;
}

parse :: (s: string) -> [..] Pair {
  result: [..] Pair;
  for Spliterator.{ source=s, skip_empty=true } {
    comma := find_index_from_left(it, #char ",");
    assert(comma > 0, it);
    x, ok := string_to_int(subs(it, 0, comma));
    assert(ok, it);
    y:, ok = string_to_int(subs(it, comma+1));
    assert(ok, it);
    array_add(*result, .{y, x});
  }
  return result;
}

#scope_file

#import "STL";
#import "Basic";
#import "String";
#import "Hash_Table";