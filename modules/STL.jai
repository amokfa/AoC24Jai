// Sagar Tiwari's Library™
//
// Some generic utilities

#import "Basic";
Basic :: #import "Basic";
#import "String";
#import "Math";

suba :: (a: []$T, s: int, e: int) -> []T {
  result := a;
  result.data += s;
  result.count = e - s;
  return result;
}

subs :: (s: string, start: int, end: int) -> string {
  return cast(string) suba(cast([]u8) s, start, end);
}

Spliterator :: struct {
    source: string;
    current_index := 0;
    split_at := cast(u8) #char "\n";
    skip_empty := false;
}

for_expansion :: (iterator: Spliterator, body: Code, flags: For_Flags) #expand {
    `it_index := 0;
    while iterator.current_index <= iterator.source.count {
        remaining := subs(iterator.source, iterator.current_index, iterator.source.count);
        next_nl := find_index_from_left(remaining, iterator.split_at);
        `it: string = ---;
        if next_nl == -1 {
            it = remaining;
            iterator.current_index = iterator.source.count+1;
        } else {
            it = subs(iterator.source, iterator.current_index, iterator.current_index+next_nl);
            iterator.current_index += next_nl + 1;
        }
        if iterator.skip_empty && it.count == 0 {
            continue;
        }
        defer it_index += 1;
        #insert body;
    }
}

println :: (format_string: string, args: .. Any, to_standard_error := false) -> bytes_printed: s64 {
    written := print(format_string, ..args, to_standard_error);
    print("\n");
    return written + 1;
} @PrintLike

dbg :: (v: $T) -> T {
    println("%", v);
    return v;
}

panic :: (assertion: bool, format_string: string, args: .. Any) {
    if !assertion {
        println(format_string, ..args);
        assert(false);
    }
} @PrintLike

identity :: (v: $T) -> T {
    return v;
}

parse_line :: (line: string) -> [..] int {
    items: [..] int;
    for Spliterator.{source=line, split_at=cast(u8) #char " ", skip_empty=true} {
        value, success := parse_int(*it);
        if !success {
            dbg(line);
            dbg(it);
        }
        assert(success);
        array_add(*items, value);
    }
    return items;
}

array_get :: (arr: []$T, idx: int) -> T {
  if idx >= arr.count || idx < 0 {
    res: T;
    return res;
  } else {
    return arr[idx];
  }
}

grid_get :: (grid: [][]$T, i1: int, i2: int) -> T {
  return array_get(array_get(grid, i1), i2);
}

grid_set :: (grid: [][]$T, i1: int, i2: int, val: T) {
  grid[i1][i2] = val;
}

print :: (grid: [][]u8) {
  for grid {
    println("%", cast(string)it);
  }
}

char :: ($s: string) -> u8 {
  return s[0];
}

X :: cast(u8) #char "X";
M :: cast(u8) #char "M";
A :: cast(u8) #char "A";
S :: cast(u8) #char "S";

StackRArr :: struct ($N: int, $T: Type) {
  data: [N] T;
  count := 0;
}

array_add :: (arr: *StackRArr, elem: $T) {
  panic(arr.count < arr.data.count, "Tried pushing too many elements to StackRArr");
  arr.data[arr.count] = elem;
  arr.count += 1;
}

Pair :: struct {
  a, b: int;
}

operator == :: (p1: Pair, p2: Pair) -> bool {
  return p1.a == p2.a && p1.b == p2.b;
}
#poke_name Basic operator==;

operator - :: (p1: Pair, p2: Pair) -> Pair {
  return .{p1.a-p2.a, p1.b-p2.b};
}

operator * :: (p: Pair, n: int) -> Pair {
  return .{p.a * n, p.b * n};
}

abs :: (p: Pair) -> Pair {
  return .{abs(p.a), abs(p.b)};
}

pow :: (a: int, b: int) -> int {
  result := 1;
  for 0..b-1 {
    result *= a;
  }
  return result;
}

num_digs :: (n: int) -> int {
  result := 1;
  while true {
    if n < 10 {
      break;
    }
    n /= 10;
    result += 1;
  }
  return result;
}

parse_grid :: (i: string) -> [..][]u8 {
  grid: [..][] u8;
  grid.allocator = temp;
  width := 0;
  for Spliterator.{source=i, skip_empty=true} {
    if width == 0 {
      width = it.count;;
    }
    panic(width == it.count, "non uniform grid");
    array_add(*grid, cast([]u8) it);
  }
  return grid;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "Thread";
Simp :: #import "Simp";
Input :: #import "Input";
#import "Window_Creation";

UiPainterContext :: struct($T: Type) {
  painter: #type (*T);
  data: T;
}

run_ui :: (painter: (*$T), data: T) {
  thread := New(Thread);
  thread.proc = ui_painter;
  ui_context := New(UiPainterContext(T));
  ui_context.painter = painter;
  ui_context.data = data;
  thread_init(thread, ui_painter);
  thread_start(thread);
}

ui_painter :: (t: *Thread) -> s64 {
  // ctx := cast(*UiPainterContext(T)) t.data;
  window := create_window(512, 512, "AOC", 8);
  width, height := Simp.get_render_dimensions(window);
  Simp.set_render_target(window, .LEFT_HANDED);
  quit := false;
  while !quit {
    Input.update_window_events();
    for Input.get_window_resizes() {
      Simp.update_window(it.window);
    }
    for Input.events_this_frame {
      dbg(it);
      if it.type == .QUIT then quit = true;
    }

    // drawing
    
    

    sleep_milliseconds(10);
    reset_temporary_storage();
  }
  return 0;
}

ArrayMap :: struct ($K: Type, $V: Type, $N: int) {
  ks: [N]K;
  vs: [N]V;
  index: [N]bool;
}


set :: (map: *ArrayMap($K, $V, $N), k: K, v: V) {
  for map.index {
    if !it {
      map.ks[it_index] = k;
      map.vs[it_index] = v;
      map.index[it_index] = true;
      return;
    }
  }
}

get :: (map: *ArrayMap($K, $V, $N), k: K) -> V {
  for 0..N-1 {
    if !map.index[it] continue;
    if map.ks[it] == k {
      return map.vs[it];
    }
  }
  result: V= ---;
  return result;
}

contains :: (map: *ArrayMap($K, $V, $N), k: K) -> bool {
  for 0..N-1 {
    if map.index[it] && map.ks[it] == k return true;
  }
  return false;
}

for_expansion :: (map: ArrayMap($K, $V, $N), body: Code, flags: For_Flags) #expand {
  for n: 0..N-1 {
    if map.index[n] {
      `it_index := map.ks[n];
      `it := map.vs[n];
      #insert body;
    }
  }
}

