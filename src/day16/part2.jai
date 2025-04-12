
main :: () {
  grid, start, end := P1.parse(INPUT);
  start_node := P1.NodeType.{ start, .East };
  mapping := dijkstra(*grid, start_node, P1.get_neighbours);
  print(*mapping);

  good_spots: Table(Pair, bool);

  min_dist := 9999999999;
  for parent, node: mapping {
    if node.coord == end {
      if parent.distance < min_dist {
        min_dist = parent.distance;
      }
    }
  }
  dbg(min_dist);
  for parent, node: mapping {
    if node.coord == end {
      if parent.distance == min_dist {
        seen_nodes: Table(P1.NodeType, bool);
        println("==============================");
        println("checking: %|%", node, parent.distance);
        find_good_spots(*grid, node, *mapping, *good_spots, *seen_nodes);
        println("==============================");
      }
    }
  }

  print(*good_spots);
  dbg(good_spots.count);
}

find_good_spots :: (grid: *Grid(u8), curr: P1.NodeType, mapping: *Table(P1.NodeType, NS(P1.NodeType)), good_spots: *Table(Pair, bool), seen_nodes: *Table(P1.NodeType, bool), depth := 0) {
  if table_contains(seen_nodes, curr) return;
  table_set(seen_nodes, curr, true);

  prefix_builder: String_Builder;
  for Range.{0, depth} {
    append(*prefix_builder, "  ");
  }
  prefix := builder_to_string(*prefix_builder);
  println("%processing: %", prefix, curr);

  neighbours := get_reverse_neighbours(grid, curr);
  min_dist := 9999999999;
  for neighbours {
    n, found := table_find(mapping, it.neighbour);
    if found && n.distance < min_dist min_dist = n.distance;
  }
  println("%min dist: %", prefix, min_dist);
  for neighbours {
    n, found := table_find(mapping, it.neighbour);
    if found && n.distance == min_dist {
      println("%going down to: %", prefix, it.neighbour);
      find_good_spots(grid, it.neighbour, mapping, good_spots, seen_nodes, depth+1);
    }
  }
  table_set(good_spots, curr.coord, true);
}

get_reverse_neighbours :: (g: *Grid(u8), n: P1.NodeType) -> [..] NS(P1.NodeType) {
  result: [..] NS(P1.NodeType);
  array_add(*result, .{.{n.coord,  P1.left(n.facing)}, 1000});
  array_add(*result, .{.{n.coord, P1.right(n.facing)}, 1000});
  front: P1.NodeType;
  if n.facing == {
    case .East; front = .{left(n.coord), n.facing};
    case .West; front = .{right(n.coord), n.facing};
    case .North; front = .{down(n.coord), n.facing};
    case .South; front = .{up(n.coord), n.facing};
  }
  if get(g, front.coord) != char("#") {
    array_add(*result, .{front, 1});
  }
  return result;
}

P1 :: #import,file "part1.jai";
#import "STL";
#import "Hash_Table";
#import "Basic";