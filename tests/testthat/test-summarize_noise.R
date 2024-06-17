test_that("without crucial columns errors gracefully", {
  data <- toy_summarize_noise()
  crucial <- "min"
  bad <- select(data, -all_of(crucial))
  expect_snapshot(error = TRUE, summarize_noise(bad))

  crucial <- "max"
  bad <- select(data, -all_of(crucial))
  expect_snapshot(error = TRUE, summarize_noise(bad))

  crucial <- "min_jitter"
  bad <- select(data, -all_of(crucial))
  expect_snapshot(error = TRUE, summarize_noise(bad))

  crucial <- "max_jitter"
  bad <- select(data, -all_of(crucial))
  expect_snapshot(error = TRUE, summarize_noise(bad))
})

test_that("yields columns `min_noise` and `max_noise`", {
  data <- toy_summarize_noise()
  out <- summarize_noise(data)
  expect_true(hasName(out, "min_noise"))
  expect_true(hasName(out, "max_noise"))
})

test_that("yields a summary, so fewer rows than the input data", {
  data <- toy_summarize_noise(!!col_min() := 1:2)
  out <- summarize_noise(data)
  expect_true(nrow(out) < nrow(data))
})

test_that("yields the expected percent noise", {
  data <- toy_summarize_noise()
  out <- summarize_noise(data)
  # Toy `data` designed with these expectations
  expect_equal(out$min_noise, 20)
  expect_equal(out$max_noise, 10)
})

test_that("drops missing values", {
  data <- toy_summarize_noise(!!col_min() := c(1, NA))
  out <- summarize_noise(data)
  expect_false(anyNA(out))
})

test_that("is sensitive to .by", {
  data <- toy_summarize_noise(group = 1)
  expect_no_error(summarize_noise(data, .by = "group"))
})

test_that("yields the expected percent noise by group", {
  data <- bind_rows(
    # This dataset has 20% and 10% noise in min and max respectively
    toy_summarize_noise(g = 1),
    # This dataset has 10% and 10% noise in min and max respectively
    toy_summarize_noise(g = 2, !!col_min_jitter() := 0.9)
  )

  out <- summarize_noise(data, .by = "g")

  expect_equal(out[1, ][["min_noise"]], 20)
  expect_equal(out[1, ][["max_noise"]], 10)

  expect_equal(out[2, ][["min_noise"]], 10)
  expect_equal(out[2, ][["max_noise"]], 10)
})
