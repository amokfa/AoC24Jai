#import "Basic";
#import "STL";
#import "String";

main :: () {
    result := 0;
    current_index := 0;
    do_state := true;
    while true {
        mi := find_index_from_left(INPUT, "mul(", current_index);
        if mi == -1 {
            break;
        }
        // from comma forwards
        v1, s1, remaining3 := string_to_int(subs(INPUT, mi+4, INPUT.count));
        if !s1 || remaining3[0] != cast(u8) #char "," {
            current_index = mi + 4;
            continue;
        }
        remaining3.data += 1;
        remaining3.count -= 1;
        // from closing parenthesis onwards
        v2, s2, remaining4 := string_to_int(remaining3);
        if !s2 || remaining4[0] != cast(u8) #char ")" {
            current_index = INPUT.count - remaining3.count;
            continue;
        }

        // find first do or dont before mul()
        do_idx := find_index_from_right(subs(INPUT, 0, mi), "do()");
        dont_idx := find_index_from_right(subs(INPUT, 0, mi), "don't()");
        if do_idx > dont_idx {
            do_state = true;
        } else if dont_idx > do_idx {
            do_state = false;
        }
        if do_state {
            result += v1 * v2;
        }
        current_index = INPUT.count - (remaining4.count - 1);
    }
    dbg(result);
}
