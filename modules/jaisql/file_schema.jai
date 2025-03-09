
FileHeader :: struct {
  header_string: [16] u8;
  page_size: u16,
  write_version, read_version: u8;
  page_tail_unused_bytes: u8;
  max_epf, min_epf: u8;
  leaf_payload_fraction: u8;
  file_change_counter: u32;
  pages_count: u32;
  first_freelist_trunc_page: u32;
  freelist_pages_count: u32;
  schema_cookie: u32;

}