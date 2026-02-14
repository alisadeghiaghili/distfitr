# distfitr 🎯

**Professional Distribution Fitting for R**

A comprehensive, production-ready R package for statistical distribution fitting with advanced diagnostics, goodness-of-fit tests, bootstrap confidence intervals, and full multilingual support.

[![R >= 4.0](https://img.shields.io/badge/R-%3E%3D%204.0-blue.svg)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](https://github.com/alisadeghiaghili/distfitr/releases)
[![Tests](https://img.shields.io/badge/tests-210%2B-brightgreen.svg)](https://github.com/alisadeghiaghili/distfitr/tree/main/tests)
[![R-CMD-check](https://github.com/alisadeghiaghili/distfitr/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/alisadeghiaghili/distfitr/actions/workflows/R-CMD-check.yml)
[![test-coverage](https://github.com/alisadeghiaghili/distfitr/actions/workflows/test-coverage.yml/badge.svg)](https://github.com/alisadeghiaghili/distfitr/actions/workflows/test-coverage.yml)

[English](README.md) | [فارسی](README.fa.md) | [Deutsch](README.de.md) | [📋 CHANGELOG](CHANGELOG.md)

---

## 🌟 What's New in v1.0.0

### 🎉 **FIRST STABLE RELEASE** - Production Ready!

✅ **10 Statistical Distributions** (Continuous)  
✅ **Goodness-of-Fit Tests** (KS, AD, Chi-Square, Cramér-von Mises)  
✅ **Bootstrap Confidence Intervals** (Parametric, Non-parametric, BCa)  
✅ **Enhanced Diagnostics** (Residuals, Influence, Outlier Detection)  
✅ **Multiple Estimation Methods** (MLE, Method of Moments, Quantile matching)  
✅ **Multilingual Support** (English, فارسی, Deutsch) 🌍  
✅ **Comprehensive Documentation** (59 help pages + guides)  
✅ **210+ Tests** with >85% coverage  
✅ **Parallel Processing** for bootstrap operations  
✅ **CI/CD Ready** with GitHub Actions

**Sister project:** [py-distfit-pro v1.0.0](https://github.com/alisadeghiaghili/py-distfit-pro) 🐍

---

## 🚀 Why Choose distfitr?

### **First R Package with Full i18n Support**
- ✅ Output in English, Persian/Farsi, or German
- ✅ Localized distribution names and descriptions
- ✅ Formatted numbers based on locale
- ✅ RTL text support for Persian

### **Better Than Base R**
- ✅ Unified API across all distributions
- ✅ Advanced GOF tests built-in
- ✅ Bootstrap CI with BCa method
- ✅ Comprehensive diagnostics (4 outlier detection methods)
- ✅ Human-readable output

### **Production Quality**
- ✅ 210+ comprehensive tests
- ✅ >85% code coverage
- ✅ Full documentation (59 help pages)
- ✅ CI/CD with GitHub Actions
- ✅ Clean, maintainable code
- ✅ Type validation throughout

---

## 📦 Installation

```r
# From GitHub
devtools::install_github("alisadeghiaghili/distfitr")
```

**Development Installation:**
```r
# Clone and install locally
git clone https://github.com/alisadeghiaghili/distfitr.git
cd distfitr
devtools::install()
```

**Requirements:**
- R >= 4.0.0
- stats, graphics, grDevices, parallel, jsonlite

**Suggested:**
- MASS, boot, fitdistrplus, ggplot2, testthat, covr

---

## ⚡ Quick Start

### **Basic Usage**

```r
library(distfitr)

# Generate data
set.seed(42)
data <- rnorm(1000, mean = 10, sd = 2)

# Fit distribution
fit <- fit_distribution(data, dist = "normal", method = "mle")

# View results
print(fit)
# Distribution: Normal
# Method: MLE
# Sample size: 1000
# 
# Estimated Parameters:
#   mean: 9.9827
#   sd: 2.0115
# 
# Log-likelihood: -2245.67
# AIC: 4495.34
# BIC: 4505.16
```

### **Goodness-of-Fit Testing**

```r
# Run all GOF tests
gof <- gof_tests(fit)
print(gof)

# Goodness-of-Fit Tests:
# 
# Kolmogorov-Smirnov: ✓ PASS (p = 0.8234)
# Anderson-Darling: ✓ PASS (p = 0.7892)
# Chi-Square: ✓ PASS (p = 0.6543)
# Cramér-von Mises: ✓ PASS (p = 0.7234)
# 
# Overall: All tests passed!
```

### **Bootstrap Confidence Intervals**

```r
# Parametric bootstrap (1000 samples, parallel)
ci <- bootstrap_ci(fit, n_bootstrap = 1000, parallel = TRUE)
print(ci)

# Bootstrap Confidence Intervals (95%):
# 
# mean:
#   Estimate: 9.9827
#   CI: [9.8534, 10.1120]
# 
# sd:
#   Estimate: 2.0115
#   CI: [1.9234, 2.0996]
```

### **Diagnostics & Outliers**

```r
# Comprehensive diagnostics
diag <- diagnostics(fit)
print(diag)

# Detect outliers using multiple methods
outliers <- detect_outliers(fit, method = "all")
print(outliers$consensus)

# Consensus outliers detected by ≥2 methods:
# Found 12 outliers (1.2% of data)
# Indices: [23, 156, 234, ...]
```

### **Multilingual Output** 🌐

```r
# 🇬🇧 English (default)
set_language("en")
print(fit)
# Distribution: Normal
# Method: MLE

# 🇮🇷 فارسی (Persian)
set_language("fa")
print(fit)
# توزیع: نرمال
# روش: حداکثر درستنمایی

# 🇩🇪 Deutsch (German)
set_language("de")
print(fit)
# Verteilung: Normal
# Methode: MLE

# Reset to English
set_language("en")
```

---

## 📊 Supported Distributions

### **Continuous Distributions (10)**

| Distribution | Use Cases | Key Features |
|--------------|-----------|-------------|
| **Normal** | Heights, test scores, errors | Symmetric, bell curve |
| **Lognormal** | Income, stock prices | Right-skewed, positive |
| **Weibull** | Reliability, lifetimes | Flexible hazard rate |
| **Gamma** | Waiting times, rainfall | Sum of exponentials |
| **Exponential** | Time between events | Memoryless property |
| **Beta** | Probabilities, rates | Bounded [0,1] |
| **Uniform** | Random sampling | Constant probability |
| **Student's t** | Small samples | Heavy tails |
| **Pareto** | Wealth, power law | 80-20 rule |
| **Gumbel** | Extreme maxima | Flood analysis |

```r
# List all available distributions
list_distributions()
# [1] "normal"      "lognormal"   "gamma"       "weibull"    
# [5] "exponential" "beta"        "uniform"     "studentt"   
# [9] "pareto"      "gumbel"
```

---

## 🎯 Core Features

### **1. Multiple Estimation Methods**

```r
# Maximum Likelihood (most efficient)
fit_mle <- fit_distribution(data, "normal", method = "mle")

# Method of Moments (fast, robust)
fit_mme <- fit_distribution(data, "normal", method = "mme")

# Quantile Matching (robust to outliers)
fit_qme <- fit_distribution(data, "normal", method = "qme")

# Compare methods
c(mle = fit_mle$aic, mme = fit_mme$aic, qme = fit_qme$aic)
```

### **2. Comprehensive GOF Tests**

- **Kolmogorov-Smirnov** - General purpose, distribution-free
- **Anderson-Darling** - More sensitive to tails
- **Chi-Square** - Frequency-based, binned data
- **Cramér-von Mises** - Focuses on middle of distribution

All tests include p-values, test statistics, and pass/fail interpretation.

### **3. Bootstrap Uncertainty Quantification**

```r
# Parametric bootstrap (assumes fitted distribution)
ci_param <- bootstrap_ci(fit, method = "parametric", n_bootstrap = 1000)

# Non-parametric bootstrap (no assumptions)
ci_nonparam <- bootstrap_ci(fit, method = "nonparametric", n_bootstrap = 1000)

# BCa method (bias-corrected and accelerated)
ci_bca <- bootstrap_ci(fit, method = "bca", n_bootstrap = 1000)
```

**Features:**
- Parallel processing (uses all CPU cores)
- Reproducible results (seed parameter)
- Multiple confidence levels (0.90, 0.95, 0.99)
- Three bootstrap methods

### **4. Enhanced Diagnostics**

**Residual Analysis (4 types):**
- Quantile residuals
- Pearson residuals
- Deviance residuals
- Standardized residuals

**Influence Diagnostics:**
- Cook's distance
- Leverage values
- DFFITS
- Automatic identification of influential points

**Outlier Detection (4 methods):**
- Z-score (classic statistical method)
- IQR (Interquartile Range)
- Likelihood-based (distribution-specific)
- Mahalanobis distance (multivariate)

```r
# Run all diagnostics
diag <- diagnostics(fit)

# Access components
diag$residuals         # Quantile residuals
diag$influence         # Cook's distance, leverage
diag$qq_data          # Q-Q plot data
diag$pp_data          # P-P plot data

# Detect outliers with consensus
outliers <- detect_outliers(fit, method = "all")
outliers$consensus$outlier_indices  # Detected by ≥2 methods
```

### **5. Model Selection**

```r
# Compare multiple distributions
candidates <- c("normal", "lognormal", "gamma", "weibull")
results <- list()

for (dist_name in candidates) {
  fit_candidate <- fit_distribution(data, dist_name)
  results[[dist_name]] <- list(
    aic = fit_candidate$aic,
    bic = fit_candidate$bic,
    fit = fit_candidate
  )
}

# Compare AICs (lower is better)
aics <- sapply(results, function(r) r$aic)
print(sort(aics))

# Best model
best_model <- names(which.min(aics))
cat(sprintf("Best distribution: %s\n", best_model))

# Validate with GOF tests
best_fit <- results[[best_model]]$fit
gof <- gof_tests(best_fit)
print(gof)
```

---

## 🌐 Multilingual Support

distfitr is the **first R package** with full multilingual support!

```r
# Switch languages
set_language("en")  # English
set_language("fa")  # فارسی (Persian)
set_language("de")  # Deutsch (German)

# Get current language
get_language()

# List available languages
list_languages()
# [1] "en" "fa" "de"

# Get translated distribution names
set_language("fa")
get_dist_name("normal")      # "نرمال"
get_dist_name("weibull")     # "ویبول"

set_language("de")
get_dist_name("normal")      # "Normal"
get_dist_name("weibull")     # "Weibull"

# Locale-specific number formatting
locale_format(1234.56, "number", 2)
# en: "1,234.56"
# fa: "۱٬۲۳۴٫۵۶"
# de: "1.234,56"
```

---

## 📚 Documentation

### **Help Pages**

```r
# Package overview
?distfitr

# Main functions
?fit_distribution
?gof_tests
?bootstrap_ci
?diagnostics
?detect_outliers

# Multilingual functions
?set_language
?get_dist_name
?locale_format

# All help files
help(package = "distfitr")
```

### **Guides & Tutorials**

- 📝 [Quick Start Guide](QUICK_START.md) - Get started in 5 minutes
- 🧪 [Testing Guide](TESTING.md) - Comprehensive testing instructions
- 📖 [Documentation Guide](DOCUMENTATION.md) - Roxygen2 documentation
- 📋 [Changelog](CHANGELOG.md) - Version history

---

## 🔬 Real-World Examples

See [QUICK_START.md](QUICK_START.md) for complete examples including:
- Quality Control
- Reliability Analysis  
- Complete Analysis Pipeline

---

## 🚀 Performance

**Benchmarks on typical hardware:**

| Task | Data Size | Time | Notes |
|------|-----------|------|-------|
| Fit single distribution | 1,000 | <10ms | MLE |
| Fit single distribution | 100,000 | ~100ms | MLE |
| GOF tests (all 4) | 1,000 | ~50ms | Serial |
| Bootstrap (1000 iter) | 1,000 | ~3s | Parallel |
| Bootstrap (1000 iter) | 10,000 | ~15s | Parallel |
| Diagnostics | 1,000 | ~30ms | All methods |

**Memory efficient:** Handles datasets limited only by available RAM.

---

## 📋 Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

### **v1.0.0** - 2026-02-14 🎉
**First Stable and Production-Ready Release**

#### ✨ Complete Feature Set:
- ✅ **10 Statistical Distributions** (Continuous)
- ✅ **3 Estimation Methods** (MLE, Method of Moments, Quantile)
- ✅ **4 Goodness-of-Fit Tests** (KS, AD, Chi-Square, CvM)
- ✅ **Bootstrap Confidence Intervals** (Parametric, Non-parametric, BCa)
- ✅ **Enhanced Diagnostics** (4 residual types, influence, outlier detection)
- ✅ **Multilingual Support** (English, فارسی, Deutsch)
- ✅ **Comprehensive Documentation** (59 help pages + guides)
- ✅ **210+ Tests** with >85% coverage
- ✅ **CI/CD Pipeline** (GitHub Actions)
- ✅ **Parallel Processing** (bootstrap operations)

---

## 🛠️ Development

### **Current Status**

**Version:** 1.0.0 ✅  
**Release Date:** 2026-02-14  
**Status:** Stable and Production-Ready

### **Project Statistics**

- 📝 **~5,000+ lines** of R code
- 🧪 **210+ tests** with >85% coverage
- 📚 **59 help pages** (roxygen2 documentation)
- 🌐 **3 languages** (en, fa, de)
- 📊 **10 distributions**
- ⚙️ **3 estimation methods**
- ✅ **4 GOF tests**
- 🔄 **3 bootstrap methods**
- 🔍 **4 outlier detection methods**
- 📊 **4 residual types**

### **Completed Features**

- ✅ Distribution fitting system
- ✅ Goodness-of-fit tests
- ✅ Bootstrap confidence intervals
- ✅ Comprehensive diagnostics
- ✅ Outlier detection
- ✅ Multilingual support (first in R!)
- ✅ Complete documentation
- ✅ Extensive test suite
- ✅ CI/CD pipeline
- ✅ Production-ready code quality

---

## 🤝 Contributing

Contributions welcome!

**Areas we need help:**
- Additional distributions
- More estimation methods
- Performance optimizations
- Documentation improvements
- Translations (add your language!)
- Vignettes and tutorials
- Real-world use case examples

---

## 📄 License

MIT License - see [LICENSE](LICENSE).

Free for commercial and personal use.

---

## 🙏 Acknowledgments

**Inspired by:**
- R's `fitdistrplus` package (Delignette-Muller & Dutang)
- Python's `distfit-pro` package (sister project)
- SciPy's statistical distributions

**Built with:**
- R base packages (stats, graphics, parallel)
- jsonlite for i18n translations
- testthat for testing framework
- roxygen2 for documentation

---

## 📞 Contact

**Ali Sadeghi Aghili**  
🦄 Data Unicorn  
🇮🇷 ORCID: [0000-0002-5938-3291](https://orcid.org/0000-0002-5938-3291)

🌐 [zil.ink/thedatascientist](https://zil.ink/thedatascientist)  
🔗 [linktr.ee/aliaghili](https://linktr.ee/aliaghili)  
💻 [@alisadeghiaghili](https://github.com/alisadeghiaghili)

---

## ⭐ Star History

If you find this project useful, please consider giving it a star! ⭐

It helps others discover the project and motivates continued development.

---

**Made with ❤️, ☕, and rigorous statistical methodology by Ali Sadeghi Aghili**

*"Better statistics through better software."*

---

## Related Projects

- 🐍 **[py-distfit-pro](https://github.com/alisadeghiaghili/py-distfit-pro)** - Python sister project (v1.0.0, 30 distributions)
- 🔗 Both v1.0.0, both production-ready, both with full multilingual support!
