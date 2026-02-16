# distfitr 1.1.1 (Development)

## Bug Fixes

### Tests
- Fixed test failures in `test-fitting.R` by using `as.numeric()` to ignore names in parameter comparisons
- Fixed test failures in `test-gof.R` by:
  - Changing `alpha` parameter to `significance_level` to match function signature
  - Adding proper `passed` field checks for all GOF tests
- Fixed test failures in `test-bootstrap.R` by:
  - Properly handling bootstrap CI structure with named vectors
  - Improving error validation tests
  - Adding detailed error messages for debugging

### GOF Tests
- Added `passed` field to all individual GOF test results (ks_test, ad_test, chi_square_test, cvm_test)
- Added `alpha` as alias parameter for `significance_level` in `gof_tests()` for backward compatibility
- GOF test functions now accept `significance_level` parameter and properly compute the `passed` field

### Bootstrap
- Bootstrap CI structure now properly validated in tests
- Improved error handling for invalid input validation

# distfitr 1.1.0

## New Features

### S3 Methods
- Added comprehensive S3 method support for `distfitr_fit` objects:
  - `coef()` - Extract fitted parameters
  - `logLik()` - Extract log-likelihood with proper attributes
  - `AIC()` / `BIC()` - Model selection criteria
  - `nobs()` - Number of observations
  - `residuals()` - Calculate residuals (quantile, pearson, deviance, standardized)
  - `predict()` - Predictions (density, probability, quantile)
  - `plot()` - Visualization (density, Q-Q, P-P, CDF plots)
  - `update()` - Refit with modified parameters
  - `vcov()` - Placeholder (directs to bootstrap_ci)
  - `confint()` - Confidence intervals via bootstrap

## Bug Fixes

### i18n System
- Fixed critical locked binding error in i18n system
- Replaced package-level variables with environment-based storage
- Added test coverage for i18n state management

### Documentation
- Fixed deprecated `@docType package` warning by using `_PACKAGE` special string
- Fixed encoding issues by replacing Unicode characters (é → e) in documentation
- Wrapped parallel bootstrap examples in `\donttest{}` for CI compatibility

### Core Functions
- Fixed `residuals()` to handle vector output from `calculate_residuals()`
- Fixed `coef()` to handle list parameters properly
- Fixed `plot.distfitr_diagnostics` to handle atomic vectors
- Added `all_passed` field for backward compatibility in GOF tests

# distfitr 1.0.1

## Bug Fixes
- Fixed i18n locked binding error that prevented package usage
- Use environment instead of package-level variables for i18n state

# distfitr 1.0.0

Initial CRAN release.

## Features
- Distribution fitting with MLE, MME, and QME methods
- Support for common distributions (normal, lognormal, gamma, weibull, exponential, beta, uniform)
- Goodness-of-fit tests (KS, AD, Chi-Square, CvM)
- Bootstrap confidence intervals (parametric, non-parametric, BCa)
- Diagnostic plots and tools
- Bilingual support (English and Farsi)
