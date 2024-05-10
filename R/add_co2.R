#' Add a the jittered range of CO2 values
#'
#' @inheritParams tiltIndicator::tilt_profile
#' @param co2 See `co2` in [tiltIndicator::emissions_profile()].
#' @param jitter_amount Numeric. Controls the amount of noise. Passed to
#'   `amount` in [tiltIndicator::jitter_range()].
#'
#' @return An object of the same class as `data`.
#' @export
#'
#' @examples
#' library(dplyr, warn.conflicts = FALSE)
#' library(readr)
#' library(tiltToyData)
#' library(tiltIndicatorAfter)
#' library(tiltAddCO2)
#'
#' file <- toy_emissions_profile_products_ecoinvent()
#' co2 <- read_csv(file, show_col_types = FALSE)
#' profile <- toy_profile_emissions_impl_output()
#'
#' with_co2 <- profile |>
#'   add_co2(co2)
#'
#' with_co2 |>
#'   unnest_product() |>
#'   relocate(matches("co2"))
#'
#' with_co2 |>
#'   unnest_company() |>
#'   relocate(matches("co2"))
add_co2 <- function(data, co2, jitter_amount = NULL) {
  data_co2 <- data |>
    add_co2_footprint(co2) |>
    add_co2_footprint_mean()

  product <- data_co2 |>
    unnest_product() |>
    split_summarize_range_by_benchmark() |>
    map(\(.x) jitter_range_by_benchmark(.x, amount = jitter_amount)) |>
    map(\(.x) join_to(.x, unnest_product(data_co2))) |>
    reduce(bind_rows) |>
    prune_useless_rows_introduced_when_binding_disparate_columns() |>
    restore_missing_products_from(profile = data)

  company <- data_co2 |>
    unnest_company()

  tilt_profile(nest_levels(product, company))
}

add_co2_footprint <- function(data, co2) {
  product <- data |>
    unnest_product() |>
    left_join(
      co2 |> select_product_id_and_footprint(),
      by = col_product_id(),
      relationship = "many-to-many"
    )
  company <- data |>
    unnest_company()

  tilt_profile(nest_levels(product, company))
}

select_product_id_and_footprint <- function(data) {
  select(data, matches(c(col_product_id(), col_footprint())))
}

add_co2_footprint_mean <- function(data, name = "co2_avg") {
  product <- data |>
    unnest_product()

  by <- c(col_company_id(), col_benchmark())
  footprint <- extract_name(product, col_footprint())

  footprint_mean <- product |>
    select(all_of(by), matches(col_footprint())) |>
    summarise(
      {{ name }} := round(mean(.data[[footprint]], na.rm = TRUE), 3),
      .by = all_of(by)
    )
  company <- data |>
    unnest_company() |>
    left_join(footprint_mean, by = by, relationship = "many-to-many")

  tilt_profile(nest_levels(product, company))
}

prune_useless_rows_introduced_when_binding_disparate_columns <- function(data) {
  filter(data, !is.na(.data[["min_jitter"]]) | !is.na(.data[["max_jitter"]]))
}

restore_missing_products_from <- function(data, profile) {
  product <- unnest_product(profile)
  product_missing <- pick_missing_risk_category(product)
  bind_rows(data, product_missing)
}

pick_missing_risk_category <- function(data) {
  .col <- extract_name(data, pattern_risk_category_emissions_any())
  filter(data, is.na(.data[[.col]]))
}
