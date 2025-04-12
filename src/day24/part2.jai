
main :: () {
  random_seed(cast(u64, current_time_monotonic().low));
  _values, gates := P1.parse(INPUT);
  ig: Table(string, bool);
  test_values: Table(string, int);
  table_set(*test_values, "x00", 1);
  table_set(*test_values, "x01", 1);
  table_set(*test_values, "y00", 0);
  table_set(*test_values, "y01", 1);
  P1.run_circuit(*test_values, gates);
  dbg(table_find(*test_values, "z01"));
}

generate_test_input :: (num_bits: int) -> Table(string, int), Table(string, int) {
  inputs, outputs: Table(string, int);
  x := get_hash(random_get());
  y := get_hash(random_get());
  z := x + y;
  for Range.{0, num_bits} {
    table_set(*inputs, tprint("x%", formatInt(it, minimum_digits=2)), ifx x & cast(u64, 1 << it) == 0 then 0 else 1);
    table_set(*inputs, tprint("y%", formatInt(it, minimum_digits=2)), ifx y & cast(u64, 1 << it) == 0 then 0 else 1);
    table_set(*outputs, tprint("z%", formatInt(it, minimum_digits=2)), ifx z & cast(u64, 1 << it) == 0 then 0 else 1);
  }
  return inputs, outputs;
}

involved_gates :: (design: [] P1.Gate, output: string, result: *Table(string, bool)) {
  table_set(result, output, true);
  found := false;
  gate: P1.Gate;
  for design {
    if it.output == output {
      gate = it;
      found = true;
      break;
    }
  }
  if found {
    involved_gates(design, gate.c1, result);
    involved_gates(design, gate.c2, result);
  }
}

P1 :: #import,file "part1.jai";
#import "Hash_Table";
#import "STL";
#import "Basic";
#import "Random";
#import "Hash";
