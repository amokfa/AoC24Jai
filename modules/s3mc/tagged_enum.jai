EnumVariant :: struct {
  name: string;
  data: Type;
}

gen_enum :: (name: string, variants: [] EnumVariant) -> string {
  result: String_Builder;
  result.allocator = temp;

  tag_list: String_Builder; tag_list.allocator = temp;
  for variants append(*tag_list, tprint(" %;", it.name));
  tag_def: String_Builder; tag_def.allocator = temp;
  append(*tag_def, tprint("enum {% }", builder_to_string(*tag_list)));

  data_union: String_Builder; data_union.allocator = temp;
  for variants append(*data_union, tprint("    %: %;\n", it.name, it.data));
  append(
    *result,
    tprint(
      "% :: struct {\n  tag: %;\n  data: union {\n%  };\n}",
      name, builder_to_string(*tag_def), builder_to_string(*data_union)
    )
  );

  return builder_to_string(*result);
}

#scope_file
#import "Basic";
