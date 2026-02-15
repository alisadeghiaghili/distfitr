# Tests for Enhanced S3 Methods

test_that("coef() extracts parameters correctly", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(x, "normal")
  
  params <- coef(fit)
  
  expect_type(params, "double")
  expect_named(params, c("mean", "sd"))
  expect_length(params, 2)
  expect_true(all(is.finite(params)))
})

test_that("logLik() returns proper logLik object", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(x, "normal")
  
  ll <- logLik(fit)
  
  expect_s3_class(ll, "logLik")
  expect_type(as.numeric(ll), "double")
  expect_equal(attr(ll, "df"), 2)
  expect_equal(attr(ll, "nobs"), 100)
})

test_that("AIC() and BIC() return correct values", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(x, "normal")
  
  aic_val <- AIC(fit)
  bic_val <- BIC(fit)
  
  expect_type(aic_val, "double")
  expect_type(bic_val, "double")
  expect_equal(aic_val, fit$aic)
  expect_equal(bic_val, fit$bic)
  expect_true(is.finite(aic_val))
  expect_true(is.finite(bic_val))
})

test_that("nobs() returns sample size", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(x, "normal")
  
  n <- nobs(fit)
  
  expect_type(n, "integer")
  expect_equal(n, 100)
  expect_equal(n, length(x))
})

test_that("residuals() computes residuals correctly", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(x, "normal")
  
  res <- residuals(fit)
  
  expect_type(res, "double")
  expect_length(res, 100)
  expect_true(all(is.finite(res)))
  
  # Check that residuals are approximately standard normal
  expect_true(abs(mean(res)) < 0.3)  # Mean close to 0
  expect_true(abs(sd(res) - 1) < 0.3)  # SD close to 1
})

test_that("predict() works with different types", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(x, "normal")
  
  new_points <- c(3, 5, 7)
  
  # Test density prediction
  pred_dens <- predict(fit, newdata = new_points, type = "density")
  expect_type(pred_dens, "double")
  expect_length(pred_dens, 3)
  expect_true(all(pred_dens > 0))
  
  # Test probability prediction
  pred_prob <- predict(fit, newdata = new_points, type = "prob")
  expect_type(pred_prob, "double")
  expect_length(pred_prob, 3)
  expect_true(all(pred_prob >= 0 & pred_prob <= 1))
  
  # Test quantile prediction
  probs <- c(0.25, 0.5, 0.75)
  pred_quant <- predict(fit, newdata = probs, type = "quantile")
  expect_type(pred_quant, "double")
  expect_length(pred_quant, 3)
  expect_true(all(is.finite(pred_quant)))
})

test_that("predict() uses original data when newdata is NULL", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(x, "normal")
  
  pred <- predict(fit, type = "density")
  
  expect_length(pred, 100)
  expect_true(all(pred > 0))
})

test_that("predict() validates quantile input", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(x, "normal")
  
  expect_error(
    predict(fit, newdata = c(-0.1, 0.5), type = "quantile"),
    "probabilities"
  )
  
  expect_error(
    predict(fit, newdata = c(0.5, 1.5), type = "quantile"),
    "probabilities"
  )
})

test_that("plot() creates plots without error", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(x, "normal")
  
  # Test different plot types
  expect_silent(plot(fit, type = "density"))
  expect_silent(plot(fit, type = "qq"))
  expect_silent(plot(fit, type = "pp"))
  expect_silent(plot(fit, type = "cdf"))
})

test_that("plot() with type='all' creates multiple plots", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(x, "normal")
  
  # This should create 4 plots in a 2x2 layout
  expect_silent(plot(fit, type = "all"))
})

test_that("vcov() returns message about implementation", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(x, "normal")
  
  expect_message(vcov(fit), "not yet implemented")
  expect_null(vcov(fit))
})

test_that("update() refits with new parameters", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  fit_mle <- fit_distribution(x, "normal", method = "mle")
  
  # Update with different method
  fit_mme <- update(fit_mle, method = "mme")
  
  expect_s3_class(fit_mme, "distfitr_fit")
  expect_equal(fit_mme$method, "mme")
  expect_equal(fit_mme$data, fit_mle$data)
  
  # Parameters should be different (slightly)
  expect_false(identical(fit_mme$params, fit_mle$params))
})

test_that("update() works with new data", {
  set.seed(123)
  x1 <- rnorm(100, mean = 5, sd = 2)
  x2 <- rnorm(100, mean = 6, sd = 2)
  
  fit1 <- fit_distribution(x1, "normal")
  fit2 <- update(fit1, data = x2)
  
  expect_s3_class(fit2, "distfitr_fit")
  expect_equal(fit2$data, x2)
  expect_false(identical(fit1$params, fit2$params))
})

test_that("S3 methods work with different distributions", {
  set.seed(123)
  
  # Test with gamma distribution
  x_gamma <- rgamma(100, shape = 2, rate = 0.5)
  fit_gamma <- fit_distribution(x_gamma, "gamma")
  
  expect_named(coef(fit_gamma), c("shape", "rate"))
  expect_type(AIC(fit_gamma), "double")
  expect_length(residuals(fit_gamma), 100)
  
  # Test with weibull distribution
  x_weibull <- rweibull(100, shape = 2, scale = 1)
  fit_weibull <- fit_distribution(x_weibull, "weibull")
  
  expect_named(coef(fit_weibull), c("shape", "scale"))
  expect_type(BIC(fit_weibull), "double")
  expect_length(predict(fit_weibull, type = "density"), 100)
})

test_that("Methods are compatible with standard R workflows", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  
  fit1 <- fit_distribution(x, "normal")
  fit2 <- fit_distribution(x, "lognormal")
  
  # Model comparison should work
  aic1 <- AIC(fit1)
  aic2 <- AIC(fit2)
  
  expect_true(is.finite(aic1))
  expect_true(is.finite(aic2))
  expect_false(identical(aic1, aic2))
  
  # logLik comparison
  ll1 <- logLik(fit1)
  ll2 <- logLik(fit2)
  
  expect_s3_class(ll1, "logLik")
  expect_s3_class(ll2, "logLik")
})

test_that("predict() handles edge cases", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(x, "normal")
  
  # Single value prediction
  pred_single <- predict(fit, newdata = 5, type = "density")
  expect_length(pred_single, 1)
  expect_true(is.finite(pred_single))
  
  # Empty newdata should use original data
  pred_default <- predict(fit)
  expect_length(pred_default, 100)
})

test_that("residuals() type parameter works", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  fit <- fit_distribution(x, "normal")
  
  # Different residual types (if calculate_residuals exists)
  res_quantile <- residuals(fit, type = "quantile")
  expect_length(res_quantile, 100)
  
  # Default should be quantile
  res_default <- residuals(fit)
  expect_equal(res_default, res_quantile)
})

test_that("Methods handle NA values gracefully", {
  set.seed(123)
  x <- c(rnorm(95, mean = 5, sd = 2), rep(NA, 5))
  
  # fit_distribution should handle NAs already
  fit <- fit_distribution(x, "normal")
  
  expect_equal(nobs(fit), 95)  # Should exclude NAs
  expect_length(residuals(fit), 95)
})

test_that("Plot functions handle different distributions", {
  set.seed(123)
  
  # Skewed distribution
  x_skewed <- rexp(100, rate = 0.5)
  fit_skewed <- fit_distribution(x_skewed, "exponential")
  
  expect_silent(plot(fit_skewed, type = "density"))
  expect_silent(plot(fit_skewed, type = "qq"))
})
