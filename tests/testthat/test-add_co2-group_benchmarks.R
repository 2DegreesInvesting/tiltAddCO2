test_that("with products-benchmarks, outpts the expected groups", {
  product_benchmarks <- c(
    "all",
    col_unit(),
    col_tsector(),
    "unit_tilt_sector",
    col_isic(),
    "unit_isic_4digit"
  )
  all <- c(col_benchmark(), col_risk_category_emissions())
  expect_snapshot(group_benchmark(product_benchmarks, all))
})

test_that("with inputs-benchmarks, outpts the expected groups", {
  input_benchmark <- c(
    "all",
    input(col_isic()),
    input(col_tsector()),
    input(col_unit()),
    input(unit(input(col_isic()))),
    input(unit(input(col_tsector())))
  )
  all <- c(col_benchmark(), "emission_upstream_profile")

  expect_snapshot(group_benchmark(input_benchmark, all))
})

test_that("is sensitive to `all`", {
  out <- group_benchmark(col_unit(), all = "x")
  expect_equal(out[[1]], c("x", col_unit()))

  out <- group_benchmark(col_unit(), all = "y")
  expect_equal(out[[1]], c("y", col_unit()))
})

test_that("after `all`, the output is alpha sorted", {
  benchmarks <- c(
    "all",
    col_unit(),
    col_tsector(),
    "unit_tilt_sector",
    col_isic(),
    "unit_isic_4digit"
  )

  .all <- "z"
  out <- group_benchmark(benchmarks, all = .all)
  other <- lapply(out, setdiff, "z")
  sorted <- lapply(other, sort)

  expect_equal(other, sorted)
})

test_that("can drop missing values", {
  # Similar to `?split()`: Any missing values in f are dropped together with the
  # corresponding values of x.
  expect_equal(
    group_benchmark(c("all", NA_character_), "all", na.rm = TRUE),
    group_benchmark(c("all"), "all")
  )
})
