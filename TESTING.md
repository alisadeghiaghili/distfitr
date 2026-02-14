# Testing & Installation Guide

## Quick Installation

### From GitHub (Development Version)

```r
# Install devtools if needed
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Install distfitr
devtools::install_github("alisadeghiaghili/distfitr")

# Load package
library(distfitr)
```

### Dependencies

**Required (Imports):**
- stats
- graphics
- grDevices
- parallel
- jsonlite

**Suggested (for full functionality):**
```r
install.packages(c("MASS", "boot", "fitdistrplus", "ggplot2", 
                   "testthat", "covr", "knitr", "rmarkdown"))
```

## Quick Test

### 1-Minute Smoke Test

```r
library(distfitr)

# Generate data
set.seed(42)
data <- rnorm(100, mean = 10, sd = 2)

# Fit
fit <- fit_distribution(data, "normal")
print(fit)

# If this works, installation is successful!
```

## Comprehensive Testing

### Manual Test Script (Recommended)

**Run the comprehensive test script:**

```r
# From R console
source("tests/manual_test_all.R")
```

This script tests:
- ✅ Distribution system (10 distributions)
- ✅ Fitting methods (MLE, MME, QME)
- ✅ GOF tests (KS, AD, Chi-Square, CvM)
- ✅ Bootstrap confidence intervals
- ✅ Diagnostics and outlier detection
- ✅ Multilingual support (en, fa, de)
- ✅ Edge cases
- ✅ Print methods

**Expected output:** All tests should show ✓ (checkmark)

### Automated Test Suite

**Run all 210+ tests:**

```r
# Using devtools
devtools::test()

# Or using testthat directly
testthat::test_dir("tests/testthat")
```

**Expected result:**
```
Test summary
══ testthat results ═══════════════════════════════════════════
✔ | F | W | S | OK | Context
✔ |   |   |   | 40 | distributions
✔ |   |   |   | 45 | fitting
✔ |   |   |   | 30 | gof
✔ |   |   |   | 25 | bootstrap
✔ |   |   |   | 25 | diagnostics
✔ |   |   |   | 25 | i18n
✔ |   |   |   | 20 | edge-cases

[ FAIL 0 | WARN 0 | SKIP 0 | PASS 210 ]
```

### Test Individual Components

**Test specific file:**
```r
testthat::test_file("tests/testthat/test-fitting.R")
```

**Test by pattern:**
```r
testthat::test_dir("tests/testthat", filter = "gof")
```

### Test Coverage

**Generate coverage report:**

```r
library(covr)

# Calculate coverage
cov <- package_coverage()

# View in browser
report(cov)

# Show untested code
zero_coverage(cov)

# Coverage percentage
percent_coverage(cov)
```

**Target:** >85% coverage

## R CMD check

**Full package check (like CRAN):**

```r
# Using devtools
devtools::check()

# Or from command line
R CMD build .
R CMD check distfitr_0.2.1.tar.gz
```

**Expected result:**
```
── R CMD check results ────────────────────────────────────────
Status: OK

R CMD check succeeded
```

## Platform-Specific Testing

### Windows

```r
# Check Windows-specific issues
devtools::check_win_devel()
devtools::check_win_release()
```

### macOS

```r
# Check macOS build
devtools::check_mac_release()
```

### Linux

Tests run automatically on GitHub Actions (Ubuntu)

## Feature-Specific Tests

### Test Multilingual Support

```r
library(distfitr)

# Test all languages
for (lang in c("en", "fa", "de")) {
  set_language(lang)
  
  cat(sprintf("\n=== Testing %s ===\n", lang))
  
  # Fit and print
  data <- rnorm(50, 10, 2)
  fit <- fit_distribution(data, "normal")
  print(fit)
  
  # Test translation
  cat("\nDistribution names:\n")
  for (dist in c("normal", "gamma", "weibull")) {
    cat(sprintf("  %s: %s\n", dist, get_dist_name(dist)))
  }
}

set_language("en")  # Reset
```

### Test Bootstrap Performance

```r
library(distfitr)

set.seed(42)
data <- rnorm(100, 10, 2)
fit <- fit_distribution(data, "normal")

# Sequential
start <- Sys.time()
boot_seq <- bootstrap_ci(fit, n_bootstrap = 1000, parallel = FALSE)
time_seq <- Sys.time() - start

# Parallel
start <- Sys.time()
boot_par <- bootstrap_ci(fit, n_bootstrap = 1000, parallel = TRUE)
time_par <- Sys.time() - start

cat(sprintf("Sequential: %.2f seconds\n", time_seq))
cat(sprintf("Parallel: %.2f seconds\n", time_par))
cat(sprintf("Speedup: %.2fx\n", time_seq / time_par))
```

### Test All Distributions

```r
library(distfitr)

set.seed(42)

test_cases <- list(
  normal = rnorm(100, 5, 2),
  lognormal = rlnorm(100, 1, 0.5),
  gamma = rgamma(100, shape = 2, rate = 1),
  weibull = rweibull(100, shape = 2, scale = 1),
  exponential = rexp(100, rate = 1),
  beta = rbeta(100, shape1 = 2, shape2 = 5),
  uniform = runif(100, 0, 10),
  studentt = rt(100, df = 5)
)

for (dist_name in names(test_cases)) {
  cat(sprintf("\nTesting %s distribution...\n", dist_name))
  
  fit <- fit_distribution(test_cases[[dist_name]], dist_name)
  gof <- gof_tests(fit)
  
  cat(sprintf("  AIC: %.2f\n", fit$aic))
  cat(sprintf("  GOF: %s\n", 
              ifelse(gof$all_passed, "PASSED", "FAILED")))
}
```

## Troubleshooting

### Common Issues

**1. Installation fails:**
```r
# Try with dependencies
devtools::install_github("alisadeghiaghili/distfitr", 
                        dependencies = TRUE)
```

**2. Tests fail on Windows:**
```r
# Parallel processing may fail on Windows
# Use parallel = FALSE for bootstrap
bootstrap_ci(fit, parallel = FALSE)
```

**3. i18n not working:**
```r
# Check jsonlite is installed
install.packages("jsonlite")

# Check locale files exist
list.files(system.file("locales", package = "distfitr"))
# Should show: en.json, fa.json, de.json
```

**4. Tests timeout:**
```r
# Reduce bootstrap samples in tests
bootstrap_ci(fit, n_bootstrap = 100)  # Instead of 1000
```

### Debug Mode

**Run tests with detailed output:**

```r
# Verbose testing
testthat::test_dir("tests/testthat", 
                   reporter = testthat::DebugReporter$new())

# Or with location reporter
testthat::test_file("tests/testthat/test-fitting.R",
                   reporter = "location")
```

**Check package status:**

```r
# Package info
packageVersion("distfitr")
packageDescription("distfitr")

# Check loaded functions
ls("package:distfitr")

# Check for conflicts
conflicts(detail = TRUE)
```

## Performance Benchmarks

### Fitting Speed

```r
library(distfitr)
library(microbenchmark)

set.seed(42)
data <- rnorm(1000, 10, 2)

# Benchmark fitting
microbenchmark(
  mle = fit_distribution(data, "normal", method = "mle"),
  mme = fit_distribution(data, "normal", method = "mme"),
  qme = fit_distribution(data, "normal", method = "qme"),
  times = 100
)
```

### Bootstrap Speed

```r
fit <- fit_distribution(data, "normal")

microbenchmark(
  parametric = bootstrap_ci(fit, method = "parametric", 
                           n_bootstrap = 100, seed = 42),
  nonparametric = bootstrap_ci(fit, method = "nonparametric", 
                              n_bootstrap = 100, seed = 42),
  times = 10
)
```

## CI/CD Status

**Check GitHub Actions:**

Visit: https://github.com/alisadeghiaghili/distfitr/actions

Workflows:
- ✅ R-CMD-check (Ubuntu, macOS, Windows)
- ✅ test-coverage (Ubuntu with codecov)

**Badges in README:**
- R-CMD-check status
- Test coverage percentage
- Version number

## Next Steps After Testing

### If all tests pass ✅

1. **Use in your project:**
   ```r
   library(distfitr)
   # Your analysis here
   ```

2. **Contribute:**
   - Report issues: https://github.com/alisadeghiaghili/distfitr/issues
   - Submit PRs: https://github.com/alisadeghiaghili/distfitr/pulls
   - Add translations for new languages

3. **Cite the package:**
   ```r
   citation("distfitr")
   ```

### If tests fail ❌

1. Check error messages carefully
2. Review dependencies
3. Try manual test script first
4. Report issue with:
   - R version: `R.version.string`
   - Platform: `.Platform$OS.type`
   - Package version: `packageVersion("distfitr")`
   - Error message and traceback

---

## Summary

**Quick verification:**
```r
# 30-second test
library(distfitr)
data <- rnorm(100, 10, 2)
fit <- fit_distribution(data, "normal")
print(fit)
gof_tests(fit)
```

**Full verification:**
```r
# 5-minute test
source("tests/manual_test_all.R")  # Manual tests
devtools::test()                    # Automated tests (210+)
devtools::check()                   # R CMD check
```

**Coverage verification:**
```r
# 10-minute test
covr::package_coverage()            # Calculate coverage
covr::report(cov)                   # View report
```

---

**Status:** distfitr v0.2.1 is production-ready! 🚀

**Test Coverage:** >85% (210+ tests)

**Platforms:** ✅ Ubuntu | ✅ macOS | ✅ Windows

**Languages:** 🇬🇧 English | 🇮🇷 فارسی | 🇩🇪 Deutsch
