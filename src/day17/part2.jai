
main :: () {
  exe := P1.parse(INPUT);
  io_mapping: Table(int, int);
  for i: Range.{0, 1024} {
    exe.ra = i; exe.rb = 0; exe.rb = 0;
    outputs := P1.run(*exe); defer array_free(outputs);
    table_set(*io_mapping, i, outputs[0]);
  }
  oi_mapping: Table(int, [..] int);
  for value, key: io_mapping {
    arr := find_or_add(*oi_mapping, value);
    array_add(arr, key);
  }

  b1_candidates, found := table_find(*oi_mapping, 2);
  b2_candidates:, found = table_find(*oi_mapping, 4);
  b3_candidates:, found = table_find(*oi_mapping, 1);
  b4_candidates:, found = table_find(*oi_mapping, 1);
  b5_candidates:, found = table_find(*oi_mapping, 7);
  b6_candidates:, found = table_find(*oi_mapping, 5);
  b7_candidates:, found = table_find(*oi_mapping, 0);
  b8_candidates:, found = table_find(*oi_mapping, 3);
  b9_candidates:, found = table_find(*oi_mapping, 1);
  b10_candidates:, found = table_find(*oi_mapping, 4);
  b11_candidates:, found = table_find(*oi_mapping, 4);
  b12_candidates:, found = table_find(*oi_mapping, 0);
  b13_candidates:, found = table_find(*oi_mapping, 5);
  b14_candidates:, found = table_find(*oi_mapping, 5);
  b15_candidates:, found = table_find(*oi_mapping, 3);
  b16_candidates:, found = table_find(*oi_mapping, 0);

  result := S64_MAX;
  seven_bits := 0b1111111;
  for c1: b1_candidates {
    for c2: b2_candidates {
      if (c1 >> 3) == (c2 & seven_bits) {
        for c3: b3_candidates {
          if ((c2 >> 3) & seven_bits) == (c3 & seven_bits) {
            for c4: b4_candidates {
              if ((c3 >> 3) & seven_bits) == (c4 & seven_bits) {
                for c5: b5_candidates {
                  if ((c4 >> 3) & seven_bits) == (c5 & seven_bits) {
                    for c6: b6_candidates {
                      if ((c5 >> 3) & seven_bits) == (c6 & seven_bits) {
                        for c7: b7_candidates {
                          if ((c6 >> 3) & seven_bits) == (c7 & seven_bits) {
                            for c8: b8_candidates {
                              if ((c7 >> 3) & seven_bits) == (c8 & seven_bits) {
                                for c9: b9_candidates {
                                  if ((c8 >> 3) & seven_bits) == (c9 & seven_bits) {
                                    for c10: b10_candidates {
                                      if ((c9 >> 3) & seven_bits) == (c10 & seven_bits) {
                                        for c11: b11_candidates {
                                          if ((c10 >> 3) & seven_bits) == (c11 & seven_bits) {
                                            for c12: b12_candidates {
                                              if ((c11 >> 3) & seven_bits) == (c12 & seven_bits) {
                                                for c13: b13_candidates {
                                                  if ((c12 >> 3) & seven_bits) == (c13 & seven_bits) {
                                                    for c14: b14_candidates {
                                                      if ((c13 >> 3) & seven_bits) == (c14 & seven_bits) {
                                                        for c15: b15_candidates {
                                                          if ((c14 >> 3) & seven_bits) == (c15 & seven_bits) {
                                                            for c16: b16_candidates {
                                                              if ((c15 >> 3) & seven_bits) == (c16 & seven_bits) {
                                                                num := c1 | (c2 << 3)  | (c3 << 6)  | (c4 << 9)  | (c5 << 12) | (c6 << 15) | (c7 << 18) | (c8 << 21) | (c9 << 24) | (c10 << 27)| (c11 << 30)| (c12 << 33) | (c13 << 36)| (c14 << 39)| (c15 << 42)| (c16 << 45);
                                                                exe.ra = num; exe.rb = 0; exe.rb = 0;
                                                                outputs := P1.run(*exe); defer array_free(outputs);
                                                                if outputs.count == exe.program.count {
                                                                  equal := true;
                                                                  for Range.{0, exe.program.count} {
                                                                    if exe.program[it] != outputs[it] equal = false;
                                                                  }
                                                                  if equal && num < result result = num;
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  dbg(result);
}

do_temp_example :: () {
  exe := P1.parse(INPUT);
  result := 0;
  for byte, byte_index: exe.program {
    result |= byte << ((byte_index + 1) * 3);
  }
  dbg(result);
}

do_part_2 :: () {
  exe := P1.parse(INPUT);
  result := 0;
  for rb, byte_index: exe.program {
    // result |= stuff << (byte_index * 3);
  }
  dbg(result);
}

decompile_program :: () {
  exe := P1.parse(INPUT);
  rip := 0;
  while rip < exe.program.count {
    instr := exe.program[rip];
    rip += 1;
    cr := combo_repr(exe.program[rip]);
    lr := literal_repr(exe.program[rip]);
    rip += 1;
    if cast(P1.Opcode, instr) == {
      case .Adv;
        println("RA >>= %", cr);
      case .Bxl;
        println("RB ^= %", lr);
      case .Bst;
        println("RB = % & 0b111", cr);
      case .Jnz;
        println("if RA != 0 then RIP = %", lr);
      case .Bxc;
        println("RB ^= RC");
      case .Out;
        println("LOG(% & 0b111)", cr);
      case .Bdv;
        println("RB = RA >> %", cr);
      case .Cdv;
        println("RC = RA >> %", cr);
    }
  }
}

i2s: [8] string : .["0", "1", "2", "3", "4", "5", "6", "7"];
combo_repr :: (arg: int) -> string {
  if arg <= 3 return i2s[arg];
  if arg == {
    case 4; return "RA";
    case 5; return "RB";
    case 6; return "RC";
  }
  assert(false);
  return "";
}
literal_repr :: (arg: int) -> string {
  return i2s[arg];
}

P1 :: #import,file "part1.jai";
#import "STL";
#import "Math";
#import "Basic";
#import "Hash_Table";