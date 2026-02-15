# Changelog

All notable changes to distfitr will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

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

- **Total Code Lines**: ~5,000+
- **Test Files**: 7 (v1.0.0) + 1 (v1.0.1)
- **Test Cases**: 210+ (v1.0.0) + 15 (v1.0.1)
- **Help Pages**: 59
- **Distribution Classes**: 10
- **Fitting Methods**: 3
- **Goodness-of-Fit Tests**: 4
- **Bootstrap Methods**: 3
- **Outlier Detection Methods**: 4
- **Residual Types**: 4
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
