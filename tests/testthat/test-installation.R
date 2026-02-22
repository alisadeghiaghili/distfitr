# Installation and Core Functionality Tests
# These tests verify that the package loads correctly and core functions work

test_that("Package loads correctly", {
  expect_true(require(distfitr, quietly = TRUE))
})

test_that("Basic fitting works with MLE", {
  set.seed(42)
  data <- rnorm(50, mean = 10, sd = 2)
  fit <- fit_distribution(data, "normal", method = "mle")
  
  expect_s3_class(fit, "distfitr_fit")
  expect_named(fit$params, c("mean", "sd"))
  expect_true(abs(fit$params["mean"] - 10) < 1.5)
  expect_true(abs(fit$params["sd"] - 2) < 1)
  expect_true(!is.null(fit$aic))
  expect_true(!is.null(fit$bic))
})

test_that("GOF tests work", {
  set.seed(42)
  data <- rnorm(50, mean = 10, sd = 2)
  fit <- fit_distribution(data, "normal", method = "mle")
  gof <- gof_tests(fit)
  
  expect_s3_class(gof, "distfitr_gof")
  expect_true(!is.null(gof$ks))
  expect_true(!is.null(gof$ad))
  expect_true(!is.null(gof$chisq))
  expect_true(!is.null(gof$cvm))
  expect_type(gof$all_passed, "logical")
})

test_that("Bootstrap confidence intervals work", {
  set.seed(42)
  data <- rnorm(50, mean = 10, sd = 2)
  fit <- fit_distribution(data, "normal", method = "mle")
  boot_result <- bootstrap_ci(fit, n_bootstrap = 50, seed = 42)
  
  expect_s3_class(boot_result, "distfitr_bootstrap")
  expect_true(!is.null(boot_result$ci$mean))
  expect_true(!is.null(boot_result$ci$sd))
  
  # Check that CI has required elements (order doesn't matter)
  expect_true(all(c("estimate", "lower", "upper") %in% names(boot_result$ci$mean)))
  expect_length(boot_result$ci$mean, 3)
})

test_that("Diagnostics work", {
  set.seed(42)
  data <- rnorm(50, mean = 10, sd = 2)
  fit <- fit_distribution(data, "normal", method = "mle")
  diag <- diagnostics(fit)
  
  expect_s3_class(diag, "distfitr_diagnostics")
  expect_true(!is.null(diag$residuals))
  expect_true(!is.null(diag$influence))
  expect_length(diag$residuals, length(data))
})

test_that("i18n system works", {
  original_lang <- get_language()
  
  set_language("en")
  expect_equal(get_language(), "en")
  en_name <- get_dist_name("normal")
  expect_gt(nchar(en_name), 0)
  
  set_language("fa")
  expect_equal(get_language(), "fa")
  fa_name <- get_dist_name("normal")
  expect_gt(nchar(fa_name), 0)
  
  set_language("de")
  expect_equal(get_language(), "de")
  de_name <- get_dist_name("normal")
  expect_gt(nchar(de_name), 0)
  
  # Test locale formatting
  formatted <- locale_format(1234.56, "number", 2)
  expect_gt(nchar(formatted), 0)
  
  # Restore original language
  set_language(original_lang)
})

test_that("Print methods work", {
  set.seed(42)
  data <- rnorm(50, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  # Test fit print
  output <- capture.output(print(fit))
  expect_gt(length(output), 0)
  
  # Test GOF print
  gof <- gof_tests(fit)
  output <- capture.output(print(gof))
  expect_gt(length(output), 0)
  
  # Test bootstrap print
  boot <- bootstrap_ci(fit, n_bootstrap = 50, seed = 42)
  output <- capture.output(print(boot))
  expect_gt(length(output), 0)
  
  # Test diagnostics print
  diag <- diagnostics(fit)
  output <- capture.output(print(diag))
  expect_gt(length(output), 0)
})

test_that("Multiple distributions work", {
  set.seed(42)
  
  # Normal
  data_norm <- rnorm(50, 5, 2)
  fit_norm <- fit_distribution(data_norm, "normal")
  expect_s3_class(fit_norm, "distfitr_fit")
  
  # Gamma
  data_gamma <- rgamma(50, shape = 2, rate = 1)
  fit_gamma <- fit_distribution(data_gamma, "gamma")
  expect_s3_class(fit_gamma, "distfitr_fit")
  
  # Weibull
  data_weibull <- rweibull(50, shape = 2, scale = 1)
  fit_weibull <- fit_distribution(data_weibull, "weibull")
  expect_s3_class(fit_weibull, "distfitr_fit")
  
  # Exponential
  data_exp <- rexp(50, rate = 1)
  fit_exp <- fit_distribution(data_exp, "exponential")
  expect_s3_class(fit_exp, "distfitr_fit")
})
