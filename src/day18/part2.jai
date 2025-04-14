main :: () {
  drops := P1.parse(INPUT);
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
  // TODO: optimize using binary search
  for drops {
    set(*grid, it, char("#"));
    mapping := dijkstra(*grid, Pair.{0, 0}, P1.get_neighbours);
    result, found := table_find(*mapping, Pair.{grid.rows-1, grid.cols-1});
    if !found {
      println("%,%", it.b, it.a);
      break;
    }
  }
}

P1 :: #import,file "part1.jai";
#import "STL";
#import "Hash_Table";
#import "Basic";