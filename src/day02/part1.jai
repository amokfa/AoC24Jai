#import "Basic";
#import "String";
#import "STL";

nums_are_valid :: (nums: [] int) -> bool {
    if nums.count == 1 {
        return true;
    } else if nums[1] > nums[0] {
        valid := true;
        for 0..nums.count-2 {
            diff := nums[it+1] - nums[it];
            if diff < 1 || diff > 3 {
                valid = false;
                break;
            }
        }
        return valid;
    } else if nums[1] < nums[0] {
        valid := true;
        for 0..nums.count-2 {
            diff := nums[it] - nums[it+1];
            if diff < 1 || diff > 3 {
                valid = false;
                break;
            }
        }
        return valid;
    } else {
        return false;
    }
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