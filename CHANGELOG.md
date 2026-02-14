# Changelog

All notable changes to the distfitr package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned for v0.2.0
- Multilingual support (Persian, German)
- Additional distributions (Cauchy, Chi-Square, F-distribution)
- Weighted data support
- More visualization options
- Vignettes and tutorials
- Unit tests with testthat
- CRAN submission preparation

## [0.1.0] - 2026-02-14

### Added - Initial Release

#### Core Functionality
- **10 Essential Distributions**: Normal, Log-Normal, Gamma, Weibull, Exponential, Beta, Uniform, Student's t, Pareto, Gumbel
- **3 Estimation Methods**:
  - Maximum Likelihood Estimation (MLE)
  - Method of Moments (MME)
  - Quantile Matching Estimation (QME)
- **Model Selection Criteria**: AIC, BIC, Log-likelihood

#### Goodness-of-Fit Tests
- **4 Comprehensive GOF Tests**:
  - Kolmogorov-Smirnov (KS) test
  - Anderson-Darling (AD) test - enhanced tail sensitivity
  - Chi-Square test with automatic binning
  - Cramér-von Mises (CvM) test
- Human-readable interpretations for all tests
- Overall pass/fail assessment
- P-values and test statistics for all tests

#### Bootstrap Confidence Intervals
- **3 Bootstrap Methods**:
  - Parametric bootstrap
  - Non-parametric bootstrap
  - BCa (Bias-Corrected and Accelerated) method
- **Parallel Processing Support**:
  - Multi-core computation for faster bootstrap
  - Automatic core detection
  - Cross-platform support (Windows, Unix-like)
- Configurable confidence levels
- Success rate monitoring

#### Advanced Diagnostics
- **4 Residual Types**:
  - Quantile residuals (most robust)
  - Pearson residuals
  - Deviance residuals
  - Standardized residuals
- **Influence Diagnostics**:
  - Cook's distance
  - Leverage values
  - DFFITS
  - Automatic identification of influential observations
- **4 Outlier Detection Methods**:
  - Z-score based
  - IQR (Interquartile Range) based
  - Likelihood-based
  - Mahalanobis distance
  - Consensus outlier identification (flagged by ≥2 methods)
- **Diagnostic Plots**:
  - Q-Q plot
  - P-P plot
  - Residuals plot
  - Residuals histogram with normal overlay

#### API Design
- Clean, consistent S3 object-oriented interface
- Comprehensive print and summary methods
- Informative error messages and warnings
- Self-documenting outputs

#### Documentation
- Complete roxygen2 documentation for all exported functions
- Basic usage examples in all function docs
- Comprehensive example script (`examples/basic_usage.R`)
- README with quick start guide (English + Persian)

#### Package Infrastructure
- MIT License
- DESCRIPTION with proper metadata
- NAMESPACE with selective exports
- .gitignore for R package development
- GitHub repository structure

### Technical Details

#### Dependencies
- **Base R**: stats, graphics, grDevices
- **Recommended**: MASS, boot, parallel, jsonlite
- **Suggested**: fitdistrplus, ggplot2, testthat, knitr, rmarkdown

#### Performance Optimizations
- Efficient numerical algorithms
- Parallel bootstrap computation
- Smart starting values for optimization
- Robust error handling

#### Code Quality
- Clean, readable R code
- Consistent naming conventions (snake_case)
- Comprehensive input validation
- Defensive programming practices

### Known Limitations (to be addressed in future versions)

1. **Distribution Support**: Currently 10 distributions (Phase 1). More coming in v0.2.0.
2. **Multilingual Support**: Interface currently English-only. i18n system planned for v0.2.0.
3. **Weighted Data**: Not yet implemented. Coming in v0.2.0.
4. **Censored Data**: Not supported. Planned for v0.3.0.
5. **Test Coverage**: Unit tests to be added in v0.2.0.
6. **Vignettes**: Long-form tutorials planned for v0.2.0.

### Development Philosophy

**Human-First Design**: Every function output is designed to be immediately understandable by statisticians and data scientists, not just machines.

**Production-Ready**: While this is v0.1.0, the code is written with production quality standards:
- Robust error handling
- Clear documentation
- Consistent API
- Informative outputs

**Enhanced, Not Replacement**: distfitr complements fitdistrplus by adding features that are missing or under-developed, particularly in diagnostics and testing.

### Comparison with fitdistrplus

**Advantages of distfitr**:
- ✅ Built-in comprehensive GOF tests (fitdistrplus has none)
- ✅ Advanced diagnostics (4 residual types, influence measures)
- ✅ Multiple outlier detection methods
- ✅ BCa bootstrap (fitdistrplus has basic bootstrap only)
- ✅ Parallel processing built-in
- ✅ Self-documenting, human-readable outputs

**Advantages of fitdistrplus** (that we plan to add):
- Censored data support (planned v0.3.0)
- MGE and MSE estimation methods (planned v0.2.0)
- More mature, battle-tested codebase
- CRAN availability

### Contributors

- **Ali Sadeghi Aghili** - Initial work and package creation

### Acknowledgments

- Inspired by R's `fitdistrplus` package
- Based on concepts from Python's `distfit-pro` package
- Statistical methods from established literature

---

## Version History Summary

- **v0.1.0** (2026-02-14) - Initial release with core functionality
- **v0.2.0** (Planned Q2 2026) - Multilingual, more distributions, tests, CRAN prep
- **v0.3.0** (Planned Q3 2026) - Censored data, weighted data, performance improvements
- **v1.0.0** (Planned Q4 2026) - Stable API, comprehensive features, CRAN release

---

**Made with ❤️, ☕, and rigorous statistical methodology**
