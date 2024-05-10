test_that("if min/max increases across risk categories, *jittered increases too (#214#issuecomment-2061180499)", {
  data <- toy_jitter_range_range_by_benchmark(
    !!col_risk_category_emissions() := c("low", "high"),
    !!col_min() := c(1, 3),
    !!col_max() := c(2, 4)
  )

  out <- jitter_range_by_benchmark(data)

  # Ensure min and max are strictly increasing
  strictly_increasing <- function(x) all(diff(x) > 0)
  stopifnot(strictly_increasing(data$min) & strictly_increasing(data$max))

  expect_true(strictly_increasing(out[[col_min_jitter()]]))
  expect_true(strictly_increasing(out[[col_max_jitter()]]))
})

test_that("if min/max increases across benchmarks, *jittered increases too (#214#issuecomment-2061180499)  ", {
  data <- toy_jitter_range_range_by_benchmark(
    !!col_benchmark() := c("all", col_unit()),
    !!col_min() := c(1, 3),
    !!col_max() := c(2, 4),
    !!col_unit() := c(NA, "m2")
  )

  out <- jitter_range_by_benchmark(data)

  # Ensure min and max are strictly increasing
  strictly_increasing <- function(x) all(diff(x) > 0)
  stopifnot(strictly_increasing(data$min) & strictly_increasing(data$max))

  expect_true(strictly_increasing(out[[col_min_jitter()]]))
  expect_true(strictly_increasing(out[[col_max_jitter()]]))
})

test_that("adds columns `min_jitter` and `max_jitter`", {
  data <- toy_jitter_range_range_by_benchmark()

  out <- jitter_range_by_benchmark(data)
  expect_named(out, c(names(data), c(col_min_jitter(), col_max_jitter())))
})

test_that("without crucial columns errors gracefully", {
  data <- toy_jitter_range_range_by_benchmark()

  expect_error(jitter_range_by_benchmark(data |> select(-benchmark)), "benchmark.*not")
  expect_error(jitter_range_by_benchmark(data |> select(-min)), "missing.*min")
  expect_error(jitter_range_by_benchmark(data |> select(-max)), "missing.*max")
})

test_that("yields `min*` smaller than `max*`", {
  data <- toy_jitter_range_range_by_benchmark()

  out <- jitter_range_by_benchmark(data)
  expect_true(all(out[[col_min_jitter()]] < out[[col_max_jitter()]]))
})

test_that("is sensitive to `amount`", {
  data <- toy_jitter_range_range_by_benchmark()

  local_seed(1)
  small <- jitter_range_by_benchmark(data, amount = 0.1)
  large <- jitter_range_by_benchmark(data, amount = 100)

  # Increase `amount` to get more extreeme min/max_jitter
  expect_true(large[[col_min_jitter()]] < small[[col_min_jitter()]])
  expect_true(small[[col_max_jitter()]] < large[[col_max_jitter()]])
})
