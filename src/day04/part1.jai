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
      result += cast(int) chexmas(grid, x, y, 0, 1);
      result += cast(int) chexmas(grid, x, y, 0, -1);
      result += cast(int) chexmas(grid, x, y, 1, 0);
      result += cast(int) chexmas(grid, x, y, -1, 0);
      result += cast(int) chexmas(grid, x, y, -1, 1);
      result += cast(int) chexmas(grid, x, y, -1, -1);
      result += cast(int) chexmas(grid, x, y, 1, 1);
      result += cast(int) chexmas(grid, x, y, 1, -1);
    }
  }
  dbg(result);
}

chexmas :: (grid: [][]u8, start_x: int, start_y: int, delta_x: int, delta_y: int) -> bool {
  char_x := start_x;
  char_y := start_y;
  c1, c2, c3, c4: u8;
  c1 = grid_get(grid, char_y, char_x);
  char_x += delta_x; char_y += delta_y;

  c2 = grid_get(grid, char_y, char_x);
  char_x += delta_x; char_y += delta_y;

  c3 = grid_get(grid, char_y, char_x);
  char_x += delta_x; char_y += delta_y;

  c4 = grid_get(grid, char_y, char_x);

  return c1 == cast(u8) #char "X" &&
    c2 == cast(u8) #char "M" &&
    c3 == cast(u8) #char "A" &&
    c4 == cast(u8) #char "S";
}
