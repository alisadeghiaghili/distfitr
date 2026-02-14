# distfitr 📊

**Advanced Distribution Fitting for R**

A modern, comprehensive R package for statistical distribution fitting with enhanced diagnostics, goodness-of-fit tests, and bootstrap confidence intervals.

[![R-CMD-check](https://img.shields.io/badge/R--CMD--check-passing-brightgreen.svg)](https://github.com/alisadeghiaghili/distfitr)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](https://github.com/alisadeghiaghili/distfitr)

[English](#english) | [فارسی](#فارسی)

---

## English

### 🌟 Why distfitr?

**Enhanced companion to fitdistrplus** with:

✅ **4 Goodness-of-Fit Tests** (KS, AD, Chi-Square, Cramér-von Mises)  
✅ **Advanced Diagnostics** (4 residual types, influence measures, outlier detection)  
✅ **Bootstrap Confidence Intervals** (Parametric, Non-parametric, BCa)  
✅ **Multilingual Support** (English, فارسی, Deutsch)  
✅ **Parallel Processing** (Multi-core support)  
✅ **Self-Documenting Output** (Human-readable summaries)  

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

Phase 1 includes **10 essential distributions**:

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

### 🌐 Multilingual Support

```r
# Set language
set_language("en")  # English (default)
set_language("fa")  # فارسی
set_language("de")  # Deutsch

# All outputs will be in selected language
print(fit)
summary(fit)
```

### 🚀 Performance

Optimized for speed with:
- Parallel bootstrap (uses all CPU cores)
- Efficient numerical algorithms
- Smart caching of intermediate results

---

## فارسی

### 🌟 چرا distfitr؟

**ابزار پیشرفته مکمل fitdistrplus** با:

✅ **4 تست برازش** (KS، AD، خی‌دو، کرامر-فون‌میزس)  
✅ **تشخیص‌های پیشرفته** (4 نوع باقیمانده، معیارهای تأثیرگذاری، تشخیص نقاط پرت)  
✅ **فواصل اطمینان بوت‌استرپ** (پارامتریک، ناپارامتریک، BCa)  
✅ **پشتیبانی چندزبانه** (انگلیسی، فارسی، آلمانی)  
✅ **پردازش موازی** (استفاده از چند هسته)  
✅ **خروجی خودتوضیح** (خلاصه‌های قابل فهم)  

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

# تولید داده نمونه
set.seed(42)
data <- rnorm(1000, mean = 10, sd = 2)

# برازش توزیع
fit <- fit_distribution(data, dist = "normal", method = "mle")

# مشاهده نتایج
print(fit)
summary(fit)

# تست‌های برازش
gof_results <- gof_tests(fit)
print(gof_results)

# فواصل اطمینان بوت‌استرپ
ci_results <- bootstrap_ci(fit, n_bootstrap = 1000, parallel = TRUE)
print(ci_results)

# تشخیص‌ها
diag_results <- diagnostics(fit)
plot(diag_results)
```

---

## 📚 Documentation

Comprehensive documentation coming soon!

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
