test_that("different benchmarks output different number of rows", {
  x <- tidyr::expand_grid(
    !!col_benchmark() := c("all", col_unit(), col_tsector(), unit(col_tsector())),
    !!col_risk_category_emissions() := c("low", "medium", "high"),
    !!col_unit() := c("m2", "kg"),
    !!col_tsector() := c("sector1", "sector2"),
    !!col_tsubsector() := c("subsector1", "subsector2"),
  )
  y <- tibble(
    !!col_risk_category_emissions() := c("low", "medium", "high"),
    !!col_isic() := "'1234'",
    !!col_footprint() := 1:3,
  )
  data <- left_join(
    x, y,
    by = col_risk_category_emissions(),
    relationship = "many-to-many"
  )

  benchmark <- "all"
  expected <- 3
  # 3 = 3 emission_profile
  out <- summarize_range_by_benchmark(data)
  expect_equal(
    nrow(filter(out, .data[[col_benchmark()]] == .env$benchmark)),
    expected
  )

  benchmark <- col_unit()
  expected <- 6
  # 6 = 3 emission_profile * 2 unit
  out <- summarize_range_by_benchmark(data)
  expect_equal(
    nrow(filter(out, .data[[col_benchmark()]] == .env$benchmark)),
    expected
  )

  benchmark <- col_tsector()
  expected <- 12
  # 12 = 3 emission_profile * 2 tilt_sector * 2 tilt_subsector
  out <- summarize_range_by_benchmark(data)
  expect_equal(
    nrow(filter(out, .data[[col_benchmark()]] == .env$benchmark)),
    expected
  )

  benchmark <- unit(col_tsector())
  expected <- 24
  # 24 = 3 emission_profile * 2 tilt_sector * 2 tilt_subsector * 2 unit
  out <- summarize_range_by_benchmark(data)
  expect_equal(
    nrow(filter(out, .data[[col_benchmark()]] == .env$benchmark)),
    expected
  )
})

test_that("with a simple case yields the same as `summarize_range()` (#214#issuecomment-2061180499)", {
  data <- toy_summarize_range_by_benchmark(
    !!col_risk_category_emissions() := c("low", "medium"),
    !!col_footprint() := c(1:2),
    !!col_tsubsector() := paste0("subsector", 1:2)
  )

  expect_equal(
    summarize_range(
      data,
      col_footprint(),
      .by = c(col_benchmark(), col_risk_category_emissions())
    ),
    summarize_range_by_benchmark(data)
  )
})

test_that("is vectorized over `benchmark`", {
  data <- toy_summarize_range_by_benchmark(
    !!col_benchmark() := c("all", col_unit())
  )

  out <- summarize_range_by_benchmark(data)
  expect_equal(unique(out$benchmark), c("all", col_unit()))
})

test_that("without crucial columns errors gracefully", {
  benchmarks <- c(
    col_unit(),
    col_tsector(),
    col_tsubsector(),
    col_isic()
  )
  data <- toy_summarize_range_by_benchmark(
    !!col_benchmark() := c("all", benchmarks)
  )

  crucial <- col_unit()
  bad <- select(data, -all_of(crucial))
  expect_error(summarize_range_by_benchmark(bad), crucial)

  crucial <- col_tsector()
  bad <- select(data, -all_of(crucial))
  expect_error(summarize_range_by_benchmark(bad), crucial)

  crucial <- col_tsubsector()
  bad <- select(data, -all_of(crucial))
  expect_error(summarize_range_by_benchmark(bad), crucial)

  crucial <- col_isic()
  bad <- select(data, -all_of(crucial))
  expect_error(summarize_range_by_benchmark(bad), crucial)

  # Other crucial columns

  crucial <- col_benchmark()
  bad <- select(data, -all_of(crucial))
  expect_error(summarize_range_by_benchmark(bad), class = "check_matches_name")

  crucial <- col_risk_category_emissions()
  bad <- select(data, -all_of(crucial))
  expect_error(summarize_range_by_benchmark(bad), class = "check_matches_name")

  crucial <- col_footprint()
  bad <- select(data, -all_of(crucial))
  expect_error(summarize_range_by_benchmark(bad), crucial)
})
