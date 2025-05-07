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

is_full :: (s: *StackRArr($N, $T)) -> bool {
  return s.count >= N;
}

eq :: inline (s1: StackRArr($N, $T), s2: StackRArr(N, T)) -> bool {
  if s1.count != s2.count return false;
  return memcmp(xx *s1.data, xx *s2.data, s1.count * size_of(T)) == 0;
}

operator == :: inline (s1: StackRArr($N, $T), s2: StackRArr(N, T)) -> bool { return eq(s1, s2); }

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

array_find :: (arr: *StackRArr($N, $T), pred: (T) -> bool) -> int {
  for * arr {
    if pred(it) return it_index;
  }
  return -1;
}

array_find :: (arr: *[..] $T, ctx: *$U, pred: (*U, *T) -> bool) -> int {
  for * arr.* {
    if pred(ctx, it) return it_index;
  }
  return -1;
}

delete :: (arr: *StackRArr, idx: int) {
  for idx..arr.count-2 {
    arr.data[it] = arr.data[it+1];
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

operator == :: inline (a: $T, b: T) -> bool {
  pa := cast(*void, *a);
  pb := cast(*void, *b);
  return memcmp(pa, pb, size_of(T)) == 0;
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
pad :: (rect: Rect, amt := 0.0, vert := 0.0, horiz := 0.0, left := 0.0, right := 0.0, up := 0.0, down := 0.0) -> Rect {
  vertt := ifx vert != 0 vert else amt;
  horizz := ifx horiz != 0 horiz else amt;
  lleft := ifx left != 0 then left else horizz;
  rright := ifx right != 0 then right else horizz;
  uup := ifx up != 0 then up else vertt;
  ddown := ifx down != 0 then down else vertt;
  return .{rect.x + lleft, rect.y + uup, rect.w - lleft - rright, rect.h - uup - ddown};
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

to_temp_string :: (d: Date) -> string {
  return tprint(
    "%-%-%",
    formatInt(d.year, minimum_digits=4, padding=#char "0"),
    formatInt(d.month, minimum_digits=2, padding=#char "0"),
    formatInt(d.day, minimum_digits=2, padding=#char "0"),
  );
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

one_month_later :: (today: Date) -> Date {
  result := today;
  max_in_this_month := get_days_in_month(result.year, result.month);
  if result.day != max_in_this_month {
    result.day = max_in_this_month;
    return result;
  }
  result.month += 1;
  if result.month > 12 {
    result.month = 1;
    result.year += 1;
  }
  result.day = get_days_in_month(result.year, result.month);
  return result;
}

one_year_later :: (today: Date) -> Date {
  result := today;
  result.year += 1;
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

one_month_ago :: (today: Date) -> Date {
  result := today;
  if result.day != 1 {
    result.day = 1;
    return result;
  }
  result.month -= 1;
  if result.month == 0 {
    result.month = 12;
    result.year -= 1;
  }
  result.day = 1;
  return result;
}

one_year_ago :: (today: Date) -> Date {
  result := today;
  result.year -= 1;
  return result;
}

today :: () -> Date {
  #import "POSIX";
  t := time(null);
  lt := localtime(*t);
  return .{lt.tm_year+1900, lt.tm_mon+1, lt.tm_mday};
}

julian_date :: (d: Date) -> int {
  a := (14 - d.month) / 12;
  y := d.year + 4800 - a;
  m := d.month + 12 * a - 3;
  return d.day + (153 * m + 2) / 5 + 365 * y + y/4 - y/100 + y/400 - 32045;
}

julian_to_date :: (jd: int) -> Date {
    d: Date;
    a := jd + 32044;
    b := (4 * a + 3) / 146097;
    c := a - (146097 * b) / 4;
    d_val := (4 * c + 3) / 1461;
    e := c - (1461 * d_val) / 4;
    m := (5 * e + 2) / 153;

    d.day = (e - (153 * m + 2) / 5 + 1);
    d.month = (m + 3 - 12 * (m / 10));
    d.year = (100 * b + d_val - 4800 + (m / 10));
    return d;
}

// distance in days
operator - :: (d1: Date, d2: Date) -> int {
  return julian_date(d1) - julian_date(d2);
}

operator > :: (d1: Date, d2: Date) -> bool {
  return julian_date(d1) > julian_date(d2);
}

day_of_week :: (d: Date) -> int {
    q := d.day;
    m := d.month;
    y := d.year;
    if m < 3 {
        m += 12;
        y -= 1;
    }
    K := y % 100;
    J := y / 100;
    h := (q + (13*(m+1))/5 + K + K/4 + J/4 + 5*J) % 7;
    return h;
}

previous_sunday :: (d: Date) -> Date {
    // Using Zeller's, Sunday is represented by 1.
    h := day_of_week(d);
    // Compute the offset in days: if already Sunday (h == 1), subtract 0 days.
    // For other days, (h + 6) % 7 gives the number of days to subtract.
    days_to_subtract := (h + 6) % 7;
    jd := julian_day(d);
    sunday_jd := jd - days_to_subtract;
    return julian_to_date(sunday_jd);
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

bytemuck :: ($O: Type, value: $I) -> O
#modify {
  return true;
  // return size_of(O) == size_of(I);
}
{
  return cast(*O, *value).*;
}

is_allnum :: (c: u8) -> bool {
    if c >= #char "0" && c <= #char "9" {
        return true;
    }
    if c >= #char "A" && c <= #char "Z" {
        return true;
    }
    if c >= #char "a" && c <= #char "z" {
        return true;
    }
    return false;
}

print :: (t: *Table($K, $V)) {
  println("Table(%, %) {", K, V);
  for v, k: t {
    println("  % -> %", k, v);
  }
  println("}");
}

#import "Hash_Table";

EnumVariant :: struct {
  name: string;
  data: Type;
}

gentenum_impl :: (name: string, variants: [] EnumVariant) -> string {
  result: String_Builder;
  result.allocator = temp;

  tag_list: String_Builder; tag_list.allocator = temp;
  for variants append(*tag_list, tprint(" %;", it.name));
  tag_def: String_Builder; tag_def.allocator = temp;
  append(*tag_def, tprint("enum {% }", builder_to_string(*tag_list)));

  data_union: String_Builder; data_union.allocator = temp;
  for variants append(*data_union, tprint("    %: %;\n", it.name, it.data));
  append(
    *result,
    tprint(
      "% :: struct {\n  tag: %;\n  data: union {\n%  }\n}",
      name, builder_to_string(*tag_def), builder_to_string(*data_union)
    )
  );

  return builder_to_string(*result);
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
    index = parent_index;
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

NS :: struct (N: Type) {neighbour: N; distance: int;}

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

signum :: (n: int) -> int {
  return ifx n > 0 then 1 else ifx n < 0 then -1 else 0;
}

remove_day :: (d: Date) -> Date {
  result := d;
  result.day = 0;
  return result;
}
