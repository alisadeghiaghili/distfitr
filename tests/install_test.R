#!/usr/bin/env Rscript
# Post-Installation Verification Test
# Run this immediately after installing distfitr

cat("\n")
cat("==========================================\n")
cat(" distfitr Post-Installation Test        \n")
cat("==========================================\n\n")

# Test 1: Package loads
cat("[1/8] Testing package load...\n")
tryCatch({
  library(distfitr)
  cat("✓ Package loaded successfully\n\n")
}, error = function(e) {
  cat("✗ FAILED: Could not load package\n")
  cat(sprintf("  Error: %s\n\n", e$message))
  quit(status = 1)
})

# Test 2: Basic fitting
cat("[2/8] Testing basic fitting...\n")
tryCatch({
  set.seed(42)
  data <- rnorm(50, mean = 10, sd = 2)
  fit <- fit_distribution(data, "normal", method = "mle")
  
  if (is.null(fit)) stop("Fit returned NULL")
  if (!inherits(fit, "distfitr_fit")) stop("Wrong object class")
  
  cat(sprintf("  Estimated mean: %.3f (true: 10.0)\n", fit$params["mean"]))
  cat(sprintf("  Estimated sd: %.3f (true: 2.0)\n", fit$params["sd"]))
  cat("✓ Basic fitting works\n\n")
}, error = function(e) {
  cat(sprintf("✗ FAILED: %s\n\n", e$message))
  quit(status = 1)
})

# Test 3: GOF tests
cat("[3/8] Testing GOF tests...\n")
tryCatch({
  gof <- gof_tests(fit)
  
  if (is.null(gof)) stop("GOF returned NULL")
  if (!inherits(gof, "distfitr_gof")) stop("Wrong object class")
  
  cat(sprintf("  KS test: %s (p=%.4f)\n", 
              ifelse(gof$ks$passed, "PASS", "FAIL"),
              gof$ks$p_value))
  cat(sprintf("  AD test: %s (p=%.4f)\n", 
              ifelse(gof$ad$passed, "PASS", "FAIL"),
              gof$ad$p_value))
  cat("✓ GOF tests work\n\n")
}, error = function(e) {
  cat(sprintf("✗ FAILED: %s\n\n", e$message))
  quit(status = 1)
})

# Test 4: Bootstrap
cat("[4/8] Testing bootstrap...\n")
tryCatch({
  boot_result <- bootstrap_ci(fit, n_bootstrap = 50, seed = 42)
  
  if (is.null(boot_result)) stop("Bootstrap returned NULL")
  if (!inherits(boot_result, "distfitr_bootstrap")) stop("Wrong object class")
  
  cat(sprintf("  Mean CI: [%.3f, %.3f]\n", 
              boot_result$ci$mean["lower"],
              boot_result$ci$mean["upper"]))
  cat("✓ Bootstrap works\n\n")
}, error = function(e) {
  cat(sprintf("✗ FAILED: %s\n\n", e$message))
  quit(status = 1)
})

# Test 5: Diagnostics
cat("[5/8] Testing diagnostics...\n")
tryCatch({
  diag <- diagnostics(fit)
  
  if (is.null(diag)) stop("Diagnostics returned NULL")
  if (!inherits(diag, "distfitr_diagnostics")) stop("Wrong object class")
  
  cat(sprintf("  Residuals: %d values\n", length(diag$residuals)))
  cat(sprintf("  Influential points: %d\n", 
              length(diag$influence$influential_indices)))
  cat("✓ Diagnostics work\n\n")
}, error = function(e) {
  cat(sprintf("✗ FAILED: %s\n\n", e$message))
  quit(status = 1)
})

# Test 6: i18n system
cat("[6/8] Testing i18n (multilingual)...\n")
tryCatch({
  original_lang <- get_language()
  
  # Test language switching
  set_language("en")
  if (get_language() != "en") stop("Failed to set English")
  
  set_language("fa")
  if (get_language() != "fa") stop("Failed to set Persian")
  
  set_language("de")
  if (get_language() != "de") stop("Failed to set German")
  
  # Test translation
  set_language("en")
  en_name <- get_dist_name("normal")
  if (nchar(en_name) == 0) stop("Translation failed")
  
  # Test locale formatting
  formatted <- locale_format(1234.56, "number", 2)
  if (nchar(formatted) == 0) stop("Formatting failed")
  
  # Restore
  set_language(original_lang)
  
  cat("  Languages: en, fa, de\n")
  cat("  Translation: OK\n")
  cat("  Formatting: OK\n")
  cat("✓ i18n system works\n\n")
}, error = function(e) {
  cat(sprintf("✗ FAILED: %s\n\n", e$message))
  quit(status = 1)
})

# Test 7: Print methods
cat("[7/8] Testing print methods...\n")
tryCatch({
  # Test fit print
  output <- capture.output(print(fit))
  if (length(output) == 0) stop("Fit print failed")
  
  # Test GOF print
  output <- capture.output(print(gof))
  if (length(output) == 0) stop("GOF print failed")
  
  # Test bootstrap print
  output <- capture.output(print(boot_result))
  if (length(output) == 0) stop("Bootstrap print failed")
  
  # Test diagnostics print
  output <- capture.output(print(diag))
  if (length(output) == 0) stop("Diagnostics print failed")
  
  cat("  All print methods: OK\n")
  cat("✓ Print methods work\n\n")
}, error = function(e) {
  cat(sprintf("✗ FAILED: %s\n\n", e$message))
  quit(status = 1)
})

# Test 8: Multiple distributions
cat("[8/8] Testing multiple distributions...\n")
tryCatch({
  set.seed(42)
  
  test_cases <- list(
    normal = list(data = rnorm(50, 5, 2), dist = "normal"),
    gamma = list(data = rgamma(50, shape = 2, rate = 1), dist = "gamma"),
    weibull = list(data = rweibull(50, shape = 2, scale = 1), dist = "weibull")
  )
  
  for (name in names(test_cases)) {
    tc <- test_cases[[name]]
    fit_test <- fit_distribution(tc$data, tc$dist)
    if (is.null(fit_test)) stop(sprintf("%s failed", name))
  }
  
  cat("  Tested: normal, gamma, weibull\n")
  cat("✓ Multiple distributions work\n\n")
}, error = function(e) {
  cat(sprintf("✗ FAILED: %s\n\n", e$message))
  quit(status = 1)
})

# Final summary
cat("\n")
cat("==========================================\n")
cat("      ✅ ALL TESTS PASSED!                \n")
cat("==========================================\n\n")

cat("distfitr is installed and working correctly!\n\n")

cat("Quick start:\n")
cat("  library(distfitr)\n")
cat("  data <- rnorm(100, 10, 2)\n")
cat("  fit <- fit_distribution(data, 'normal')\n")
cat("  print(fit)\n\n")

cat("Test in Persian:\n")
cat("  set_language('fa')\n")
cat("  print(fit)  # Output in Persian!\n\n")

cat("For full tests, run:\n")
cat("  source('tests/manual_test_all.R')\n\n")

cat("Package info:\n")
cat(sprintf("  Version: %s\n", packageVersion("distfitr")))
cat(sprintf("  Installed: %s\n", 
            format(as.POSIXct(file.info(
              system.file(package = "distfitr"))$mtime), 
              "%Y-%m-%d %H:%M:%S")))

cat("\n🎉 Happy analyzing! 🚀\n\n")
