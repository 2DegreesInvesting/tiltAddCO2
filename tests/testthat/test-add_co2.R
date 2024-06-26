test_that("at product level, different values of co2 footprint yield different values in the jittered range of co2 footprint (#214#issuecomment-2086975144)", {
  # From reprex 2 at https://github.com/2DegreesInvesting/tiltIndicatorAfter/pull/214#issuecomment-2086975144
  .id <- c("ironhearted_tarpan", "epitaphic_yellowhammer")
  profile <- toy_profile_emissions_impl_output() |>
    filter(.data[[col_company_id()]] %in% .id)
  co2 <- read_csv(toy_emissions_profile_products_ecoinvent())

  out <- profile |> add_co2(co2)

  cols <- c(
    col_company_id(),
    col_unit(),
    col_benchmark(),
    col_risk_category_emissions(),
    col_footprint(),
    paste0(anchor(col_min()), "|", anchor(col_min_jitter())),
    paste0(anchor(col_max()), "|", anchor(col_max_jitter())),
    col_tsector(),
    col_tsubsector(),
    col_isic()
  )
  product <- out |>
    unnest_product() |>
    filter(.data[[col_benchmark()]] == col_unit()) |>
    filter(.data[[col_risk_category_emissions()]] == "high") |>
    select(matches(cols))

  # Units with different footprint ...
  expect_false(identical(
    pull(filter(product, unit == "kg"), col_footprint()),
    pull(filter(product, unit == "m2"), col_footprint())
  ))

  # yield different jittered footprint
  expect_false(identical(
    pull(filter(product, unit == "kg"), col_min_jitter()),
    pull(filter(product, unit == "m2"), col_min_jitter())
  ))
})

test_that("different risk categories yield different min and max (#214#issuecomment-2059645683)", {
  # https://github.com/2DegreesInvesting/tiltIndicatorAfter/pull/214#issuecomment-2059645683
  # > it should actually vary across risk categories (the idea is that the
  # > co2e_lower and _upper shows the lowest/highest value in each risk_category).
  # > -- Tilman
  #
  # Instead of the jittered columns, I test min/max because testing equality for
  # jittered values is impossible, and testing proximity (e.g. with
  # `dplyr::near()`) is hard. This simpler test is most likely enough to avoid
  # a regression.

  co2 <- read_csv(toy_emissions_profile_products_ecoinvent())
  profile <- toy_profile_emissions_impl_output()

  relevant_pattern <- c(
    col_benchmark(),
    pattern_risk_category_emissions_any(),
    col_footprint(),
    col_footprint_mean(),
    anchor(col_min()),
    anchor(col_max())
  )

  .benchmark <- "all"
  pick <- profile |>
    add_co2(co2) |>
    unnest_product() |>
    filter(.data[[col_benchmark()]] %in% .benchmark) |>
    filter(emission_profile == c("high", "low")) |>
    select(matches(relevant_pattern)) |>
    distinct()

  # different risk category has different min
  col <- col_risk_category_emissions()
  low_min <- pick |>
    filter(.data[[col]] == "low") |>
    pull(col_min())
  high_min <- pick |>
    filter(.data[[col]] == "high") |>
    pull(col_min())
  expect_false(identical(low_min, high_min))

  # different risk category has different max
  low_max <- pick |>
    filter(.data[[col]] == "low") |>
    pull(col_max())
  high_max <- pick |>
    filter(.data[[col]] == "high") |>
    pull(col_max())
  expect_false(identical(low_max, high_max))

  .benchmark <- col_unit()
  pick <- profile |>
    add_co2(co2) |>
    unnest_product() |>
    filter(.data[[col_benchmark()]] %in% .benchmark) |>
    filter(emission_profile == c("high", "low")) |>
    select(matches(relevant_pattern)) |>
    distinct()

  # different risk category has different min
  col <- col_risk_category_emissions()
  low_min <- pick |>
    filter(.data[[col]] == "low") |>
    pull(col_min())
  high_min <- pick |>
    filter(.data[[col]] == "high") |>
    pull(col_min())
  expect_false(identical(low_min, high_min))

  # different risk category has different max
  low_max <- pick |>
    filter(.data[[col]] == "low") |>
    pull(col_max())
  high_max <- pick |>
    filter(.data[[col]] == "high") |>
    pull(col_max())
  expect_false(identical(low_max, high_max))
})

test_that("at company level, yields the expected number of rows with benchmark 'all' ", {
  co2 <- read_csv(toy_emissions_profile_products_ecoinvent())
  profile <- toy_profile_emissions_impl_output()[1:2, ]

  out <- profile |> add_co2(co2)

  grouped_by <- "all"
  # "high", "medium", "low", NA
  n_risk_category <- 4
  expected <- n_risk_category

  company <- out |>
    unnest_company() |>
    filter(.data[[col_company_id()]] %in% .data[[col_company_id()]][[1]]) |>
    filter(.data[[col_benchmark()]] == grouped_by)

  expect_equal(nrow(company), expected)
})

test_that("at company level, yields the expected number of rows with benchmark 'unit'", {
  co2 <- read_csv(toy_emissions_profile_products_ecoinvent())
  profile <- toy_profile_emissions_impl_output()[1:20, ]

  out <- profile |> add_co2(co2)

  grouped_by <- col_unit()
  # "high", "medium", "low", NA
  n_risk_category <- 4
  all <- c(col_benchmark(), col_risk_category_emissions())
  groups <- group_benchmark(col_unit(), all)[[1]]
  n_unit <- out |>
    unnest_product() |>
    filter(.data[[col_company_id()]] %in% .data[[col_company_id()]][[1]]) |>
    filter(.data[[col_benchmark()]] == grouped_by) |>
    select(all_of(groups)) |>
    distinct() |>
    nrow()
  expected <- n_risk_category * n_unit

  company <- out |>
    unnest_company() |>
    filter(.data[[col_company_id()]] %in% .data[[col_company_id()]][[1]]) |>
    filter(.data[[col_benchmark()]] == grouped_by)

  expect_equal(nrow(company), expected)
})

test_that("at product level, has co2 footprint", {
  co2 <- read_csv(toy_emissions_profile_products_ecoinvent())
  profile <- toy_profile_emissions_impl_output()

  out <- profile |> add_co2(co2)
  expect_true(hasName(unnest_product(out), col_footprint()))
})

test_that("at company level, lacks co2 footprint", {
  co2 <- read_csv(toy_emissions_profile_products_ecoinvent())
  profile <- toy_profile_emissions_impl_output()

  out <- profile |> add_co2(co2)
  expect_false(hasName(unnest_company(out), col_footprint()))
})

test_that("at product level, has min and max", {
  co2 <- read_csv(toy_emissions_profile_products_ecoinvent())
  profile <- toy_profile_emissions_impl_output()

  out <- profile |> add_co2(co2)
  expect_true(hasName(unnest_product(out), col_min()))
  expect_true(hasName(unnest_product(out), col_max()))
})

test_that("at company level, lacks min and max", {
  co2 <- read_csv(toy_emissions_profile_products_ecoinvent())
  profile <- toy_profile_emissions_impl_output()

  out <- profile |> add_co2(co2)
  expect_false(hasName(unnest_company(out), col_min()))
  expect_false(hasName(unnest_company(out), col_max()))
})

test_that("at product level, has the jittered range of co2 footprint", {
  co2 <- read_csv(toy_emissions_profile_products_ecoinvent())
  profile <- toy_profile_emissions_impl_output()

  out <- profile |> add_co2(co2)
  expect_true(hasName(out |> unnest_product(), col_min_jitter()))
  expect_true(hasName(out |> unnest_product(), col_max_jitter()))
})

test_that("at product level, the jittered range of co2 footprint isn't full of `NA`s", {
  co2 <- read_csv(toy_emissions_profile_products_ecoinvent())
  profile <- toy_profile_emissions_impl_output()

  out <- profile |> add_co2(co2)

  product <- unnest_product(out)
  expect_false(all(is.na(product[[col_min_jitter()]])))
  expect_false(all(is.na(product[[col_max_jitter()]])))
})

test_that("at company level, has the average co2 footprint", {
  co2 <- read_csv(toy_emissions_profile_products_ecoinvent())
  profile <- toy_profile_emissions_impl_output()

  out <- profile |> add_co2(co2)
  expect_true(hasName(out |> unnest_company(), col_footprint_mean()))
})
