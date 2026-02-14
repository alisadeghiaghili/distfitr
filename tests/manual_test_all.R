#!/usr/bin/env Rscript
# Comprehensive Manual Test Script for distfitr
# Run this to verify all package functionality

cat("\n")
cat("========================================\n")
cat("  distfitr v0.2.1 Comprehensive Tests  \n")
cat("========================================\n\n")

# Load package
cat("[1/12] Loading distfitr package...\n")
if (!requireNamespace("distfitr", quietly = TRUE)) {
  stop("distfitr not installed. Run: devtools::install_github('alisadeghiaghili/distfitr')")
}
library(distfitr)
cat("✓ Package loaded successfully\n\n")

# Test 1: Distributions
cat("[2/12] Testing distribution system...\n")
test_distributions <- function() {
  tryCatch({
    # List all distributions
    dists <- list_distributions()
    cat(sprintf("  Found %d distributions: %s\n", 
                length(dists), 
                paste(head(dists, 3), collapse = ", ")))
    
    # Test getting a distribution
    normal_dist <- get_distribution("normal")
    if (is.null(normal_dist)) stop("Failed to get normal distribution")
    
    # Test distribution functions
    set.seed(42)
    test_val <- normal_dist$dfunc(0, mean = 0, sd = 1)
    if (!is.finite(test_val)) stop("PDF function failed")
    
    test_data <- normal_dist$rfunc(10, mean = 0, sd = 1)
    if (length(test_data) != 10) stop("Random generation failed")
    
    cat("✓ Distribution system working\n\n")
    return(TRUE)
  }, error = function(e) {
    cat(sprintf("✗ FAILED: %s\n\n", e$message))
    return(FALSE)
  })
}
test_distributions()

# Test 2: Fitting - MLE
cat("[3/12] Testing MLE fitting...\n")
test_mle <- function() {
  tryCatch({
    set.seed(42)
    data <- rnorm(100, mean = 10, sd = 2)
    
    fit <- fit_distribution(data, "normal", method = "mle")
    
    if (is.null(fit)) stop("MLE fit returned NULL")
    if (!inherits(fit, "distfitr_fit")) stop("Wrong class")
    if (abs(fit$params["mean"] - 10) > 1) stop("Mean estimation too far off")
    
    cat(sprintf("  Estimated mean: %.3f (true: 10)\n", fit$params["mean"]))
    cat(sprintf("  Estimated sd: %.3f (true: 2)\n", fit$params["sd"]))
    cat(sprintf("  AIC: %.2f, BIC: %.2f\n", fit$aic, fit$bic))
    cat("✓ MLE fitting working\n\n")
    return(fit)
  }, error = function(e) {
    cat(sprintf("✗ FAILED: %s\n\n", e$message))
    return(NULL)
  })
}
fit_result <- test_mle()

# Test 3: Fitting - MME and QME
cat("[4/12] Testing MME and QME methods...\n")
test_other_methods <- function() {
  tryCatch({
    set.seed(42)
    data <- rnorm(100, mean = 10, sd = 2)
    
    fit_mme <- fit_distribution(data, "normal", method = "mme")
    fit_qme <- fit_distribution(data, "normal", method = "qme")
    
    if (is.null(fit_mme) || is.null(fit_qme)) stop("Fitting failed")
    
    cat(sprintf("  MME mean: %.3f\n", fit_mme$params["mean"]))
    cat(sprintf("  QME mean: %.3f\n", fit_qme$params["mean"]))
    cat("✓ MME and QME working\n\n")
    return(TRUE)
  }, error = function(e) {
    cat(sprintf("✗ FAILED: %s\n\n", e$message))
    return(FALSE)
  })
}
test_other_methods()

# Test 4: GOF Tests
cat("[5/12] Testing goodness-of-fit tests...\n")
test_gof <- function(fit) {
  if (is.null(fit)) {
    cat("✗ Skipped (no fit object)\n\n")
    return(NULL)
  }
  
  tryCatch({
    gof <- gof_tests(fit, alpha = 0.05)
    
    if (is.null(gof)) stop("GOF tests returned NULL")
    if (!inherits(gof, "distfitr_gof")) stop("Wrong class")
    
    cat(sprintf("  KS test p-value: %.4f (%s)\n", 
                gof$ks$p_value,
                ifelse(gof$ks$passed, "PASSED", "FAILED")))
    cat(sprintf("  AD test p-value: %.4f (%s)\n", 
                gof$ad$p_value,
                ifelse(gof$ad$passed, "PASSED", "FAILED")))
    cat(sprintf("  Chi-Square p-value: %.4f (%s)\n", 
                gof$chisq$p_value,
                ifelse(gof$chisq$passed, "PASSED", "FAILED")))
    cat(sprintf("  CvM test p-value: %.4f (%s)\n", 
                gof$cvm$p_value,
                ifelse(gof$cvm$passed, "PASSED", "FAILED")))
    cat(sprintf("  Overall: %s\n", 
                ifelse(gof$all_passed, "ALL PASSED", "SOME FAILED")))
    cat("✓ GOF tests working\n\n")
    return(gof)
  }, error = function(e) {
    cat(sprintf("✗ FAILED: %s\n\n", e$message))
    return(NULL)
  })
}
gof_result <- test_gof(fit_result)

# Test 5: Bootstrap
cat("[6/12] Testing bootstrap confidence intervals...\n")
test_bootstrap <- function(fit) {
  if (is.null(fit)) {
    cat("✗ Skipped (no fit object)\n\n")
    return(NULL)
  }
  
  tryCatch({
    # Use small n_bootstrap for speed
    boot_result <- bootstrap_ci(fit, method = "parametric", 
                               n_bootstrap = 100, seed = 42)
    
    if (is.null(boot_result)) stop("Bootstrap returned NULL")
    if (!inherits(boot_result, "distfitr_bootstrap")) stop("Wrong class")
    
    for (param in names(boot_result$ci)) {
      ci <- boot_result$ci[[param]]
      cat(sprintf("  %s: %.3f [%.3f, %.3f]\n", 
                  param, ci["estimate"], ci["lower"], ci["upper"]))
    }
    
    cat("✓ Bootstrap working\n\n")
    return(boot_result)
  }, error = function(e) {
    cat(sprintf("✗ FAILED: %s\n\n", e$message))
    return(NULL)
  })
}
boot_result <- test_bootstrap(fit_result)

# Test 6: Diagnostics
cat("[7/12] Testing diagnostics...\n")
test_diagnostics <- function(fit) {
  if (is.null(fit)) {
    cat("✗ Skipped (no fit object)\n\n")
    return(NULL)
  }
  
  tryCatch({
    diag <- diagnostics(fit, residual_type = "quantile")
    
    if (is.null(diag)) stop("Diagnostics returned NULL")
    if (!inherits(diag, "distfitr_diagnostics")) stop("Wrong class")
    
    cat(sprintf("  Residuals: min=%.3f, max=%.3f\n", 
                min(diag$residuals), max(diag$residuals)))
    cat(sprintf("  Influential points: %d\n", 
                length(diag$influence$influential_indices)))
    
    if (!is.null(diag$outliers$consensus)) {
      cat(sprintf("  Consensus outliers: %d\n", 
                  diag$outliers$consensus$n_outliers))
    }
    
    cat("✓ Diagnostics working\n\n")
    return(diag)
  }, error = function(e) {
    cat(sprintf("✗ FAILED: %s\n\n", e$message))
    return(NULL)
  })
}
diag_result <- test_diagnostics(fit_result)

# Test 7: Outlier Detection
cat("[8/12] Testing outlier detection methods...\n")
test_outliers <- function(fit) {
  if (is.null(fit)) {
    cat("✗ Skipped (no fit object)\n\n")
    return(FALSE)
  }
  
  tryCatch({
    methods <- c("zscore", "iqr", "likelihood", "mahalanobis")
    
    for (method in methods) {
      outliers <- detect_outliers(fit, method = method)
      cat(sprintf("  %s: %d outliers detected\n", 
                  method, outliers$n_outliers))
    }
    
    # Test "all" method
    outliers_all <- detect_outliers(fit, method = "all")
    if (!is.null(outliers_all$consensus)) {
      cat(sprintf("  Consensus: %d outliers\n", 
                  outliers_all$consensus$n_outliers))
    }
    
    cat("✓ Outlier detection working\n\n")
    return(TRUE)
  }, error = function(e) {
    cat(sprintf("✗ FAILED: %s\n\n", e$message))
    return(FALSE)
  })
}
test_outliers(fit_result)

# Test 8: i18n - Language Switching
cat("[9/12] Testing i18n (multilingual support)...\n")
test_i18n <- function() {
  tryCatch({
    original_lang <- get_language()
    
    # Test English
    set_language("en")
    if (get_language() != "en") stop("Failed to set English")
    en_name <- get_dist_name("normal")
    cat(sprintf("  English: %s\n", en_name))
    
    # Test Persian
    set_language("fa")
    if (get_language() != "fa") stop("Failed to set Persian")
    fa_name <- get_dist_name("normal")
    cat(sprintf("  Persian: %s\n", fa_name))
    
    # Test German
    set_language("de")
    if (get_language() != "de") stop("Failed to set German")
    de_name <- get_dist_name("normal")
    cat(sprintf("  German: %s\n", de_name))
    
    # Test translation function
    en_text <- tr("fitting.method_mle")
    if (nchar(en_text) == 0) stop("Translation failed")
    
    # Test locale formatting
    formatted <- locale_format(1234.56, "number", 2)
    cat(sprintf("  Formatted number (de): %s\n", formatted))
    
    # Restore original language
    set_language(original_lang)
    
    cat("✓ i18n system working\n\n")
    return(TRUE)
  }, error = function(e) {
    cat(sprintf("✗ FAILED: %s\n\n", e$message))
    return(FALSE)
  })
}
test_i18n()

# Test 9: Multiple Distributions
cat("[10/12] Testing multiple distributions...\n")
test_multiple_dists <- function() {
  tryCatch({
    set.seed(42)
    
    test_cases <- list(
      list(name = "gamma", data = rgamma(50, shape = 2, rate = 1)),
      list(name = "weibull", data = rweibull(50, shape = 2, scale = 1)),
      list(name = "exponential", data = rexp(50, rate = 1)),
      list(name = "lognormal", data = rlnorm(50, meanlog = 1, sdlog = 0.5))
    )
    
    for (tc in test_cases) {
      fit <- fit_distribution(tc$data, tc$name, method = "mle")
      if (is.null(fit)) stop(sprintf("%s fitting failed", tc$name))
      cat(sprintf("  %s: AIC=%.2f, params=%d\n", 
                  tc$name, fit$aic, length(fit$params)))
    }
    
    cat("✓ Multiple distributions working\n\n")
    return(TRUE)
  }, error = function(e) {
    cat(sprintf("✗ FAILED: %s\n\n", e$message))
    return(FALSE)
  })
}
test_multiple_dists()

# Test 10: Edge Cases
cat("[11/12] Testing edge cases...\n")
test_edge_cases <- function() {
  tryCatch({
    set.seed(42)
    
    # Small sample
    small_data <- rnorm(10)
    fit_small <- fit_distribution(small_data, "normal")
    if (is.null(fit_small)) stop("Small sample failed")
    cat("  Small sample (n=10): OK\n")
    
    # Large sample (smaller for speed)
    large_data <- rnorm(1000)
    fit_large <- fit_distribution(large_data, "normal")
    if (is.null(fit_large)) stop("Large sample failed")
    cat("  Large sample (n=1000): OK\n")
    
    # Extreme values
    extreme_data <- c(rnorm(95), 100, -100)
    fit_extreme <- fit_distribution(extreme_data, "normal")
    if (is.null(fit_extreme)) stop("Extreme values failed")
    cat("  Extreme values: OK\n")
    
    # Beta distribution (bounded)
    beta_data <- rbeta(50, 2, 5)
    fit_beta <- fit_distribution(beta_data, "beta")
    if (is.null(fit_beta)) stop("Beta distribution failed")
    cat("  Beta distribution: OK\n")
    
    cat("✓ Edge cases handled\n\n")
    return(TRUE)
  }, error = function(e) {
    cat(sprintf("✗ FAILED: %s\n\n", e$message))
    return(FALSE)
  })
}
test_edge_cases()

# Test 11: Print Methods
cat("[12/12] Testing print methods...\n")
test_print_methods <- function() {
  tryCatch({
    set.seed(42)
    data <- rnorm(50, mean = 5, sd = 2)
    
    # Set to English for consistent output
    original_lang <- get_language()
    set_language("en")
    
    # Test fit print
    fit <- fit_distribution(data, "normal")
    output <- capture.output(print(fit))
    if (length(output) == 0) stop("Fit print produced no output")
    cat("  fit print: OK\n")
    
    # Test GOF print
    gof <- gof_tests(fit)
    output <- capture.output(print(gof))
    if (length(output) == 0) stop("GOF print produced no output")
    cat("  GOF print: OK\n")
    
    # Test bootstrap print
    boot <- bootstrap_ci(fit, n_bootstrap = 50, seed = 42)
    output <- capture.output(print(boot))
    if (length(output) == 0) stop("Bootstrap print produced no output")
    cat("  Bootstrap print: OK\n")
    
    # Test diagnostics print
    diag <- diagnostics(fit)
    output <- capture.output(print(diag))
    if (length(output) == 0) stop("Diagnostics print produced no output")
    cat("  Diagnostics print: OK\n")
    
    # Restore language
    set_language(original_lang)
    
    cat("✓ Print methods working\n\n")
    return(TRUE)
  }, error = function(e) {
    cat(sprintf("✗ FAILED: %s\n\n", e$message))
    return(FALSE)
  })
}
test_print_methods()

# Final Summary
cat("\n")
cat("========================================\n")
cat("         TEST SUMMARY                  \n")
cat("========================================\n\n")
cat("All manual tests completed!\n")
cat("\nTo run automated tests:\n")
cat("  devtools::test()\n")
cat("\nTo check test coverage:\n")
cat("  covr::package_coverage()\n")
cat("\nTo run R CMD check:\n")
cat("  devtools::check()\n")
cat("\n========================================\n\n")

cat("✓ distfitr v0.2.1 is ready! 🚀\n\n")
