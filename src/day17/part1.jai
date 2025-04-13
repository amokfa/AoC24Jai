
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
    ca := combo(exe, ip+1);
    la := exe.program[ip+1];
    if opcode == {
      case .Adv; exe.ra = exe.ra >> ca;
      case .Bxl; exe.rb ^= la;
      case .Bst; exe.rb = ca & 0b111;
      case .Bxc; exe.rb ^= exe.rc;
      case .Out; array_add(*result, ca & 0b111);
      case .Bdv; exe.rb = exe.ra >> ca;
      case .Cdv; exe.rc = exe.ra >> ca;
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
    case 4; return exe.ra & 0b111;
    case 5; return exe.rb & 0b111;
    case 6; return exe.rc & 0b111;
  }
  dbg(addr);
  dbg(literal);
  assert(false);
  return 0;
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
  return .{};
}

Opcode :: enum {
  Adv; Bxl; Bst; Jnz; Bxc; Out; Bdv; Cdv;
}

#import "Basic";
#import "STL";
#import "Print_Vars";
