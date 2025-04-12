main :: () {
  values, gates := parse(INPUT);
  run_circuit(*values, gates);
  result := 0;
  for value, name: values {
    if name[0] == #char "z" {
      significance, ok := string_to_int(subs(name, 1));
      assert(ok, name);
      if value != 0 {
        result |= 1 << significance;
      }
    }
  }
  dbg(result);
}

run_circuit :: (values: *Table(string, int), gates: [] Gate) {
  while true {
    did_something := false;
    for gate: gates {
      if !table_contains(values, gate.output) {
        v1, found1 := table_find(values, gate.c1);
        v2, found2 := table_find(values, gate.c2);
        if found1 && found2 {
          table_set(values, gate.output, perform(gate.op, v1, v2));
          did_something = true;
        }
      }
    }
    if !did_something break;
  }
}

perform :: (op: Op, v1: int, v2: int) -> int {
  if op == {
    case .AND; return v1 & v2;
    case .OR; return v1 | v2;
    case .XOR; return v1 ^ v2;
  }
  assert(false);
  return 0;
}

parse :: (s: string) -> Table(string, int), [..] Gate {
  inputs: Table(string, int);
  gates:  [..] Gate;

  parsing_inputs := true;
  for line: Spliterator.{ source=s, skip_empty=false } {
    if trim(line).count == 0 {
      parsing_inputs = false;
    } else if parsing_inputs {
      name := subs(line, 0, 3);
      value, ok := string_to_int(subs(line, 5));
      assert(ok, line);
      assert(value == 0 || value == 1, line);
      table_set(*inputs, name, value);
    } else {
      c1, c2, name: string;
      op: Op;
      count: int;
      for Spliterator.{ source=line, split_at=char(" ") } {
        count = it_index+1;
        if it_index == {
          case 0; c1 = it;
          case 1;
            if it == {
              case "AND"; op = .AND;
              case "OR"; op = .OR;
              case "XOR"; op = .XOR;
              case; assert(false, line);
            }
          case 2; c2 = it;
          case 4; name = it;
        }
      }
      assert(count == 5, line);
      array_add(*gates, .{c1, c2, op, name});
    }
  }
  return inputs, gates;
}

Gate :: struct {
  c1, c2: string;
  op: Op;
  output: string;
}
Op :: enum { AND; OR; XOR; };

//attach_gates :: (gates: [] Gate) -> [..] AssembledGate, [..] AssembledGate {
//  all_gates: [..] AssembledGate;
//  for gate: gates {
//    array_add(*all_gates, );
//  }
//  return all_gates, output_gates;
//}
//AssembledGate :: struct {
//  type: AGType;
//  fixed_value: int;
//  c1, c2: *AssembledGate;
//  op: Op;
//}
//AGType :: enum { FIXED; DERIVED; };
//#insert #run gentenum_impl(
//  "AssembledGate",
//  .[
//    .{ "FixedValue", int },
//    .{ "Derived", Gate }
//  ]
//);
//Gyatt :: struct { c1, c2: *AssembledGate; op: Op; };

#import "STL";
#import "Basic";
#import "String";
#import "Print_Vars";
#import "Hash_Table";