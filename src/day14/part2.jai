main :: () {
  ri := P1.parse(INPUT);
  for i: Range.{1, S64_MAX} {
    P1.step(*ri);
    if copy_pasta(*ri) {
      dbg(i);
      break;
    }
  }
}

copy_pasta :: (ri: *[..]P1.RobotInfo) -> bool {
  sum := 0;
  for ri.* {
    stuff := abs(it.pos - .{P1.W, P1.H}/2);
    sum += stuff.a;
    sum += stuff.b;
  }
  return sum < #run pow(2, 14);
}

#import "STL";
#import "Math";
P1 ::#import,file "part1.jai";
