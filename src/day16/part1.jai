
main :: () {
  grid, start, end := parse(INPUT);
  start_node := NodeType.{ start, .East };
  min := 999999999999;
  min_node: NodeType;
  mapping := dijkstra(*grid, start_node, get_neighbours);
  for parent, node: mapping {
    if node.coord == end {
      if parent.distance < min {
        min = parent.distance;
        min_node = node;
      }
    }
  }
  while min_node != start_node {
    marker: u8;
    if min_node.facing == {
      case .East; marker = char(">");
      case .West; marker = char("<");
      case .North; marker = char("^");
      case .South; marker = char("v");
    }
    set(*grid, min_node.coord, marker);
    ns, found := table_find(*mapping, min_node);
    if !found {
      assert(false);
    }
    min_node = ns.neighbour;
  }
  dbg(min);
}

Direction :: enum { East; North; West; South; }
left :: (d: Direction) -> Direction {
  return cast(Direction, (cast(u8, d)+1) % 4);
}
right :: (d: Direction) -> Direction {
  return cast(Direction, (cast(u8, d)-1) % 4);
}
NodeType :: struct { coord: Pair; facing: Direction; }

get_neighbours :: (g: *Grid(u8), n: NodeType) -> [..] NS(NodeType) {
  result: [..] NS(NodeType);
  array_add(*result, .{.{n.coord,  left(n.facing)}, 1000});
  array_add(*result, .{.{n.coord, right(n.facing)}, 1000});
  front: NodeType;
  if n.facing == {
    case .East; front = .{right(n.coord), n.facing};
    case .West; front = .{left(n.coord), n.facing};
    case .North; front = .{up(n.coord), n.facing};
    case .South; front = .{down(n.coord), n.facing};
  }
  if get(g, front.coord) != char("#") {
    array_add(*result, .{front, 1});
  }
  return result;
}

parse :: (input: string) -> grid: Grid(u8), start: Pair, end: Pair {
  data: [..]u8;
  array_reserve(*data, input.count);
  rows := 0;
  cols := 0;
  start, end: Pair;
  for line: Spliterator.{source=input, split_at=char("\n"), skip_empty=true} {
    if cols != 0 {
      assert(line.count == cols);
    } else {
      cols = line.count;
    }
    for line {
      array_add(*data, it);
      if it == {
        case #char "S"; start = .{rows, it_index};
        case #char "E"; end = .{rows, it_index};
      }
    }
    rows += 1;
  }
  return .{data, rows, cols}, start, end;
}

#import "STL";
#import "Basic";
#import "Pool";
#import "Hash_Table";