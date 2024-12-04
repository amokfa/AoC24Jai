#import "Basic";
#import "String";
#import "STL";
P1 :: #import,file "part1.jai";

nums_are_valid :: (nums: [] int) -> bool {
    if P1.nums_are_valid(nums) {
        return true;
    } else {
        for 0..nums.count-1 {
            nums_copy := array_copy(nums);
            array_ordered_remove_by_index(*nums_copy, it);
            if P1.nums_are_valid(nums_copy) {
                return true;
            }
        }
    }
    return false;
}

main :: () {
    count := 0;
    for Spliterator.{source = INPUT, skip_empty=true} {
        nums := parse_line(it);
        assert(nums.count > 0);
        if nums_are_valid(nums) { count += 1; }
    }
    dbg(count);
}