# Changelog

All notable changes to distfitr will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

## [1.1.0] - 2026-02-15

### Added

- **S3 Methods Integration:** Complete set of standard R S3 methods for seamless ecosystem integration
  - `coef()` - Extract fitted distribution parameters as numeric vector
  - `logLik()` - Extract log-likelihood with proper attributes (df, nobs)
  - `AIC()` / `BIC()` - Information criteria for model comparison
  - `nobs()` - Extract sample size
  - `residuals()` - Calculate quantile residuals (with type options)
  - `predict()` - Predict density, probability, or quantiles for new data
  - `plot()` - Create diagnostic plots (density, Q-Q, P-P, CDF, or all)
  - `vcov()` - Variance-covariance matrix placeholder (with informative message)
  - `confint()` - Parameter confidence intervals (via bootstrap)
  - `update()` - Refit with different method or data

- **Plot Methods:** Four built-in diagnostic plot types
  - Density plot (histogram + fitted curve)
  - Q-Q plot (quantile-quantile)
  - P-P plot (probability-probability)
  - CDF plot (empirical vs fitted)
  - All-in-one: 2×2 grid with all four plots

### Fixed

- **Documentation:** Replaced deprecated `@docType package` with modern `"_PACKAGE"` roxygen2 syntax
  - Eliminates warning in roxygen2 >= 7.0
  - Follows current R package development best practices

- **residuals() Method:** Fixed vector output handling from `calculate_residuals()`
  - Previous version expected list structure, actual return was numeric vector
  - Now properly handles both vector and list outputs
  - Includes fallback computation if helper function unavailable

### Changed

- Updated `.onAttach()` startup message to be more concise
- Package documentation updated to reflect v1.1.0 status

### Technical Notes

- All S3 methods properly registered in NAMESPACE
- Methods follow R generic function conventions
- Backward compatible with v1.0.1 (no breaking changes)
- Total 13 S3 methods now available for `distfitr_fit` objects

---

## [1.0.1] - 2026-02-15

### Fixed

- **Critical:** Resolved locked binding error in i18n system that prevented package usage
  - Package-level variables `.pkg_language` and `.pkg_translations` were locked by R's namespace mechanism
  - Error occurred when `init_i18n()` or `set_language()` attempted to modify locked bindings
  - Replaced with environment-based state management (`.pkg_env`) to allow proper mutations
  - All 14 references throughout `R/i18n.R` updated to use environment storage

### Added

- Test suite for i18n state management (`test-i18n_state.R`)
  - Covers initialization, language switching, translation caching
  - Validates state persistence across function calls
  - Prevents regression of locked binding issue

### Technical Notes

- Environment-based storage follows R best practices for package state
- No breaking changes; fully backward compatible
- No new dependencies added

---

## [1.0.0] - 2026-02-14

### First Stable Release - Production Ready

#### Added

**Core Functionality:**
- 10 continuous statistical distributions (Normal, Log-Normal, Gamma, Weibull, Exponential, Beta, Uniform, Student's t, Pareto, Gumbel)
- 3 parameter estimation methods (MLE, Method of Moments, Quantile Matching)
- 4 goodness-of-fit tests (Kolmogorov-Smirnov, Anderson-Darling, Chi-Square, Cramér-von Mises)
- Bootstrap confidence intervals with 3 methods (Parametric, Non-parametric, BCa)
- Parallel processing support for bootstrap operations

**Diagnostics:**
- 4 residual types (Quantile, Pearson, Deviance, Standardized)
- Influence measures (Cook's distance, Leverage, DFFITS)
- 4 outlier detection methods (Z-score, IQR, Likelihood-based, Mahalanobis)
- Consensus outlier detection across multiple methods
- Q-Q and P-P plot data generation

**Internationalization:**
- Full multilingual support (English, Persian/Farsi, German)
- First R package with comprehensive i18n implementation
- JSON-based translation system
- Runtime language switching
- Locale-aware number formatting
- RTL/LTR text direction support
- Persian digit conversion

**Documentation:**
- 59 roxygen2-generated help pages
- Complete function documentation with examples
- Quick Start Guide
- Testing Guide
- Documentation Guide

**Testing & Quality:**
- 210+ test cases across 7 test files
- >85% code coverage
- CI/CD pipeline with GitHub Actions
- R-CMD-check on Ubuntu, macOS, Windows
- Multiple R versions (release, devel, oldrel-1)

#### Technical Details

**Performance:**
- Optimized numerical algorithms
- Efficient memory usage
- Smart caching of intermediate results

**Reliability:**
- Extensive input validation
- Robust error handling
- Convergence checks for iterative methods

**Code Quality:**
- Clean, maintainable architecture
- Type validation throughout
- Production-ready standards

---

## Project Statistics

- **Total Code Lines**: ~5,500+
- **Test Files**: 8
- **Test Cases**: 225+
- **Help Pages**: 70+
- **Distribution Classes**: 10
- **Fitting Methods**: 3
- **Goodness-of-Fit Tests**: 4
- **Bootstrap Methods**: 3
- **Outlier Detection Methods**: 4
- **Residual Types**: 4
- **S3 Methods**: 13
- **Languages**: 3
- **Code Coverage**: >85%

---

## Distribution List

### Continuous Distributions (10)

1. Normal (Gaussian) - Symmetric, bell-shaped
2. Log-Normal - Right-skewed, positive values
3. Gamma - Flexible shape, positive values
4. Weibull - Reliability analysis, failure times
5. Exponential - Time between events, memoryless
6. Beta - Bounded [0,1], rates and proportions
7. Uniform - Constant probability, random sampling
8. Student's t - Heavy tails, small samples
9. Pareto - Power law, wealth distribution
10. Gumbel - Extreme value analysis, maxima

---

## Contributors

- Ali Sadeghi Aghili (@alisadeghiaghili) - Creator & Maintainer

---

## License

MIT License - see LICENSE file for details.
