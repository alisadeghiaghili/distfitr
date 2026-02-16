# Tests for distribution fitting

test_that("fit_distribution works with MLE", {
  set.seed(42)
  data <- rnorm(100, mean = 5, sd = 2)
  
  fit <- fit_distribution(data, "normal", method = "mle")
  
  expect_s3_class(fit, "distfitr_fit")
  expect_equal(fit$method, "mle")
  expect_true(!is.null(fit$params))
  expect_true(!is.null(fit$loglik))
  expect_true(!is.null(fit$aic))
  expect_true(!is.null(fit$bic))
  
  # Parameters should be close to true values
  expect_equal(as.numeric(fit$params["mean"]), 5, tolerance = 0.5)
  expect_equal(as.numeric(fit$params["sd"]), 2, tolerance = 0.5)
})

test_that("fit_distribution works with MME", {
  set.seed(42)
  data <- rnorm(100, mean = 5, sd = 2)
  
  fit <- fit_distribution(data, "normal", method = "mme")
  
  expect_s3_class(fit, "distfitr_fit")
  expect_equal(fit$method, "mme")
  
  # MME for normal should match sample mean and sd
  expect_equal(as.numeric(fit$params["mean"]), mean(data), tolerance = 1e-10)
  expect_equal(as.numeric(fit$params["sd"]), sd(data), tolerance = 1e-10)
})

test_that("fit_distribution works with QME", {
  set.seed(42)
  data <- rnorm(100, mean = 5, sd = 2)
  
  fit <- fit_distribution(data, "normal", method = "qme")
  
  expect_s3_class(fit, "distfitr_fit")
  expect_equal(fit$method, "qme")
  expect_true(!is.null(fit$params))
})

test_that("fit_distribution fails with invalid input", {
  # Non-numeric data
  expect_error(fit_distribution(c("a", "b", "c"), "normal"))
  
  # Too few observations
  expect_error(fit_distribution(c(1), "normal"))
  
  # NA values
  expect_error(fit_distribution(c(1, 2, NA, 4), "normal"))
  
  # Invalid distribution
  expect_error(fit_distribution(rnorm(100), "invalid"))
  
  # Invalid method
  expect_error(fit_distribution(rnorm(100), "normal", method = "invalid"))
})

test_that("fit_distribution works for all distributions", {
  set.seed(42)
  distributions <- c("normal", "lognormal", "gamma", "weibull", "exponential")
  
  for (dist in distributions) {
    # Generate appropriate data
    if (dist == "normal") {
      data <- rnorm(50, 5, 2)
    } else if (dist == "lognormal") {
      data <- rlnorm(50, 1, 0.5)
    } else if (dist == "gamma") {
      data <- rgamma(50, shape = 2, rate = 1)
    } else if (dist == "weibull") {
      data <- rweibull(50, shape = 2, scale = 1)
    } else if (dist == "exponential") {
      data <- rexp(50, rate = 1)
    }
    
    fit <- fit_distribution(data, dist, method = "mle")
    
    expect_s3_class(fit, "distfitr_fit")
    expect_true(!is.null(fit$params))
    expect_true(is.finite(fit$loglik))
    expect_true(is.finite(fit$aic))
    expect_true(is.finite(fit$bic))
  }
})

test_that("AIC and BIC calculations are correct", {
  set.seed(42)
  data <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal", method = "mle")
  
  # Manual AIC calculation
  k <- length(fit$params)
  n <- fit$n
  expected_aic <- -2 * fit$loglik + 2 * k
  expected_bic <- -2 * fit$loglik + k * log(n)
  
  expect_equal(fit$aic, expected_aic, tolerance = 1e-10)
  expect_equal(fit$bic, expected_bic, tolerance = 1e-10)
})

test_that("print method works without errors", {
  set.seed(42)
  data <- rnorm(50, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  expect_output(print(fit), "Distribution")
  expect_output(print(fit), "Method")
  expect_output(print(fit), "Parameters")
})

test_that("summary method works", {
  set.seed(42)
  data <- rnorm(50, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  summary_output <- summary(fit)
  expect_type(summary_output, "list")
})
