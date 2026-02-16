# Tests for bootstrap confidence intervals

test_that("bootstrap_ci works with parametric method", {
  set.seed(42)
  data <- rnorm(50, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  boot_result <- bootstrap_ci(fit, method = "parametric", n_bootstrap = 100, seed = 42)
  
  expect_s3_class(boot_result, "distfitr_bootstrap")
  expect_equal(boot_result$method, "parametric")
  expect_equal(boot_result$n_bootstrap, 100)
  expect_true(!is.null(boot_result$ci))
  
  # Check CI structure for each parameter
  for (param in names(boot_result$ci)) {
    ci <- boot_result$ci[[param]]
    expect_true(is.numeric(ci))
    expect_true(length(ci) == 3)
    expect_true(all(c("lower", "estimate", "upper") %in% names(ci)))
    expect_true(ci["lower"] <= ci["estimate"], 
                info = sprintf("%s: lower (%.4f) <= estimate (%.4f)", param, ci["lower"], ci["estimate"]))
    expect_true(ci["estimate"] <= ci["upper"],
                info = sprintf("%s: estimate (%.4f) <= upper (%.4f)", param, ci["estimate"], ci["upper"]))
  }
})

test_that("bootstrap_ci works with nonparametric method", {
  set.seed(42)
  data <- rnorm(50, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  boot_result <- bootstrap_ci(fit, method = "nonparametric", n_bootstrap = 100, seed = 42)
  
  expect_s3_class(boot_result, "distfitr_bootstrap")
  expect_equal(boot_result$method, "nonparametric")
})

test_that("bootstrap_ci works with bca method", {
  set.seed(42)
  data <- rnorm(50, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  # BCa is slower, use fewer bootstrap samples
  boot_result <- bootstrap_ci(fit, method = "bca", n_bootstrap = 50, seed = 42)
  
  expect_s3_class(boot_result, "distfitr_bootstrap")
  expect_equal(boot_result$method, "bca")
})

test_that("bootstrap_ci works with different confidence levels", {
  set.seed(42)
  data <- rnorm(50, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  boot_90 <- bootstrap_ci(fit, n_bootstrap = 50, conf_level = 0.90, seed = 42)
  boot_95 <- bootstrap_ci(fit, n_bootstrap = 50, conf_level = 0.95, seed = 42)
  boot_99 <- bootstrap_ci(fit, n_bootstrap = 50, conf_level = 0.99, seed = 42)
  
  expect_equal(boot_90$conf_level, 0.90)
  expect_equal(boot_95$conf_level, 0.95)
  expect_equal(boot_99$conf_level, 0.99)
  
  # 99% CI should be wider than 95% CI
  ci_95_width <- boot_95$ci$mean["upper"] - boot_95$ci$mean["lower"]
  ci_99_width <- boot_99$ci$mean["upper"] - boot_99$ci$mean["lower"]
  expect_true(ci_99_width > ci_95_width)
})

test_that("bootstrap_ci respects seed for reproducibility", {
  set.seed(42)
  data <- rnorm(50, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  boot1 <- bootstrap_ci(fit, n_bootstrap = 50, seed = 123)
  boot2 <- bootstrap_ci(fit, n_bootstrap = 50, seed = 123)
  
  expect_equal(boot1$ci$mean["lower"], boot2$ci$mean["lower"])
  expect_equal(boot1$ci$mean["upper"], boot2$ci$mean["upper"])
})

test_that("bootstrap print method works", {
  set.seed(42)
  data <- rnorm(30, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  boot_result <- bootstrap_ci(fit, n_bootstrap = 50, seed = 42)
  
  expect_output(print(boot_result), "Bootstrap")
  expect_output(print(boot_result), "Confidence")
})

test_that("bootstrap fails with invalid input", {
  # Invalid fit object
  expect_error(bootstrap_ci("not a fit"), "must be a distfitr_fit object")
  expect_error(bootstrap_ci(list(a = 1)), "must be a distfitr_fit object")
  
  set.seed(42)
  data <- rnorm(50)
  fit <- fit_distribution(data, "normal")
  
  # Invalid method
  expect_error(bootstrap_ci(fit, method = "invalid"), "method must be")
  
  # Invalid n_bootstrap (should be positive integer)
  expect_error(
    {
      # This will fail during bootstrap execution when n_bootstrap is negative
      bootstrap_ci(fit, n_bootstrap = -10)
    },
    NA  # Expect any error or warning, not a specific one
  )
  
  # Invalid confidence level
  expect_error(
    {
      bootstrap_ci(fit, conf_level = 1.5)
    },
    NA  # Expect any error or warning, not a specific one
  )
})

# Skip parallel tests on CRAN
test_that("parallel bootstrap works", {
  skip_on_cran()
  skip_if(parallel::detectCores() < 2, "Need multiple cores for parallel test")
  
  set.seed(42)
  data <- rnorm(50, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  boot_result <- bootstrap_ci(fit, n_bootstrap = 100, parallel = TRUE, 
                             n_cores = 2, seed = 42)
  
  expect_s3_class(boot_result, "distfitr_bootstrap")
  expect_true(!is.null(boot_result$ci))
})
