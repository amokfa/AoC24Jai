
main :: () {
  ri := parse(INPUT);
  for Range.{0, 100} {
    step(*ri);
  }
  q1, q2, q3, q4 := 0;
  for ri {
    if it.pos.a < W/2 {
      if it.pos.b < H/2 {
        q1 += 1;
      } else if it.pos.b > H/2 {
        q2 += 1;
      }
    } else if it.pos.a > W/2 {
      if it.pos.b < H/2 {
        q3 += 1;
      } else if it.pos.b > H/2 {
        q4 += 1;
      }
    }
  }
  dbg(q1 * q2 * q3 * q4);
}

step :: (ris: *[..] RobotInfo ) {
  for Range.{0, ris.count} {
    ri := *(ris.*[it]);
    pos := *(ri.pos);
    pos.* += ri.vel;

    while pos.a < W {
      pos.a += W;
    }
    pos.a %= W;
    while pos.b < H {
      pos.b += H;
    }
    pos.b %= H;
  }
}

parse :: (input: string) -> [..] RobotInfo {
  result: [..] RobotInfo;
  for line: Spliterator.{source=input, split_at=char("\n"), skip_empty=true} {
    x, y: int;
    success: bool;
    rest: string;
    x, success, rest = string_to_int(subs(line, 2));
    if !success assert(false);
    y, success, rest = string_to_int(subs(rest, 1));
    if !success assert(false);
    pos := Pair.{x, y};
    x, success, rest = string_to_int(subs(rest, 3));
    if !success assert(false);
    y, success, rest = string_to_int(subs(rest, 1));
    if !success assert(false);
    vel := Pair.{x, y};
    array_add(*result, .{pos, vel});
  }
  return result;
}

RobotInfo :: struct {
  pos, vel: Pair;
}

W :: 101;
H :: 103;
// W :: 11;
// H :: 7;

#import "STL";
#import "Basic";
