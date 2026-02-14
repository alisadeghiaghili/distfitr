# Tests for distribution system

test_that("get_distribution works for all distributions", {
  distributions <- c("normal", "lognormal", "gamma", "weibull", 
                    "exponential", "beta", "uniform", "studentt", 
                    "pareto", "gumbel")
  
  for (dist in distributions) {
    dist_obj <- get_distribution(dist)
    
    expect_s3_class(dist_obj, "distfitr_distribution")
    expect_true(!is.null(dist_obj$name))
    expect_true(!is.null(dist_obj$dfunc))
    expect_true(!is.null(dist_obj$pfunc))
    expect_true(!is.null(dist_obj$qfunc))
    expect_true(!is.null(dist_obj$rfunc))
  }
})

test_that("get_distribution fails for invalid distribution", {
  expect_error(get_distribution("invalid_dist"))
  expect_error(get_distribution(123))
  expect_error(get_distribution(NULL))
})

test_that("list_distributions returns all 10 distributions", {
  dist_list <- list_distributions()
  
  expect_type(dist_list, "character")
  expect_length(dist_list, 10)
  expect_true("normal" %in% dist_list)
  expect_true("pareto" %in% dist_list)
  expect_true("gumbel" %in% dist_list)
})

test_that("distribution functions work correctly", {
  # Normal distribution
  dist <- get_distribution("normal")
  
  # Test PDF
  pdf_val <- dist$dfunc(0, mean = 0, sd = 1)
  expect_true(pdf_val > 0)
  expect_true(is.finite(pdf_val))
  
  # Test CDF
  cdf_val <- dist$pfunc(0, mean = 0, sd = 1)
  expect_equal(cdf_val, 0.5, tolerance = 1e-10)
  
  # Test quantile
  q_val <- dist$qfunc(0.5, mean = 0, sd = 1)
  expect_equal(q_val, 0, tolerance = 1e-10)
  
  # Test random generation
  set.seed(42)
  random_vals <- dist$rfunc(100, mean = 0, sd = 1)
  expect_length(random_vals, 100)
  expect_true(all(is.finite(random_vals)))
})

test_that("Pareto distribution works correctly", {
  dist <- get_distribution("pareto")
  
  # PDF should work
  pdf_val <- dist$dfunc(2, scale = 1, shape = 2)
  expect_true(pdf_val > 0)
  expect_true(is.finite(pdf_val))
  
  # CDF at scale should be 0
  cdf_val <- dist$pfunc(1, scale = 1, shape = 2)
  expect_equal(cdf_val, 0, tolerance = 1e-10)
  
  # Random generation
  set.seed(42)
  random_vals <- dist$rfunc(100, scale = 1, shape = 2)
  expect_length(random_vals, 100)
  expect_true(all(random_vals >= 1))  # Pareto is bounded below by scale
})

test_that("Gumbel distribution works correctly", {
  dist <- get_distribution("gumbel")
  
  # PDF should work
  pdf_val <- dist$dfunc(0, location = 0, scale = 1)
  expect_true(pdf_val > 0)
  expect_true(is.finite(pdf_val))
  
  # CDF at location should be ~0.368
  cdf_val <- dist$pfunc(0, location = 0, scale = 1)
  expect_equal(cdf_val, exp(-1), tolerance = 1e-6)
  
  # Random generation
  set.seed(42)
  random_vals <- dist$rfunc(100, location = 0, scale = 1)
  expect_length(random_vals, 100)
  expect_true(all(is.finite(random_vals)))
})
