
main :: () {
  codes := P1.parse(INPUT);
  grid1_paths := P1.get_possible_paths(GRID1);
  grid2_paths := P1.get_possible_paths(GRID2);
  grid2_cache: Table(CacheKey, string);
  result := 0;
  for code: codes {
    minmom := 99999999;
    e1s: [..] string; defer array_free(e1s);
    P1.expand(*grid1_paths, char("A"), code, "", *e1s);

  }
  dbg(result);
}

CacheKey :: struct { start, end, depth: u8; }

P1 :: #import,file "part1.jai";