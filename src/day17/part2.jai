
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
  b15_candidates:, found = table_find(*oi_mapping, 0);
  b16_candidates:, found = table_find(*oi_mapping, 3);

  for c1: b1_candidates {
      for c2: b2_candidates {
          if c1 >> 3 == c2 & 0b1111111 {
              for c3: b3_candidates {
                  if c2 >> 3 == c3 & 0b1111111 {
                      for c4: b4_candidates {
                          if c3 >> 3 == c4 & 0b1111111 {
                              for c5: b5_candidates {
                                  if c4 >> 3 == c5 & 0b1111111 {
                                      for c6: b6_candidates {
                                          if c5 >> 3 == c6 & 0b1111111 {
                                              for c7: b7_candidates {
                                                  if c6 >> 3 == c7 & 0b1111111 {
                                                      for c8: b8_candidates {
                                                          if c7 >> 3 == c8 & 0b1111111 {
                                                              for c9: b9_candidates {
                                                                  if c8 >> 3 == c9 & 0b1111111 {
                                                                      for c10: b10_candidates {
                                                                          if c9 >> 3 == c10 & 0b1111111 {
                                                                              for c11: b11_candidates {
                                                                                  if c10 >> 3 == c11 & 0b1111111 {
                                                                                      for c12: b12_candidates {
                                                                                          if c11 >> 3 == c12 & 0b1111111 {
                                                                                              for c13: b13_candidates {
                                                                                                  if c12 >> 3 == c13 & 0b1111111 {
                                                                                                      for c14: b14_candidates {
                                                                                                          if c13 >> 3 == c14 & 0b1111111 {
                                                                                                              for c15: b15_candidates {
                                                                                                                  if c14 >> 3 == c15 & 0b1111111 {
                                                                                                                      for c16: b16_candidates {
                                                                                                                          if c15 >> 3 == c16 & 0b1111111 {
                                                                                                                              println("% and % and % and % and % and % and % and % and % and % and % and % and % and % and % and %",
                                                                                                                                c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16);
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
#import "Basic";
#import "Hash_Table";