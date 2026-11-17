# Iris-generated Nushell color overrides (rendered by Iris custom template)
# Source this from config.nu when present.

$env.config = ($env.config | upsert color_config {
  separator: "{dim}"
  leading_trailing_space_bg: "{surface}"
  header: "{accent}"
  empty: "{dim}"
  bool: "{yellow}"
  int: "{fg}"
  filesize: "{cyan}"
  duration: "{fg}"
  date: "{fg}"
  range: "{fg}"
  float: "{fg}"
  string: "{green}"
  nothing: "{dim}"
  binary: "{fg}"
  cell-path: "{fg}"
  row_index: "{accent}"
  record: "{fg}"
  list: "{fg}"
  block: "{fg}"
  hints: "{dim}"
  search_result: { fg: "{bg}" bg: "{accent}" }
  shape_garbage: { fg: "{bg}" bg: "{red}" bold: true }
  shape_directory: "{cyan}"
  shape_filepath: "{cyan}"
  shape_internalcall: "{accent}"
  shape_external: "{green}"
  shape_externalarg: "{fg}"
  shape_keyword: "{yellow}"
  shape_string: "{green}"
  shape_variable: "{magenta}"
})
