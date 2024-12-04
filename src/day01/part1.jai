#import "Basic";
#import "String";
#import "STL";
Math :: #import "Math";
Sort :: #import "Sort";

main :: () {
    list1, list2: [..] int;
    for Spliterator.{source = INPUT, skip_empty = true} {
        is := parse_line(it);
        assert(is.count == 2);
        array_add(*list1, is[0]);
        array_add(*list2, is[1]);
    }
    Sort.quick_sort(list1, identity);
    Sort.quick_sort(list2, identity);
    assert(list1.count == list2.count);
    result := 0;
    for 0..list1.count-1 {
        result += Math.abs(list1[it] - list2[it]);
    }
    dbg(result);
}

