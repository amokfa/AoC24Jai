
main :: () {
    grid, start, end := parse(INPUT);
    print(*grid);
    dbg(start);
    dbg(end);
    start_node := NodeType.{ start, .East };
    end_node := NodeType.{end, .West};
    dbg(dijkstra(*grid, start, end, get_neighbours));
}

Direction :: enum { East; West; North; South; }
NodeType :: struct { coord: Pair; facing: Direction; }

get_neighbours :: (g: *Grid(u8), n: Pair) -> [..] NS(Pair) {
  result: [..] NS(Pair);
  delta: Pair;
  return result;
}

NS :: struct (N: Type) {neighbour: N; distance: int;}
PQ :: struct (N: Type, ascending: bool) { data: N; priority: int; next: *PQ = null; }

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

// SortedLLNode :: struct ($T: Type) {
//   data: T;
//   weight: int;
//   next: *SortedLL(T);
// }

// SortedLL :: struct ($T: Type) {
//   head: *SortedLLNode;
// }

// add :: (ll: *SortedLL($T), node: T, weight: int) {
//   new_node := New(SortedLL(T));
//   if (ll.head == null || weight < ll.head.weight) {
//     new_node.next = ll.head;
//     ll.head = new_node;
//   } else {
//     parent_node := ll;
//     while parent_node.next != null && parent_node.next.weight <= weight {
//       parent_node = parent_node.next;
//     }
//     new_node.next = parent_node.next;
//     parent_node.next = new_node;
//   }
// }

// pop :: (ll: *SortedLL($T)) -> node: T, weight: int {
//   if ll.head == null {
//     return;
//   }
//   node, weight := ll.head.data, ll.head.weight;
//   ll.head = ll.head.next;
//   return node, weight;
// }

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

dijkstra :: (graph: *$G, start: $N, end: N, neighbours: (*G, N) -> [..] NS(N)) -> Table(N, int) {
    // pool: Pool;
    // set_allocators(*pool);
    // old_allocator := context.allocator;
    // context.allocator = .{pool_allocator_proc, *pool};

    all_distances: Table(N, int);
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
        if !found || new_dist < curr_dist {
          table_set(*all_distances, it.neighbour, new_dist);
          add(*unvisited, it.neighbour, new_dist);
        }
      }
    }

    // result, found := table_find(*all_distances, end);
    // if !found {
    //   assert(false, "wha happan?");
    // }

    // context.allocator = old_allocator;
    // release(*pool);
    return all_distances;
}


#import "STL";
#import "Basic";
#import "Pool";
#import "Hash_Table";