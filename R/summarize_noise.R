#' Summarize the mean percent noise in each gruop of jittered range of data
#'
#' @param data A dataset with the columns `r toString(col_summarize_noise())`.
#' @inheritParams dplyr::summarize
#'
#' @return See [dplyr::summarize()].
#' @export
#'
#' @examples
#' # styler: off
#' data <- tibble::tribble(
#'   ~min_jitter,  ~min,   ~max, ~max_jitter, ~group,
#'           0.8,   1.0,    2.1,         2.2,      1,
#'           0.9,   1.1,    2.2,         3.0,      1,
#'
#'           0.1,   2.1,    3.1,         5.8,      2,
#'           0.2,   2.2,    3.2,         5.9,      2,
#' )
#' # styler: on
#'
#' summarize_noise(data)
#'
#' summarize_noise(data, .by = "group")
summarize_noise <- function(data, .by = NULL) {
  crucial <- col_summarize_noise()
  check_crucial_names(data, crucial)

  data |>
    dplyr::summarize(
      min_noise = mean_noise(.data[[col_min()]], .data[[col_min_jitter()]]),
      max_noise = mean_noise(.data[[col_max()]], .data[[col_max_jitter()]]),
      .by = all_of(.by)
    )
}

col_summarize_noise <- function() {
  c(
    col_min(),
    col_min_jitter(),
    col_max(),
    col_max_jitter()
  )
}

mean_noise <- function(x, noisy) {
  mean(percent_noise(x, noisy), na.rm = TRUE)
}

toy_summarize_noise <- example_data_factory(tibble(
  # Designed to have 20% and 10% noise for min and max, respectively
  !!col_min_jitter() := 0.8,
  !!col_min() := 1,
  !!col_max() := 2,
  !!col_max_jitter() := 2.2
))
