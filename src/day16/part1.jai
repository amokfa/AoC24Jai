
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
  for di: enum_values_as_s64(Direction) {
    direction := cast(Direction) di;
    array_add(*result, .{.{n.coord,  left(n.facing)}, 1000});
    array_add(*result, .{.{n.coord, right(n.facing)}, 1000});
  }
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

NS :: struct (N: Type) {neighbour: N; distance: int;}

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

Grid :: struct ($T: Type) {
    data: [..] T;
    rows, cols: int;
}

get :: (grid: *Grid($T), idx: Pair) -> T {
    if idx.a < grid.rows && idx.b < grid.cols {
        return grid.data[idx.a * grid.cols + idx.b];
    }
    result: T = ---;
    return result;
}

set :: (grid: *Grid($T), idx: Pair, val: T) {
    if idx.a < grid.rows && idx.b < grid.cols {
        grid.data[idx.a * grid.cols + idx.b] = val;
    }
}

print :: (grid: *Grid($T)) {
    for r: Range.{0, grid.rows} {
        for c: Range.{0, grid.cols} {
            chr := get(grid, .{r, c});
            s: string;
            s.data = xx *chr;
            s.count = 1;
            print("%", s);
        }
        print("\n");
    }
}

MinH :: struct ($T: Type) {
  nodes: [..] T;
  weights: [..] int;
}

add :: (using mh: *MinH($T), node: T, weight: int) {
  array_add(*nodes, node);
  array_add(*weights, weight);
  index := nodes.count-1;
  while true {
    parent_index := (index-1)/2;
    if index == 0 || weights[parent_index] <= weights[index] {
      break;
    }
    Swap(*nodes[index], *nodes[parent_index]);
    Swap(*weights[index], *weights[parent_index]);
  }
}

pop :: (using mh: *MinH($T)) -> node: T, weight: int {
  if mh.nodes.count == 0 {
    a: T;
    b: int;
    return a, b;
  }
  node := nodes[0];
  weight := weights[0];
  nodes[0] = nodes[nodes.count-1];
  weights[0] = weights[weights.count-1];
  nodes.count -= 1;
  weights.count -= 1;
  heapify_down(mh, 0);
  return node, weight;
}

get_weight :: (using mh: *MinH($T), key: T) -> weight: int, found: bool {
  for Range.{0, nodes.count} {
    if nodes[it] == key {
      return weights[it], true;
    }
  }
  return -1, false;
}

heapify_down :: (using mh: *MinH($T), index: int) {
  left_child := 2 * index + 1;
  right_child := 2 * index + 2;
  smallest := index;
  if left_child < weights.count && weights[left_child] < weights[smallest] {
    smallest = left_child;
  }
  if right_child < weights.count && weights[right_child] < weights[smallest] {
    smallest = right_child;
  }
  if smallest != index {
    Swap(*nodes[index], *nodes[smallest]);
    Swap(*weights[index], *weights[smallest]);
    heapify_down(mh, smallest);
  }
}

dijkstra :: (graph: *$G, start: $N, neighbours: (*G, N) -> [..] NS(N)) -> Table(N, NS(N)) {
    // pool: Pool;
    // set_allocators(*pool);
    // old_allocator := context.allocator;
    // context.allocator = .{pool_allocator_proc, *pool};

    all_distances: Table(N, NS(N));
    visited_nodes: Table(N, bool);
    unvisited: MinH(N);
    add(*unvisited, start, 0);

    while unvisited.nodes.count != 0 {
      node, dist := pop(*unvisited);
      if table_contains(*visited_nodes, node) {
        continue;
      }
      table_set(*visited_nodes, node, true);

      for neighbours(graph, node) {
        new_dist := dist + it.distance;
        curr_dist, found := table_find(*all_distances, it.neighbour);
        if !found || new_dist < curr_dist.distance {
          table_set(*all_distances, it.neighbour, .{node, new_dist});
          add(*unvisited, it.neighbour, new_dist);
        }
      }
    }

    // context.allocator = old_allocator;
    // release(*pool);
    return all_distances;
}


#import "STL";
#import "Basic";
#import "Pool";
#import "Hash_Table";