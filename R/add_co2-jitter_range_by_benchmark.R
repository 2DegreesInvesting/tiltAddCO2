jitter_range_by_benchmark <- function(data, ...) {
  data |>
    group_by(.data[[col_benchmark()]]) |>
    group_split() |>
    map(jitter_range, ...) |>
    reduce(bind_rows)
}

example_data_jitter_range <- example_data_factory(tibble(
  !!col_benchmark() := "all",
  !!col_risk_category_emissions() := "low",
  !!col_min() := 1L,
  !!col_max() := 2L
))
