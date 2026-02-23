# distfitr 🎯

**Professional Distribution Fitting for R**

A comprehensive, production-ready R package for statistical distribution fitting with advanced diagnostics, goodness-of-fit tests, bootstrap confidence intervals, and full multilingual support.

[![R-CMD-check](https://github.com/alisadeghiaghili/distfitr/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/alisadeghiaghili/distfitr/actions/workflows/R-CMD-check.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.1.0-green.svg)](https://github.com/alisadeghiaghili/distfitr/releases)

[English](README.md) | [فارسی](README.fa.md) | [Deutsch](README.de.md)

---

## What is distfitr?

distfitr fits statistical distributions to data and gives you everything you need to evaluate the fit: parameter estimates, goodness-of-fit tests, bootstrap confidence intervals, and diagnostics — all with a unified API and multilingual output.

---

## Installation

```r
# From GitHub
devtools::install_github("alisadeghiaghili/distfitr")
```

Requirements: R >= 4.0.0, packages: `stats`, `graphics`, `grDevices`, `parallel`, `jsonlite`

---

## Quick Start

```r
library(distfitr)

set.seed(42)
data <- rnorm(1000, mean = 10, sd = 2)

# Fit
fit <- fit_distribution(data, "normal", method = "mle")
print(fit)

# Goodness-of-fit
gof <- gof_tests(fit)
print(gof)

# Bootstrap confidence intervals
ci <- bootstrap_ci(fit, n_bootstrap = 1000)
print(ci)

# Diagnostics & outlier detection
diag <- diagnostics(fit)
outliers <- detect_outliers(fit, method = "all")
```

---

## Multilingual Output 🌐

```r
set_language("en")   # English (default)
set_language("fa")   # فارسی
set_language("de")   # Deutsch

get_language()
list_languages()
```

---

## Supported Distributions

| Distribution | Typical Use |
|---|---|
| Normal | Heights, measurement errors |
| Lognormal | Income, stock prices |
| Weibull | Reliability, lifetimes |
| Gamma | Waiting times, rainfall |
| Exponential | Time between events |
| Beta | Probabilities, rates |
| Uniform | Simulation |
| Student's t | Small samples, heavy tails |
| Pareto | Power-law phenomena |
| Gumbel | Extreme value analysis |

```r
list_distributions()
```

---

## Core Features

**3 estimation methods:** MLE, Method of Moments, Quantile Matching

**4 goodness-of-fit tests:** Kolmogorov-Smirnov, Anderson-Darling, Chi-Square, Cramér-von Mises

**3 bootstrap methods:** Parametric, Non-parametric, BCa — with parallel processing

**Diagnostics:** 4 residual types, influence measures (Cook's distance, leverage, DFFITS), 4 outlier detection methods

**Model selection:**
```r
candidates <- c("normal", "lognormal", "gamma", "weibull")
fits <- lapply(candidates, function(d) fit_distribution(data, d))
aics <- sapply(fits, function(f) f$aic)
best <- candidates[which.min(aics)]
```

---

## License

MIT — see [LICENSE](LICENSE).

---

## Contact

**Ali Sadeghi Aghili**  
🌐 [zil.ink/thedatascientist](https://zil.ink/thedatascientist) | 💻 [@alisadeghiaghili](https://github.com/alisadeghiaghili)
