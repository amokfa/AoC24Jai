
main :: () {
  exe := parse(INPUT);
  output := run(*exe);
  for output {
    print("%", it);
    print("%", ifx it_index == output.count-1 "" else ",");
  }
}

run :: (exe: *Exe) -> [..] int {
  result: [..]int;
  ip := 0;
  while ip < exe.program.count {
    opcode := cast(Opcode, exe.program[ip]);
    if opcode == {
      case .Adv; exe.ra = exe.ra / pow(2, combo(exe, ip+1));
      case .Bxl; exe.rb ^= exe.program[ip+1];
      case .Bst; exe.rb = combo(exe, ip+1) % 8;
      case .Out; array_add(*result, combo(exe, ip+1) % 8);
      case .Bdv; exe.rb = exe.ra / pow(2, combo(exe, ip+1));
      case .Cdv; exe.rb = exe.ra / pow(2, combo(exe, ip+1));
    }
    if opcode == .Jnz {
      if exe.ra != 0 {
        ip = exe.program[ip+1];
      } else {
        ip += 2;
      }
    } else {
      ip += 2;
    }
  }
  return result;
}

combo :: (exe: *Exe, addr: int) -> int {
  literal := exe.program[addr];
  if literal <= 3 {
    return literal;
  }
  if literal == {
    case 4; return exe.ra;
    case 5; return exe.rb;
    case 6; return exe.rc;
  }
  dbg(addr);
  dbg(literal);
  assert(false);
}

Exe :: struct { ra: int; rb: int; rc: int; program: [..] int; }
parse :: (input: string) -> Exe {
  ra, rb, rc: int;
  for Spliterator.{source=input, split_at=char("\n"), skip_empty=true} {
    if it_index == {
      case 0; ra = string_to_int(subs(it, 12));
      case 1; rb = string_to_int(subs(it, 12));
      case 2; rc = string_to_int(subs(it, 12));
      case 3;
        program: [..]int;
        for Spliterator.{source=subs(it, 9), split_at=char(","), skip_empty=true} {
          array_add(*program, string_to_int(it));
        }
        return .{ra, rb, rc, program};
    }
  }
  assert(false);
}

Opcode :: enum {
  Adv; Bxl; Bst; Jnz; Bxc; Out; Bdv; Cdv;
}

#import "Basic";
#import "STL";
