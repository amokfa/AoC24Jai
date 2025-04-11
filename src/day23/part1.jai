main :: () {
  links := parse(INPUT);
  graph := to_graph(links);
  for neighbours, node: graph {
    print("% : ", node);
    for _t, neighbour: neighbours {
      print("% ", neighbour);
    }
    println("");
  }
}

Link :: struct { c1, c2: string; }

parse :: (s: string) -> [..] Link {
  result: [..] Link;
  for Spliterator.{ source=s, skip_empty=true } {
    link := Link.{subs(it, 0, 2), subs(it, 3)};
    array_add(*result, link);
  }
  return result;
}

to_graph :: (links: [] Link) -> Table(string, Table(string, bool)) {
  result: Table(string, Table(string, bool));
  for link: links {
    ptr := find_or_add(*result, link.c1);
    table_set(ptr, link.c2, true);
    ptr = find_or_add(*result, link.c2);
    table_set(ptr, link.c1, true);
  }
  return result;
}

#import "STL";
#import "Basic";
#import "Print_Vars";
#import "Hash_Table";