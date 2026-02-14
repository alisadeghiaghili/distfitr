# Tests for diagnostics

test_that("diagnostics works with default parameters", {
  set.seed(42)
  data <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  diag <- diagnostics(fit)
  
  expect_s3_class(diag, "distfitr_diagnostics")
  expect_true(!is.null(diag$residuals))
  expect_true(!is.null(diag$influence))
  expect_true(!is.null(diag$outliers))
  expect_true(!is.null(diag$qq_data))
  expect_true(!is.null(diag$pp_data))
})

test_that("calculate_residuals works for all types", {
  set.seed(42)
  data <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  residual_types <- c("quantile", "pearson", "deviance", "standardized")
  
  for (rtype in residual_types) {
    resid <- calculate_residuals(fit, type = rtype)
    
    expect_type(resid, "double")
    expect_length(resid, 100)
    expect_true(all(is.finite(resid)))
  }
})

test_that("calculate_influence returns proper structure", {
  set.seed(42)
  data <- rnorm(50, mean = 5, sd = 2)  # Smaller sample for speed
  fit <- fit_distribution(data, "normal")
  
  influence <- calculate_influence(fit)
  
  expect_type(influence, "list")
  expect_true(!is.null(influence$cooks_distance))
  expect_true(!is.null(influence$leverage))
  expect_true(!is.null(influence$dffits))
  expect_true(!is.null(influence$influential_indices))
  
  expect_length(influence$cooks_distance, 50)
})

test_that("detect_outliers works with all methods", {
  set.seed(42)
  data <- c(rnorm(95, mean = 5, sd = 2), 50, 60, -30, 70, -40)  # Add outliers
  fit <- fit_distribution(data, "normal")
  
  # Test individual methods
  methods <- c("zscore", "iqr", "likelihood", "mahalanobis")
  
  for (method in methods) {
    outliers <- detect_outliers(fit, method = method)
    
    expect_type(outliers, "list")
    expect_true(!is.null(outliers$method))
    expect_true(!is.null(outliers$outlier_indices))
    expect_true(!is.null(outliers$n_outliers))
  }
})

test_that("detect_outliers 'all' method provides consensus", {
  set.seed(42)
  data <- c(rnorm(95, mean = 5, sd = 2), 50, 60, -30, 70, -40)
  fit <- fit_distribution(data, "normal")
  
  outliers_all <- detect_outliers(fit, method = "all")
  
  expect_type(outliers_all, "list")
  expect_true(!is.null(outliers_all$zscore))
  expect_true(!is.null(outliers_all$iqr))
  expect_true(!is.null(outliers_all$likelihood))
  expect_true(!is.null(outliers_all$mahalanobis))
  expect_true(!is.null(outliers_all$consensus))
  
  # Consensus should have fewer or equal outliers than individual methods
  expect_true(outliers_all$consensus$n_outliers <= 
              max(outliers_all$zscore$n_outliers,
                  outliers_all$iqr$n_outliers,
                  outliers_all$likelihood$n_outliers,
                  outliers_all$mahalanobis$n_outliers))
})

test_that("diagnostics print method works", {
  set.seed(42)
  data <- rnorm(50, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  diag <- diagnostics(fit)
  
  expect_output(print(diag), "Diagnostics")
  expect_output(print(diag), "Residuals")
})

test_that("diagnostics plot method works without error", {
  skip_on_cran()  # Skip plotting tests on CRAN
  
  set.seed(42)
  data <- rnorm(50, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  diag <- diagnostics(fit)
  
  expect_silent(plot(diag))
})

test_that("diagnostics fails with invalid input", {
  expect_error(diagnostics("not a fit"))
  expect_error(diagnostics(list(a = 1)))
})

test_that("residuals are approximately normal for good fit", {
  set.seed(42)
  data <- rnorm(200, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  resid <- calculate_residuals(fit, type = "quantile")
  
  # Quantile residuals should be approximately N(0,1)
  expect_equal(mean(resid), 0, tolerance = 0.2)
  expect_equal(sd(resid), 1, tolerance = 0.2)
})
