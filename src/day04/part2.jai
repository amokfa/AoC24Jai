#import "STL";
#import "Basic";
#import "String";


main :: () {
  line_size := find_index_from_left(INPUT, "\n");
  assert(line_size > 0);

  grid: [..][] u8;

  for Spliterator.{source=INPUT, skip_empty=true} {
    assert(line_size == it.count);
    array_add(*grid, cast([]u8) it);
  }

  result := 0;
  for y: 0..grid.count-1 {
    for x: 0..line_size-1 {
      if grid_get(grid, y, x) == A {
        a1 := grid_get(grid, y+1, x+1);
        a2 := grid_get(grid, y-1, x-1);
        b1 := grid_get(grid, y+1, x-1);
        b2 := grid_get(grid, y-1, x+1);
        if ((a1 == M && a2 == S) || (a1 == S && a2 == M)) && ((b1 == M && b2 == S) || (b1 == S && b2 == M)) {
          result += 1;
        }
      }
    }
  }
  dbg(result);
}


