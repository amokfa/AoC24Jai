// Sagar Tiwari's Library™
//
// Some generic utilities

#import "Basic";
#import "String";
#import "Math";

suba :: (a: []$T, s: int, e: int) -> []T {
  result := a;
  result.data += s;
  result.count = e - s;
  return result;
}

subs :: (s: string, start: int, end: int = -1) -> string {
  eend: int;
  if end < 0 {
    eend = s.count + end + 1;
  } else {
    eend = end;
  }
  return cast(string) suba(cast([]u8) s, start, eend);
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

grid_get :: (grid: [][]$T, p: Pair) -> T {
  return grid_get(grid, p.a, p.b);
}

array_get :: (arr: [..]$T, idx: int) -> T {
  if idx >= arr.count || idx < 0 {
    res: T;
    return res;
  } else {
    return arr[idx];
  }
}

grid_get :: (grid: [..][..]$T, p: Pair) -> T {
  return array_get(array_get(grid, p.a), p.b);
}

grid_set :: (grid: [][]$T, i1: int, i2: int, val: T) {
  grid[i1][i2] = val;
}

grid_set :: (grid: [..][..]$T, i1: int, i2: int, val: T) {
  if i1 >= 0 && i1 < grid.count {
    if i2 >= 0 && i2 < grid[0].count {
      grid[i1][i2] = val;
    }
  }
}

grid_set :: (grid: [][]u8, p: Pair, val: u8) {
  grid_set(grid, p.a, p.b, val);
}

grid_contains :: (grid: [][]$T, i1: int, i2: int) -> bool {
  if i1 >= 0 && i1 < grid.count {
    if i2 >= 0 && i2 < grid[0].count {
      return true;
    }
  }
  return false;
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

for_expansion :: (arr: *StackRArr, body: Code, flags: For_Flags) #expand {
  `it_index := ifx (flags & .REVERSE) then arr.count-1 else 0;
  end := ifx (flags & .REVERSE) then -1 else arr.count;
  delta := ifx (flags & .REVERSE) then -1 else 1;
  while it_index != end {
    `it := arr.data[it_index];
    defer it_index += delta;
    #insert body;
  }
}

to_stack_arr :: (slice: [] $T, $N: int) -> StackRArr(N, T) {
  #import "Basic";
  result: StackRArr(N, T);
  result.count = min(N, slice.count);
  for 0..result.count-1 {
    result.data[it] = slice[it];
  }
  return result;
}

to_stack_arr :: (s: string, $N: int) -> StackRArr(N, u8) {
  return to_stack_arr(cast([]u8) s, N);
}

as_slice :: (arr: *StackRArr($N, $T)) -> [] T {
  result: [] T;
  result.data = cast(*T) arr;
  result.count = arr.count;
  return result;
}

as_string :: (arr: *StackRArr($N, u8)) -> string {
  return cast(string) as_slice(arr);
}

first :: (arr: *StackRArr($N, $T)) -> T {
  result: T = ---;
  if arr.count > 0 {
    result = arr.data[0];
  }
  return result;
}

last :: (arr: *StackRArr($N, $T)) -> T {
  result: T = ---;
  if arr.count > 0 {
    result = arr.data[arr.count-1];
  }
  return result;
}

pop :: (arr: *StackRArr($N, $T)) -> T {
  result := last(arr);
  arr.count -= 1;
  return result;
}

array_add :: (arr: *StackRArr, elem: $T) {
  panic(arr.count < arr.data.count, "Tried pushing too many elements to StackRArr");
  arr.data[arr.count] = elem;
  arr.count += 1;
}

delete :: (arr: *StackRArr, idx: $T) {
  for idx..arr.count-2 {
    arr.data[idx] = arr.data[idx+1];
  }
  arr.count -= 1;
}

swap_after :: (arr: *StackRArr($N, $T), idx: int) {
  panic(idx < N-1, "can't do this operation at the end");
  tmp := arr.data[idx];
  arr.data[idx] = arr.data[idx+1];
  arr.data[idx+1] = tmp;
}

Pair :: struct {
  a, b: int;
}
operator == :: (p1: Pair, p2: Pair) -> bool {
  return p1.a == p2.a && p1.b == p2.b;
}
#poke_name (#import "Basic") operator==;
#poke_name (#import "Hash_Table") operator==;

operator - :: (p1: Pair, p2: Pair) -> Pair {
  return .{p1.a-p2.a, p1.b-p2.b};
}

operator + :: (p1: Pair, p2: Pair) -> Pair {
  return .{p1.a+p2.a, p1.b+p2.b};
}

operator * :: (p: Pair, n: int) -> Pair {
  return .{p.a * n, p.b * n};
}

operator / :: (p: Pair, n: int) -> Pair {
  return .{p.a / n, p.b / n};
}

abs :: (p: Pair) -> Pair {
  return .{abs(p.a), abs(p.b)};
}

dot :: (p1: Pair, p2: Pair) -> int {
  return p1.a * p2.a + p1.b * p2.b;
}

len2 :: (p: Pair) -> int {
  return p.a * p.a + p.b * p.b;
}

left :: (p: Pair) -> Pair {
  return .{p.a, p.b-1};
}

right :: (p: Pair) -> Pair {
  return .{p.a, p.b+1};
}

up :: (p: Pair) -> Pair {
  return .{p.a-1, p.b};
}

down :: (p: Pair) -> Pair {
  return .{p.a+1, p.b};
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

// #import "Thread";
// Simp :: #import "Simp";
// Input :: #import "Input";
// #import "Window_Creation";

// UiPainterContext :: struct($T: Type) {
//   painter: #type (*T);
//   data: T;
// }

// run_ui :: (painter: (*$T), data: T) {
//   thread := New(Thread);
//   thread.proc = ui_painter;
//   ui_context := New(UiPainterContext(T));
//   ui_context.painter = painter;
//   ui_context.data = data;
//   thread_init(thread, ui_painter);
//   thread_start(thread);
// }

// ui_painter :: (t: *Thread) -> s64 {
//   // ctx := cast(*UiPainterContext(T)) t.data;
//   window := create_window(512, 512, "AOC", 8);
//   width, height := Simp.get_render_dimensions(window);
//   Simp.set_render_target(window, .LEFT_HANDED);
//   quit := false;
//   while !quit {
//     Input.update_window_events();
//     for Input.get_window_resizes() {
//       Simp.update_window(it.window);
//     }
//     for Input.events_this_frame {
//       dbg(it);
//       if it.type == .QUIT then quit = true;
//     }

//     // drawing
//
//

//     sleep_milliseconds(10);
//     reset_temporary_storage();
//   }
//   return 0;
// }

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

operator == :: (a: $T, b: T) -> bool {
  pa := cast(*u8) *a;
  pb := cast(*u8) *b;
  for 0..size_of(T)-1 {
    if pa[it] != pb[it] {
      return false;
    }
  }
  return true;
}

Hash :: #import "Hash";
get_hash :: (v: $T, h: u32 = 5381) -> u32
#modify {
  ti := cast(*Type_Info) T;
  return ti.type == .STRUCT;
}
{
  array: []u8;
  array.data = cast(*u8) *v;
  array.count = size_of(T);
  return Hash.get_hash(array, h);
}
#poke_name (#import "Hash") get_hash;

#import "GetRect_LeftHanded";
pad :: (rect: Rect, amt: float32 = 0, vert: float32 = 0, horiz: float32 = 0) -> Rect {
  vertt := ifx vert != 0 vert else amt;
  horizz := ifx horiz != 0 horiz else amt;
  return .{rect.x + horizz, rect.y + vertt, rect.w - 2*horizz, rect.h - 2*vertt};
}

split_horiz :: (rect: Rect, $N: int = 2) -> [N] Rect {
  result: [N] Rect;
  w := rect.w / N;
  for 0..N-1 {
    result[it] = .{rect.x + w * it, rect.y, w, rect.h};
  }
  return result;
}

position_float :: (parent: Rect, w: float32 = -1.0, h: float32 = -1.0, top: float32 = -1.0, left: float32 = -1.0, bottom: float32 = -1.0, right: float32 = -1.0) -> Rect {
  panic(top != -1 || bottom != -1, "at least one of top or bottom must be provided");
  panic(left != -1 || right != -1, "at least one of left or right must be provided");
  xmin, ymin, xmax, ymax: float32 = -1;
  if left != -1 {
    xmin = parent.x + left;
  }
  if top != -1 {
    ymin = parent.y + top;
  }
  if right != -1 {
    xmax = parent.x + parent.w - right;
  }
  if bottom != -1 {
    ymax = parent.y + parent.h - bottom;
  }

  rw, rh: float32;
  if xmin != -1 && xmax != -1 {
    rw = xmax - xmin;
  } else {
    panic(w != -1, "invalid constraints");
    rw = w;
  }
  if ymin != -1 && ymax != -1 {
    rh = ymax - ymin;
  } else {
    panic(h != -1, "invalid constraints");
    rh = h;
  }

  rx, ry: float32;
  if xmin != -1 {
    rx = xmin;
  } else {
    rx = xmax - rw;
  }
  if ymin != -1 {
    ry = ymin;
  } else {
    ry = ymax - rh;
  }
  return .{rx, ry, rw, rh};
}

int_validator :: (s: string) -> bool {
  if s.count <= 0 return false;
  v, s, rest := string_to_int(s);
  return s && rest.count == 0;
}

get_days_in_month :: (year: int, month: int) -> int {
    // Check for valid month input
    if month < 1 || month > 12 {
        return 0; // Invalid month
    }

    // Array of days per month for non-leap years
    days_in_month: [12]int = .[
        31, // January
        28, // February
        31, // March
        30, // April
        31, // May
        30, // June
        31, // July
        31, // August
        30, // September
        31, // October
        30, // November
        31  // December
    ];

    // Check for leap year and adjust February
    if month == 2 && (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
        return 29; // Leap year February
    }

    // Return the number of days in the given month
    return days_in_month[month - 1];
}

Date :: struct {
  year: int;
  month: int;
  day: int;
}

date_from_string :: (s: string) -> result: Date, success: bool {
  year, month, day: int;
  success: bool;
  rest: string;
  year, success, rest = string_to_int(s);
  if !success || rest.count == 0 return .{}, false;
  if year < 2000 || year > 2050 return .{}, false;
  if rest[0] != char("-") return .{}, false;

  month, success, rest = string_to_int(drop(rest, 1));
  if !success || rest.count == 0 return .{}, false;
  if month < 1 || month > 12 return .{}, false;
  if rest[0] != char("-") return .{}, false;

  day, success, rest = string_to_int(drop(rest, 1));
  if !success || rest.count != 0 return .{}, false;
  if day < 1 || day > get_days_in_month(year, month) return .{}, false;

  return .{year, month, day}, true;
}

to_stack_arr :: (date: Date, $N: int) -> StackRArr(N, u8) {
  // N must be at least 11, 10 for date + 1 for \0 because we are using snprintf
  #import "POSIX";
  result: StackRArr(N, u8);
  ptr := cast(*u8, *result.data);
  snprintf(ptr, 5, "%04d", date.year);
  ptr += 4;
  ptr.* = char("-");
  ptr += 1;
  snprintf(ptr, 3, "%02d", date.month);
  ptr+= 2;
  ptr.* = char("-");
  ptr += 1;
  snprintf(ptr, 3, "%02d", date.day);
  result.count = 10;
  return result;
}

tomorrow :: (today: Date) -> Date {
  result := today;
  result.day += 1;
  if result.day > get_days_in_month(result.year, result.month) {
    result.day = 1;
    result.month += 1;
    if result.month > 12 {
      result.month = 1;
      result.year += 1;
    }
  }
  return result;
}

yesterday :: (today: Date) -> Date {
  result := today;
  result.day -= 1;
  if result.day == 0 {
    result.month -= 1;
    if result.month == 0 {
      result.month = 12;
      result.year -= 1;
    }
    result.day = get_days_in_month(result.year, result.month);
  }
  return result;
}

today :: () -> Date {
  #import "POSIX";
  t := time(null);
  lt := localtime(*t);
  return .{lt.tm_year+1900, lt.tm_mon+1, lt.tm_mday};
}

date_validator :: (s: string) -> bool {
  _, result := date_from_string(s);
  return result;
}

simp_validator :: (s: string) -> bool {
  return s.count > 0;
}

drop :: (s: string, n: int) -> string {
  if s.count < n return "";
  result := s;
  result.data = s.data+n;
  result.count = s.count-n;
  return result;
}

Range :: struct { start: int; end: int; }

for_expansion :: (r: Range, code: Code, flags: For_Flags) #expand {
  `it := r.start;
  `it_index := 0;
  while it < r.end {
    defer it += 1;
    defer it_index += 1;

    #insert code;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

GenTupleImpl :: (n: int) -> string {
  assert(n >= 2);

  type_parameters: String_Builder;
  init_string_builder(*type_parameters);
  for 1..n {
    append(*type_parameters, tprint("T%: Type", it));
    if it != n {
      append(*type_parameters, ", ");
    }
  }

  fields: String_Builder;
  init_string_builder(*fields);
  for 1..n {
    append(*fields, tprint(" f%: T%;", it, it));
  }

  return tprint("Tuple% :: struct (%) {% }", n, builder_to_string(*type_parameters), builder_to_string(*fields));
}

GenTuplesImpl :: (n: int) -> string {
  code: String_Builder;
  init_string_builder(*code);

  for 2..n {
    append(*code, GenTupleImpl(it));
    if it != n append(*code, "\n");
  }

  return builder_to_string(*code);
}

#insert #run GenTuplesImpl(5);

////////////////////////////////////////////////////////////////////////////////////////////////////

Queue :: struct ($N: int, $T: Type) {
  buffer: [N] T;
  start: int = 0;
  end: int = 0;
}

push :: (using q: *Queue($N, $T), value: T) {
  next_end := (end + 1) % N;
  buffer[next_end] = value;
  if next_end == start {
    start = (start + 1) % N;
  }
  end = next_end;
}

pop :: (q: Queue($N, $T)) -> T, bool {
  res: T = ---;
  return res, false;
}

for_expansion :: (q: *Queue($N, $T), body: Code, flags: For_Flags) #expand {
  `it_index := 0;
  buf_index := ifx (flags & .REVERSE) then q.end-1 else q.start;
  buf_index = (buf_index + N) % N;
  delta := ifx (flags & .REVERSE) then -1 else 1;
  end := ifx (flags & .REVERSE) q.start else q.end-1;
  while true {
    `it := q.buffer[buf_index];
    #insert body;

    buf_index = (buf_index + delta + N) % N;
    if buf_index == end {
      break;
    }
  }
}

vert :: (v: Vector2) -> Vector2 {
  return .{0, v.y};
}

horiz :: (v: Vector2) -> Vector2 {
  return .{v.x, 0};
}

from_c_string :: (cs: *u8) -> string {
  result: string;
  result.data = cs;
  result.count = c_style_strlen(cs);
  return result;
}