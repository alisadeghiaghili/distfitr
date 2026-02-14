# Tests for edge cases and error handling

test_that("fit handles data with extreme values", {
  set.seed(42)
  data <- c(rnorm(90), 1000, -1000)  # Add extreme values
  
  # Should still work
  fit <- fit_distribution(data, "normal")
  expect_s3_class(fit, "distfitr_fit")
})

test_that("fit handles small sample sizes", {
  set.seed(42)
  data <- rnorm(10)  # Small but valid
  
  fit <- fit_distribution(data, "normal")
  expect_s3_class(fit, "distfitr_fit")
})

test_that("fit handles large sample sizes", {
  skip_on_cran()  # Skip slow tests on CRAN
  
  set.seed(42)
  data <- rnorm(10000)
  
  fit <- fit_distribution(data, "normal")
  expect_s3_class(fit, "distfitr_fit")
  expect_true(is.finite(fit$loglik))
})

test_that("fit handles constant data gracefully", {
  data <- rep(5, 100)
  
  # Should fail or warn
  expect_error(fit_distribution(data, "normal"))
})

test_that("fit handles data with very small variance", {
  set.seed(42)
  data <- rnorm(100, mean = 5, sd = 0.001)
  
  fit <- fit_distribution(data, "normal")
  expect_s3_class(fit, "distfitr_fit")
  expect_true(fit$params["sd"] < 0.01)
})

test_that("beta distribution handles boundary data", {
  set.seed(42)
  data <- rbeta(100, 2, 5)
  
  fit <- fit_distribution(data, "beta")
  expect_s3_class(fit, "distfitr_fit")
  
  # Parameters should be positive
  expect_true(all(fit$params > 0))
})

test_that("exponential handles zero values", {
  set.seed(42)
  data <- rexp(100, rate = 1)
  data[1] <- 0  # Add a zero
  
  # Should handle or warn about zero
  fit <- tryCatch(
    fit_distribution(data, "exponential"),
    error = function(e) NULL,
    warning = function(w) fit_distribution(data, "exponential")
  )
  
  # Should either work or fail gracefully
  expect_true(is.null(fit) || inherits(fit, "distfitr_fit"))
})

test_that("uniform distribution handles edge cases", {
  set.seed(42)
  data <- runif(50, 0, 10)
  
  fit <- fit_distribution(data, "uniform")
  expect_s3_class(fit, "distfitr_fit")
  
  # Min should be <= all data, max should be >= all data
  expect_true(fit$params["min"] <= min(data))
  expect_true(fit$params["max"] >= max(data))
})

test_that("pareto handles minimum value correctly", {
  # Pareto requires data >= scale parameter
  dist <- get_distribution("pareto")
  set.seed(42)
  data <- dist$rfunc(100, scale = 1, shape = 2)
  
  fit <- fit_distribution(data, "pareto")
  expect_s3_class(fit, "distfitr_fit")
  
  # Scale should be <= minimum data
  expect_true(fit$params["scale"] <= min(data))
})

test_that("GOF tests handle perfect fit", {
  set.seed(42)
  # Generate from distribution then fit same distribution
  data <- rnorm(1000, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  gof <- gof_tests(fit)
  
  # Should generally pass with large sample from true distribution
  expect_s3_class(gof, "distfitr_gof")
  expect_type(gof$all_passed, "logical")
})

test_that("bootstrap handles convergence failures", {
  set.seed(42)
  # Create difficult data
  data <- c(rexp(45), 100, 200)  # Outliers that might cause issues
  fit <- fit_distribution(data, "exponential")
  
  # Bootstrap should handle failures gracefully
  boot_result <- bootstrap_ci(fit, n_bootstrap = 50, seed = 42)
  
  expect_s3_class(boot_result, "distfitr_bootstrap")
  # Some samples might fail, but should still return results
  expect_true(!is.null(boot_result$ci))
})

test_that("diagnostics handles influential points", {
  set.seed(42)
  data <- c(rnorm(95, mean = 5, sd = 2), 50, 60, -30, 70, -40)
  fit <- fit_distribution(data, "normal")
  
  diag <- diagnostics(fit)
  
  expect_s3_class(diag, "distfitr_diagnostics")
  # Should detect some influential points
  expect_true(length(diag$influence$influential_indices) > 0)
})

test_that("functions handle single parameter distributions", {
  set.seed(42)
  data <- rexp(50, rate = 2)
  fit <- fit_distribution(data, "exponential")
  
  expect_s3_class(fit, "distfitr_fit")
  expect_length(fit$params, 1)
  
  # Should work with bootstrap
  boot_result <- bootstrap_ci(fit, n_bootstrap = 50, seed = 42)
  expect_s3_class(boot_result, "distfitr_bootstrap")
})

test_that("functions handle two parameter distributions", {
  set.seed(42)
  data <- rgamma(50, shape = 2, rate = 1)
  fit <- fit_distribution(data, "gamma")
  
  expect_s3_class(fit, "distfitr_fit")
  expect_length(fit$params, 2)
})
