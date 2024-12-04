#import "STL";
#import "Basic";
#import "String";

main :: () {
    result := 0;
    // string left to process
    remaining := INPUT;
    remaining2, remaining3, remaining4: string = ---;
    success: bool;
    v1, v2: int;
    while remaining.count > 0 {
        mi := find_index_from_left(remaining, "mul(");
        if mi == -1 {
            break;
        }
        // from first int forwards
        remaining2 = subs(remaining, mi+4, remaining.count);
        // from comma forwards
        v1, success, remaining3 = string_to_int(remaining2);
        if !success || remaining3[0] != cast(u8) #char "," {
            remaining = remaining3;
            continue;
        }
        remaining3.data += 1;
        remaining3.count -= 1;
        // from closing parenthesis onwards
        v2, success, remaining4 = string_to_int(remaining3);
        if !success || remaining4[0] != cast(u8) #char ")" {
            remaining = remaining4;
            continue;
        }
        result += v1 * v2;
        remaining4.data += 1;
        remaining4.count -= 1;
        remaining = remaining4;
    }
    dbg(result);
}