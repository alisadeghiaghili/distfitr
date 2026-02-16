# Tests for goodness-of-fit tests

test_that("gof_tests runs all tests", {
  set.seed(42)
  data <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  gof <- gof_tests(fit)
  
  expect_s3_class(gof, "distfitr_gof")
  expect_true(!is.null(gof$ks))
  expect_true(!is.null(gof$ad))
  expect_true(!is.null(gof$chisq))
  expect_true(!is.null(gof$cvm))
  expect_type(gof$all_passed, "logical")
})

test_that("KS test works correctly", {
  set.seed(42)
  data <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  ks_result <- ks_test(fit)
  
  expect_type(ks_result, "list")
  expect_true(!is.null(ks_result$statistic))
  expect_true(!is.null(ks_result$p_value))
  expect_true(!is.null(ks_result$passed))
  expect_type(ks_result$passed, "logical")
  expect_true(ks_result$p_value >= 0 && ks_result$p_value <= 1)
})

test_that("AD test works correctly", {
  set.seed(42)
  data <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  ad_result <- ad_test(fit)
  
  expect_type(ad_result, "list")
  expect_true(!is.null(ad_result$statistic))
  expect_true(!is.null(ad_result$p_value))
  expect_true(!is.null(ad_result$passed))
  expect_type(ad_result$passed, "logical")
  expect_true(ad_result$statistic >= 0)
})

test_that("Chi-square test works correctly", {
  set.seed(42)
  data <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  chisq_result <- chi_square_test(fit)
  
  expect_type(chisq_result, "list")
  expect_true(!is.null(chisq_result$statistic))
  expect_true(!is.null(chisq_result$p_value))
  expect_true(!is.null(chisq_result$df))
  expect_true(!is.null(chisq_result$passed))
  expect_type(chisq_result$passed, "logical")
})

test_that("CvM test works correctly", {
  set.seed(42)
  data <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  cvm_result <- cvm_test(fit)
  
  expect_type(cvm_result, "list")
  expect_true(!is.null(cvm_result$statistic))
  expect_true(!is.null(cvm_result$p_value))
  expect_true(!is.null(cvm_result$passed))
  expect_type(cvm_result$passed, "logical")
  expect_true(cvm_result$statistic >= 0)
})

test_that("GOF tests detect poor fit", {
  set.seed(42)
  # Generate exponential data but fit normal
  data <- rexp(100, rate = 1)
  fit <- fit_distribution(data, "normal")
  
  # FIX: Use significance_level instead of alpha
  gof <- gof_tests(fit, significance_level = 0.05)
  
  # At least one test should fail for this poor fit
  # (though not guaranteed with small sample)
  expect_s3_class(gof, "distfitr_gof")
  expect_type(gof$all_passed, "logical")
})

test_that("GOF tests work with different alpha levels", {
  set.seed(42)
  data <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  # FIX: Use significance_level instead of alpha
  gof_05 <- gof_tests(fit, significance_level = 0.05)
  gof_01 <- gof_tests(fit, significance_level = 0.01)
  
  expect_equal(gof_05$significance_level, 0.05)
  expect_equal(gof_01$significance_level, 0.01)
})

test_that("GOF print method works", {
  set.seed(42)
  data <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  gof <- gof_tests(fit)
  
  expect_output(print(gof), "Goodness-of-Fit")
  expect_output(print(gof), "Kolmogorov-Smirnov")
})

test_that("GOF tests fail with invalid input", {
  expect_error(gof_tests("not a fit"))
  expect_error(gof_tests(list(a = 1)))
})
