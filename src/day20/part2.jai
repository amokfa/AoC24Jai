main :: () {
  grid, start, end := D16.parse(INPUT);

  mapping := dijkstra(*grid, start, P1.get_neighbours);
  finish, found := table_find(*mapping, end);
  assert(found);
  legal_time := finish.distance;

  path: [..] Pair;
  curr_node := end;
  while true {
    array_add(*path, curr_node);
    if curr_node == start break;
    next_node, found := table_find(*mapping, curr_node);
    assert(found);
    curr_node = next_node.neighbour;
  }
  result := 0;

  for i1: Range.{0, path.count} {
    for i2: Range.{i1+1, path.count} {
      distance := P1.dist(path[i1], path[i2]);
      if distance <= 20 {
        if i2 - i1 >= 100 + distance result += 1;
      }
    }
  }
  dbg(result);
}

dist :: (p1: Pair, p2: Pair) -> int {
  return abs(p1.a-p2.a) + abs(p1.b-p2.b);
}

get_neighbours :: (grid: *Grid(u8), node: Pair) -> [..] NS(Pair) {
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
    if get(grid, front) != char("#") {
      array_add(*result, .{ front, 1 });
    }
  }
  return result;
}

D16 :: #import,file "../day16/part1.jai";
P1 :: #import,file "part1.jai";
#import "STL";
#import "Math";
#import "Basic";
#import "Print_Vars";
#import "Hash_Table";