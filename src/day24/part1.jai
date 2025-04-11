main :: () {
  values, exprs := parse(INPUT);
  while true {
    did_something := false;
    for expr, name: exprs {
      if !table_contains(*values, name) {
        v1, found1 := table_find(*values, expr.c1);
        v2, found2 := table_find(*values, expr.c2);
        if found1 && found2 {
          table_set(*values, name, perform(expr.op, v1, v2));
          did_something = true;
        }
      }
    }
    if !did_something break;
  }
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

perform :: (op: Op, v1: int, v2: int) -> int {
  if op == {
    case .AND; return v1 & v2;
    case .OR; return v1 | v2;
    case .XOR; return v1 ^ v2;
  }
  assert(false);
  return 0;
}

parse :: (s: string) -> Table(string, int), Table(string, Expr) {
  inputs: Table(string, int);
  exprs:  Table(string, Expr);

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
      table_set(*exprs, name, .{c1, c2, op});
    }
  }
  return inputs, exprs;
}

Expr :: struct {
  c1, c2: string;
  op: Op;
}
Op :: enum { AND; OR; XOR; };

#import "STL";
#import "Basic";
#import "String";
#import "Print_Vars";
#import "Hash_Table";