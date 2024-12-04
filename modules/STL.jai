// Sagar Tiwari's Library™
//
// Some generic utilities

#import "Basic";
#import "String";

Spliterator :: struct {
    source: string;
    current_index := 0;
    split_at := cast(u8) #char "\n";
    skip_empty := false;
}

subs :: (s: string, start: int, end: int) -> string {
    result: string = ---;
    result.data = s.data + start;
    result.count = end - start;
    return result;
}

for_expansion :: (iterator: Spliterator, body: Code, flags: For_Flags) #expand {
    `it_index := 0;
    while iterator.current_index <= iterator.source.count {
        remaining := subs(iterator.source, iterator.current_index, iterator.source.count);
        next_nl := find_index_from_left(remaining, iterator.split_at);
        `it: string = ---;
        if next_nl == -1 {
            `it = remaining;
            iterator.current_index = iterator.source.count+1;
        } else {
            `it = subs(iterator.source, iterator.current_index, iterator.current_index+next_nl);
            iterator.current_index += next_nl + 1;
        }
        if iterator.skip_empty && `it.count == 0 {
            continue;
        }
        `it_index += 1;
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

ALL_CHARS :: "{!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~}";

X :: cast(u8) #char "X";
M :: cast(u8) #char "M";
A :: cast(u8) #char "A";
S :: cast(u8) #char "S";
