#' Goodness-of-Fit Tests
#'
#' @description
#' Comprehensive suite of goodness-of-fit tests to assess how well a fitted
#' distribution matches the observed data. Includes Kolmogorov-Smirnov,
#' Anderson-Darling, Chi-Square, and Cramér-von Mises tests.
#'
#' @name gof_tests
NULL

#' Run All Goodness-of-Fit Tests
#'
#' @description
#' Execute all available GOF tests and return comprehensive results.
#'
#' @param fit A distfitr_fit object from \code{fit_distribution()}.
#' @param significance_level Numeric. Significance level for hypothesis tests 
#'   (default: 0.05).
#' @param n_bins Integer. Number of bins for Chi-Square test (default: auto).
#'   
#' @return An object of class "distfitr_gof" containing:
#'   \item{ks}{Kolmogorov-Smirnov test results}
#'   \item{ad}{Anderson-Darling test results}
#'   \item{chisq}{Chi-Square test results}
#'   \item{cvm}{Cramér-von Mises test results}
#'   \item{overall_pass}{Logical, whether all tests pass}
#'   \item{significance_level}{Significance level used}
#'   
#' @export
#' @examples
#' # Fit distribution
#' set.seed(123)
#' data <- rnorm(100, mean = 5, sd = 2)
#' fit <- fit_distribution(data, "normal")
#' 
#' # Run all GOF tests
#' gof <- gof_tests(fit)
#' print(gof)
gof_tests <- function(fit, significance_level = 0.05, n_bins = NULL) {
  
  if (!inherits(fit, "distfitr_fit")) {
    stop("fit must be a distfitr_fit object")
  }
  
  # Run individual tests
  ks_result <- ks_test(fit)
  ad_result <- ad_test(fit)
  chisq_result <- chi_square_test(fit, n_bins = n_bins)
  cvm_result <- cvm_test(fit)
  
  # Overall pass/fail
  tests_pass <- c(
    ks_result$p_value > significance_level,
    ad_result$p_value > significance_level,
    chisq_result$p_value > significance_level,
    cvm_result$p_value > significance_level
  )
  
  overall_pass <- all(tests_pass)
  
  results <- list(
    ks = ks_result,
    ad = ad_result,
    chisq = chisq_result,
    cvm = cvm_result,
    overall_pass = overall_pass,
    tests_pass = tests_pass,
    significance_level = significance_level,
    fit = fit
  )
  
  class(results) <- "distfitr_gof"
  
  return(results)
}

#' Kolmogorov-Smirnov Test
#'
#' @description
#' Test the maximum difference between empirical and theoretical CDFs.
#' General-purpose test, sensitive to differences in location and shape.
#'
#' @param fit A distfitr_fit object.
#'   
#' @return List with test results:
#'   \item{statistic}{D statistic (maximum absolute difference)}
#'   \item{p_value}{P-value}
#'   \item{test_name}{"Kolmogorov-Smirnov"}
#'   \item{interpretation}{Human-readable interpretation}
#'   
#' @export
ks_test <- function(fit) {
  
  data <- fit$data
  dist_obj <- fit$distribution
  params <- fit$params
  
  # Create CDF function with fitted parameters
  cdf_func <- function(x) {
    do.call(dist_obj$pfunc, c(list(q = x), as.list(params)))
  }
  
  # KS test
  ks_result <- suppressWarnings(
    stats::ks.test(data, cdf_func)
  )
  
  # Interpretation
  interpretation <- if (ks_result$p.value > 0.05) {
    "The fitted distribution is consistent with the observed data (fail to reject H0)."
  } else if (ks_result$p.value > 0.01) {
    "Weak evidence against the fitted distribution (reject H0 at α=0.05)."
  } else {
    "Strong evidence against the fitted distribution (reject H0 at α=0.01)."
  }
  
  result <- list(
    statistic = as.numeric(ks_result$statistic),
    p_value = ks_result$p.value,
    test_name = "Kolmogorov-Smirnov",
    interpretation = interpretation
  )
  
  class(result) <- "distfitr_gof_test"
  
  return(result)
}

#' Anderson-Darling Test
#'
#' @description
#' Test that gives more weight to tail deviations than KS test.
#' More sensitive to differences in distribution tails.
#'
#' @param fit A distfitr_fit object.
#'   
#' @return List with test results.
#' @export
ad_test <- function(fit) {
  
  data <- fit$data
  dist_obj <- fit$distribution
  params <- fit$params
  n <- length(data)
  
  # Sort data
  data_sorted <- sort(data)
  
  # Calculate CDFs
  cdf_values <- do.call(
    dist_obj$pfunc, 
    c(list(q = data_sorted), as.list(params))
  )
  
  # Prevent log(0) or log(1)
  cdf_values <- pmax(pmin(cdf_values, 1 - 1e-10), 1e-10)
  
  # Anderson-Darling statistic
  i <- 1:n
  ad_stat <- -n - sum((2 * i - 1) * 
                      (log(cdf_values) + log(1 - rev(cdf_values)))) / n
  
  # Approximate p-value (for normal distribution)
  # More sophisticated calculations would be distribution-specific
  ad_adj <- ad_stat * (1 + 0.75/n + 2.25/n^2)
  
  # Approximate p-value using asymptotic distribution
  if (ad_adj < 0.2) {
    p_value <- 1 - exp(-13.436 + 101.14 * ad_adj - 223.73 * ad_adj^2)
  } else if (ad_adj < 0.34) {
    p_value <- 1 - exp(-8.318 + 42.796 * ad_adj - 59.938 * ad_adj^2)
  } else if (ad_adj < 0.6) {
    p_value <- exp(0.9177 - 4.279 * ad_adj - 1.38 * ad_adj^2)
  } else {
    p_value <- exp(1.2937 - 5.709 * ad_adj + 0.0186 * ad_adj^2)
  }
  
  p_value <- max(0, min(1, p_value))
  
  interpretation <- if (p_value > 0.05) {
    "The fitted distribution is consistent with the observed data, including tails."
  } else if (p_value > 0.01) {
    "Moderate evidence of poor fit, especially in the tails."
  } else {
    "Strong evidence of poor fit, particularly in distribution tails."
  }
  
  result <- list(
    statistic = ad_stat,
    p_value = p_value,
    test_name = "Anderson-Darling",
    interpretation = interpretation
  )
  
  class(result) <- "distfitr_gof_test"
  
  return(result)
}

#' Chi-Square Goodness-of-Fit Test
#'
#' @description
#' Test based on frequency counts in bins. Good for discrete data or
#' when you want to test specific regions of the distribution.
#'
#' @param fit A distfitr_fit object.
#' @param n_bins Integer. Number of bins (default: auto using Sturges' rule).
#'   
#' @return List with test results.
#' @export
chi_square_test <- function(fit, n_bins = NULL) {
  
  data <- fit$data
  dist_obj <- fit$distribution
  params <- fit$params
  n <- length(data)
  
  # Determine number of bins
  if (is.null(n_bins)) {
    n_bins <- ceiling(log2(n) + 1)  # Sturges' rule
    n_bins <- max(5, min(n_bins, 20))  # Reasonable bounds
  }
  
  # Create bins
  breaks <- quantile(data, probs = seq(0, 1, length.out = n_bins + 1))
  breaks[1] <- -Inf
  breaks[n_bins + 1] <- Inf
  
  # Observed frequencies
  observed <- as.numeric(table(cut(data, breaks = breaks, include.lowest = TRUE)))
  
  # Expected frequencies
  expected <- numeric(n_bins)
  for (i in 1:n_bins) {
    lower_cdf <- do.call(dist_obj$pfunc, c(list(q = breaks[i]), as.list(params)))
    upper_cdf <- do.call(dist_obj$pfunc, c(list(q = breaks[i + 1]), as.list(params)))
    expected[i] <- n * (upper_cdf - lower_cdf)
  }
  
  # Remove bins with very small expected frequencies
  valid <- expected >= 5
  if (sum(valid) < 2) {
    warning("Too few bins with sufficient expected frequency")
    valid <- expected >= 1
  }
  
  observed <- observed[valid]
  expected <- expected[valid]
  
  # Chi-square statistic
  chi_stat <- sum((observed - expected)^2 / expected)
  
  # Degrees of freedom (bins - 1 - number of estimated parameters)
  df <- length(observed) - 1 - length(params)
  df <- max(1, df)
  
  # P-value
  p_value <- 1 - pchisq(chi_stat, df = df)
  
  interpretation <- if (p_value > 0.05) {
    "The observed frequencies match the expected frequencies from the fitted distribution."
  } else if (p_value > 0.01) {
    "Moderate discrepancy between observed and expected frequencies."
  } else {
    "Significant discrepancy between observed and expected frequencies."
  }
  
  result <- list(
    statistic = chi_stat,
    p_value = p_value,
    df = df,
    n_bins = length(observed),
    test_name = "Chi-Square",
    interpretation = interpretation
  )
  
  class(result) <- "distfitr_gof_test"
  
  return(result)
}

#' Cramér-von Mises Test
#'
#' @description
#' Test that weights all deviations equally (unlike KS which focuses on maximum).
#' Good overall test with balanced sensitivity across the distribution.
#'
#' @param fit A distfitr_fit object.
#'   
#' @return List with test results.
#' @export
cvm_test <- function(fit) {
  
  data <- fit$data
  dist_obj <- fit$distribution
  params <- fit$params
  n <- length(data)
  
  # Sort data
  data_sorted <- sort(data)
  
  # Calculate CDFs
  cdf_values <- do.call(
    dist_obj$pfunc,
    c(list(q = data_sorted), as.list(params))
  )
  
  # CvM statistic
  i <- 1:n
  cvm_stat <- sum((cdf_values - (2 * i - 1) / (2 * n))^2) + 1 / (12 * n)
  
  # Approximate p-value (using asymptotic distribution)
  # This is a simplified approximation
  cvm_adj <- cvm_stat * (1 + 0.5 / n)
  
  # Approximate critical values and p-value
  if (cvm_adj < 0.0275) {
    p_value <- 1 - 0.001
  } else if (cvm_adj < 0.0461) {
    p_value <- 1 - 0.01
  } else if (cvm_adj < 0.0743) {
    p_value <- 1 - 0.05
  } else if (cvm_adj < 0.1054) {
    p_value <- 1 - 0.10
  } else {
    # Rough approximation for larger values
    p_value <- exp(-cvm_adj * 10)
  }
  
  p_value <- max(0, min(1, p_value))
  
  interpretation <- if (p_value > 0.05) {
    "The fitted distribution shows good overall agreement with the data."
  } else if (p_value > 0.01) {
    "Moderate overall discrepancy between fitted distribution and data."
  } else {
    "Significant overall discrepancy between fitted distribution and data."
  }
  
  result <- list(
    statistic = cvm_stat,
    p_value = p_value,
    test_name = "Cramér-von Mises",
    interpretation = interpretation
  )
  
  class(result) <- "distfitr_gof_test"
  
  return(result)
}

#' Print GOF Test Results
#' @param x A distfitr_gof_test object
#' @param ... Additional arguments (unused)
#' @export
print.distfitr_gof_test <- function(x, ...) {
  cat(sprintf("\n%s Test\n", x$test_name))
  cat(sprintf("Statistic: %.4f\n", x$statistic))
  cat(sprintf("P-value: %s\n", format_pval(x$p_value)))
  
  if (!is.null(x$df)) {
    cat(sprintf("Degrees of freedom: %d\n", x$df))
  }
  
  cat(sprintf("\nInterpretation: %s\n", x$interpretation))
  
  invisible(x)
}

#' Print All GOF Tests Results
#' @param x A distfitr_gof object
#' @param ... Additional arguments (unused)
#' @export
print.distfitr_gof <- function(x, ...) {
  cat("\n===== Goodness-of-Fit Test Results =====\n")
  cat(sprintf("\nDistribution: %s\n", x$fit$distribution$display_name))
  cat(sprintf("Sample size: %d\n", x$fit$n))
  cat(sprintf("Significance level: %.2f\n", x$significance_level))
  
  cat("\n----- Test Statistics -----\n")
  
  tests <- list(x$ks, x$ad, x$chisq, x$cvm)
  test_names <- c("Kolmogorov-Smirnov", "Anderson-Darling", 
                  "Chi-Square", "Cramér-von Mises")
  
  for (i in seq_along(tests)) {
    pass <- x$tests_pass[i]
    symbol <- if (pass) "✓" else "✗"
    
    cat(sprintf("\n[%s] %s:\n", symbol, test_names[i]))
    cat(sprintf("    Statistic = %.4f\n", tests[[i]]$statistic))
    cat(sprintf("    P-value %s\n", format_pval(tests[[i]]$p_value)))
  }
  
  cat("\n----- Overall Assessment -----\n")
  if (x$overall_pass) {
    cat("✓ All tests PASSED: The fitted distribution is consistent with the data.\n")
  } else {
    n_failed <- sum(!x$tests_pass)
    cat(sprintf("✗ %d test(s) FAILED: Consider alternative distributions.\n", n_failed))
  }
  
  cat("\n=======================================\n")
  
  invisible(x)
}
