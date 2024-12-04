#import "Basic";
#import "String";
#import "STL";
HT :: #import "Hash_Table";

main :: () {
    list1: [..] int;
    counts2: HT.Table(int, int);
    HT.init(*counts2);
    for Spliterator.{source = INPUT, skip_empty = true} {
        is := parse_line(it);
        assert(is.count == 2);
        array_add(*list1, is[0]);
        current, found := HT.table_find(*counts2, is[1]);
        if !found {
            current = 0;
        }
        HT.table_set(*counts2, is[1], current+1);
    }
    result := 0;
    for list1 {
        value, found := HT.table_find(*counts2, it);
        if !found {
            value = 0;
        }
        result += it * value;
    }
    dbg(result);
}

