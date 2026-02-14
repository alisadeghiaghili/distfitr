# distfitr 📊

**Advanced Distribution Fitting for R**

A modern, comprehensive R package for statistical distribution fitting with enhanced diagnostics, goodness-of-fit tests, bootstrap confidence intervals, and multilingual support.

[![R-CMD-check](https://github.com/alisadeghiaghili/distfitr/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/alisadeghiaghili/distfitr/actions/workflows/R-CMD-check.yml)
[![test-coverage](https://github.com/alisadeghiaghili/distfitr/actions/workflows/test-coverage.yml/badge.svg)](https://github.com/alisadeghiaghili/distfitr/actions/workflows/test-coverage.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-0.2.1-blue.svg)](https://github.com/alisadeghiaghili/distfitr)
[![Tests](https://img.shields.io/badge/tests-210%2B-brightgreen.svg)](https://github.com/alisadeghiaghili/distfitr/tree/main/tests/testthat)
[![Coverage](https://img.shields.io/badge/coverage-%3E85%25-brightgreen.svg)](https://github.com/alisadeghiaghili/distfitr)

[English](#english) | [فارسی](#فارسی)

---

## English

### 🌟 Why distfitr?

**Enhanced companion to fitdistrplus** with:

✅ **4 Goodness-of-Fit Tests** (KS, AD, Chi-Square, Cramér-von Mises)  
✅ **Advanced Diagnostics** (4 residual types, influence measures, outlier detection)  
✅ **Bootstrap Confidence Intervals** (Parametric, Non-parametric, BCa)  
✅ **Multilingual Support** (English, فارسی, Deutsch) - **FIRST in R!** 🌍  
✅ **Parallel Processing** (Multi-core support)  
✅ **Self-Documenting Output** (Human-readable summaries)  
✅ **Comprehensive Tests** (210+ tests, >85% coverage)  
✅ **CI/CD Ready** (GitHub Actions, cross-platform)  

### 📦 Installation

```r
# From GitHub (development version)
devtools::install_github("alisadeghiaghili/distfitr")

# From CRAN (coming soon)
install.packages("distfitr")
```

### ⚡ Quick Start

```r
library(distfitr)

# Generate sample data
set.seed(42)
data <- rnorm(1000, mean = 10, sd = 2)

# Fit distribution
fit <- fit_distribution(data, dist = "normal", method = "mle")

# View results
print(fit)
summary(fit)

# Run GOF tests
gof_results <- gof_tests(fit)
print(gof_results)

# Bootstrap confidence intervals
ci_results <- bootstrap_ci(fit, n_bootstrap = 1000, parallel = TRUE)
print(ci_results)

# Diagnostics
diag_results <- diagnostics(fit)
plot(diag_results)
```

### 📊 Supported Distributions

**10 essential distributions**:

- Normal (Gaussian)
- Log-Normal
- Gamma
- Weibull  
- Exponential
- Beta
- Uniform
- Student's t
- Pareto
- Gumbel

### 🎯 Key Features

#### Goodness-of-Fit Tests

```r
# All tests at once
gof <- gof_tests(fit)

# Individual tests
ks_test(fit)
ad_test(fit)  # Anderson-Darling
chi_square_test(fit)
cvm_test(fit)  # Cramér-von Mises
```

#### Advanced Diagnostics

```r
# Multiple residual types
residuals(fit, type = "quantile")
residuals(fit, type = "pearson")
residuals(fit, type = "deviance")
residuals(fit, type = "standardized")

# Influence diagnostics
influence(fit)

# Outlier detection
detect_outliers(fit, method = "zscore")
detect_outliers(fit, method = "iqr")
detect_outliers(fit, method = "likelihood")
detect_outliers(fit, method = "mahalanobis")
```

#### Bootstrap Confidence Intervals

```r
# Parametric bootstrap
bootstrap_ci(fit, method = "parametric", n_bootstrap = 1000)

# Non-parametric bootstrap
bootstrap_ci(fit, method = "nonparametric", n_bootstrap = 1000)

# BCa method (bias-corrected and accelerated)
bootstrap_ci(fit, method = "bca", n_bootstrap = 1000)

# Parallel processing (uses all cores)
bootstrap_ci(fit, n_bootstrap = 1000, parallel = TRUE, n_cores = -1)
```

### 🌐 Multilingual Support (NEW in v0.2.0!)

**First R distribution fitting package with full multilingual support!**

```r
# Set language
set_language("en")  # English (default)
set_language("fa")  # فارسی (Persian)
set_language("de")  # Deutsch (German)

# All outputs will be in selected language
print(fit)
summary(fit)

# Get translated distribution names
get_dist_name("normal")  # "Normal (Gaussian)" / "نرمال (گاوسی)" / "Normal (Gauß)"

# Locale-aware number formatting
locale_format(1234.56, "number", 2)  # "1234.56" / "۱۲۳۴.۵۶" / "1234,56"
```

### ✅ Testing & Quality Assurance (NEW in v0.2.1!)

**Comprehensive test suite with 210+ tests:**

- ✅ Distribution functions (40+ tests)
- ✅ Fitting methods (45+ tests)
- ✅ GOF tests (30+ tests)
- ✅ Bootstrap (25+ tests)
- ✅ Diagnostics (25+ tests)
- ✅ i18n system (25+ tests)
- ✅ Edge cases (20+ tests)

**Continuous Integration:**
- GitHub Actions on Ubuntu, macOS, Windows
- R-release, R-devel, R-oldrel
- Automated test coverage reporting
- Daily scheduled builds

```r
# Run tests locally
devtools::test()

# Check test coverage
covr::package_coverage()
```

### 🚀 Performance

Optimized for speed with:
- Parallel bootstrap (uses all CPU cores)
- Efficient numerical algorithms
- Smart caching of intermediate results
- Translation system with <1ms lookup overhead

### 📈 What's New

**v0.2.1** (2026-02-14)
- ✅ 210+ comprehensive tests with testthat
- ✅ GitHub Actions CI/CD (R-CMD-check + coverage)
- ✅ Cross-platform testing (Ubuntu, macOS, Windows)
- ✅ Test documentation and helper functions
- ✅ >85% test coverage target

**v0.2.0** (2026-02-14)
- 🌍 Full multilingual support (English, Persian, German)
- 🔤 JSON-based translation system
- 🔄 Dynamic language switching
- 🎨 Locale-aware formatting
- ↔️ RTL/LTR text direction support
- 🔢 Persian digit conversion

**v0.1.0** (2026-02-14)
- 📊 10 distributions with 3 estimation methods
- 🧪 4 comprehensive GOF tests
- 🔁 3 bootstrap methods with parallel processing
- 🔍 Advanced diagnostics and outlier detection
- 📝 Production-ready code quality

---

## فارسی

### 🌟 چرا distfitr؟

**ابزار پیشرفته مکمل fitdistrplus** با:

✅ **4 تست برازش** (KS، AD، خی‌دو، کرامر-فون‌میزس)  
✅ **تشخیص‌های پیشرفته** (4 نوع باقیمانده، معیارهای تأثیرگذاری، تشخیص نقاط پرت)  
✅ **فواصل اطمینان بوت‌استرپ** (پارامتریک، ناپارامتریک، BCa)  
✅ **پشتیبانی چندزبانه** (انگلیسی، فارسی، آلمانی) - **اولین در R!** 🌍  
✅ **پردازش موازی** (استفاده از چند هسته)  
✅ **خروجی خودتوضیح** (خلاصه‌های قابل فهم)  
✅ **تست جامع** (بیش از 210 تست، پوشش >85%)  
✅ **آماده CI/CD** (GitHub Actions، چند پلتفرمی)  

### 📦 نصب

```r
# از GitHub (نسخه توسعه)
devtools::install_github("alisadeghiaghili/distfitr")

# از CRAN (به زودی)
install.packages("distfitr")
```

### ⚡ شروع سریع

```r
library(distfitr)

# تنظیم زبان به فارسی
set_language("fa")

# تولید داده نمونه
set.seed(42)
data <- rnorm(1000, mean = 10, sd = 2)

# برازش توزیع
fit <- fit_distribution(data, dist = "normal", method = "mle")

# مشاهده نتایج (به فارسی!)
print(fit)
summary(fit)

# تست‌های برازش (به فارسی!)
gof_results <- gof_tests(fit)
print(gof_results)

# فواصل اطمینان بوت‌استرپ
ci_results <- bootstrap_ci(fit, n_bootstrap = 1000, parallel = TRUE)
print(ci_results)

# تشخیص‌ها
diag_results <- diagnostics(fit)
plot(diag_results)
```

### 🌐 ویژگی چندزبانه (جدید در نسخه 0.2.0!)

**اولین پکیج R برای برازش توزیع با پشتیبانی کامل فارسی!**

```r
# تنظیم زبان
set_language("fa")  # فارسی

# همه خروجی‌ها به فارسی نمایش داده می‌شوند
print(fit)  # نتایج به فارسی
get_dist_name("normal")  # "نرمال (گاوسی)"

# اعداد به صورت فارسی
locale_format(1234.56, "number", 2)  # "۱۲۳۴.۵۶"
```

---

## 📚 Documentation

Comprehensive documentation:
- [CHANGELOG.md](CHANGELOG.md) - Version history and features
- [tests/README.md](tests/README.md) - Test suite documentation
- [inst/NEWS_i18n.md](inst/NEWS_i18n.md) - i18n system details
- Function documentation: `?fit_distribution`, `?gof_tests`, etc.

## 🤝 Contributing

Contributions welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md).

## 📄 License

MIT License - see [LICENSE](LICENSE) file.

## 🙏 Acknowledgments

Inspired by:
- R's `fitdistrplus` package
- Python's `distfit-pro` package
- Best practices from statistical computing community

## 📞 Contact

**Ali Sadeghi Aghili**  
🌐 [zil.ink/thedatascientist](https://zil.ink/thedatascientist)  
🔗 [linktr.ee/aliaghili](https://linktr.ee/aliaghili)  
💻 [@alisadeghiaghili](https://github.com/alisadeghiaghili)

---

**Made with ❤️, ☕, and rigorous statistical methodology**

*"Better statistics through better software."*

**v0.2.1** | 210+ Tests | 🌍 Multilingual (en, fa, de) | 🚀 Production Ready
