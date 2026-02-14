# distfitr Quick Start Guide

## Installation

```r
devtools::install_github("alisadeghiaghili/distfitr")
library(distfitr)
```

## Basic Workflow

### 1. Load Your Data

```r
# Example: Normal distribution
set.seed(42)
data <- rnorm(1000, mean = 10, sd = 2)
```

### 2. Fit a Distribution

```r
# Fit using MLE (default)
fit <- fit_distribution(data, dist = "normal")
print(fit)

# Try different methods
fit_mle <- fit_distribution(data, "normal", method = "mle")
fit_mme <- fit_distribution(data, "normal", method = "mme")
fit_qme <- fit_distribution(data, "normal", method = "qme")
```

### 3. Test Goodness-of-Fit

```r
# Run all GOF tests
gof <- gof_tests(fit)
print(gof)

# Individual tests
ks_test(fit)          # Kolmogorov-Smirnov
ad_test(fit)          # Anderson-Darling
chi_square_test(fit)  # Chi-Square
cvm_test(fit)         # Cramér-von Mises
```

### 4. Get Confidence Intervals

```r
# Bootstrap CI (fast, parametric)
ci <- bootstrap_ci(fit, n_bootstrap = 1000, parallel = TRUE)
print(ci)

# BCa method (more accurate)
ci_bca <- bootstrap_ci(fit, method = "bca", n_bootstrap = 1000)
print(ci_bca)
```

### 5. Run Diagnostics

```r
# Complete diagnostics
diag <- diagnostics(fit)
print(diag)

# Plot diagnostics
plot(diag)  # Shows Q-Q, P-P, residuals, histogram
```

## Available Distributions

```r
# List all available distributions
list_distributions()

# [1] "normal"      "lognormal"   "gamma"       "weibull"    
# [5] "exponential" "beta"        "uniform"     "studentt"   
# [9] "pareto"      "gumbel"
```

### Distribution Examples

```r
# Normal
data <- rnorm(100, mean = 10, sd = 2)
fit <- fit_distribution(data, "normal")

# Gamma
data <- rgamma(100, shape = 2, rate = 1)
fit <- fit_distribution(data, "gamma")

# Weibull
data <- rweibull(100, shape = 2, scale = 1)
fit <- fit_distribution(data, "weibull")

# Exponential
data <- rexp(100, rate = 1)
fit <- fit_distribution(data, "exponential")

# Beta (for data in [0,1])
data <- rbeta(100, shape1 = 2, shape2 = 5)
fit <- fit_distribution(data, "beta")

# Log-Normal
data <- rlnorm(100, meanlog = 1, sdlog = 0.5)
fit <- fit_distribution(data, "lognormal")
```

## Multilingual Support 🌍

```r
# Switch to Persian
set_language("fa")
print(fit)  # Output in Persian!

# Switch to German
set_language("de")
print(fit)  # Ausgabe auf Deutsch!

# Back to English
set_language("en")

# List available languages
list_languages()

# Get translated distribution names
get_dist_name("normal")     # Current language
get_dist_name("weibull")    # Current language
```

## Advanced Features

### Outlier Detection

```r
fit <- fit_distribution(data, "normal")

# Individual methods
outliers_z <- detect_outliers(fit, method = "zscore")
outliers_iqr <- detect_outliers(fit, method = "iqr")
outliers_ll <- detect_outliers(fit, method = "likelihood")
outliers_md <- detect_outliers(fit, method = "mahalanobis")

# All methods + consensus
outliers_all <- detect_outliers(fit, method = "all")
print(outliers_all$consensus)  # Outliers detected by ≥2 methods
```

### Residual Analysis

```r
# Different residual types
resid_q <- calculate_residuals(fit, type = "quantile")
resid_p <- calculate_residuals(fit, type = "pearson")
resid_d <- calculate_residuals(fit, type = "deviance")
resid_s <- calculate_residuals(fit, type = "standardized")

# Plot residuals
hist(resid_q, main = "Quantile Residuals")
qqnorm(resid_q); qqline(resid_q)
```

### Influence Diagnostics

```r
fit <- fit_distribution(data, "normal")

influence <- calculate_influence(fit)

# View influential points
print(influence$influential_indices)

# Plot Cook's distance
plot(influence$cooks_distance, 
     ylab = "Cook's Distance",
     main = "Influence Diagnostics")
abline(h = 4/length(data), col = "red", lty = 2)
```

### Bootstrap Methods Comparison

```r
fit <- fit_distribution(data, "normal")

# Parametric (fastest)
ci_par <- bootstrap_ci(fit, method = "parametric", n_bootstrap = 1000)

# Non-parametric (no distributional assumption)
ci_nonpar <- bootstrap_ci(fit, method = "nonparametric", n_bootstrap = 1000)

# BCa (most accurate, slowest)
ci_bca <- bootstrap_ci(fit, method = "bca", n_bootstrap = 1000)

# Compare results
data.frame(
  Method = c("Parametric", "Non-parametric", "BCa"),
  Lower = c(ci_par$ci$mean["lower"], 
            ci_nonpar$ci$mean["lower"],
            ci_bca$ci$mean["lower"]),
  Upper = c(ci_par$ci$mean["upper"],
            ci_nonpar$ci$mean["upper"],
            ci_bca$ci$mean["upper"])
)
```

### Parallel Processing

```r
# Enable parallel processing for bootstrap
ci <- bootstrap_ci(fit, 
                   n_bootstrap = 5000,
                   parallel = TRUE,
                   n_cores = -1)  # Use all cores

# Or specify number of cores
ci <- bootstrap_ci(fit,
                   n_bootstrap = 5000,
                   parallel = TRUE,
                   n_cores = 4)
```

## Model Comparison

```r
# Fit multiple distributions
fits <- list(
  normal = fit_distribution(data, "normal"),
  gamma = fit_distribution(data, "gamma"),
  weibull = fit_distribution(data, "weibull"),
  lognormal = fit_distribution(data, "lognormal")
)

# Compare AIC/BIC
comparison <- data.frame(
  Distribution = names(fits),
  AIC = sapply(fits, function(f) f$aic),
  BIC = sapply(fits, function(f) f$bic),
  LogLik = sapply(fits, function(f) f$loglik)
)

# Sort by AIC (lower is better)
comparison[order(comparison$AIC), ]

# Run GOF tests for best model
best_fit <- fits[[which.min(comparison$AIC)]]
gof <- gof_tests(best_fit)
print(gof)
```

## Real-World Example

### Complete Analysis Pipeline

```r
library(distfitr)

# 1. Load data
set.seed(42)
data <- rweibull(200, shape = 2, scale = 10)

# 2. Try multiple distributions
candidates <- c("normal", "lognormal", "gamma", "weibull", "exponential")
results <- list()

for (dist in candidates) {
  fit <- tryCatch(
    fit_distribution(data, dist),
    error = function(e) NULL
  )
  
  if (!is.null(fit)) {
    results[[dist]] <- list(
      fit = fit,
      aic = fit$aic,
      bic = fit$bic
    )
  }
}

# 3. Select best model by AIC
aics <- sapply(results, function(r) r$aic)
best_model <- names(which.min(aics))
cat(sprintf("Best model: %s (AIC = %.2f)\n", 
            best_model, min(aics)))

# 4. Validate with GOF tests
best_fit <- results[[best_model]]$fit
gof <- gof_tests(best_fit)
print(gof)

# 5. Get confidence intervals
ci <- bootstrap_ci(best_fit, n_bootstrap = 1000, parallel = TRUE)
print(ci)

# 6. Run diagnostics
diag <- diagnostics(best_fit)
plot(diag)

# 7. Check for outliers
outliers <- detect_outliers(best_fit, method = "all")
if (outliers$consensus$n_outliers > 0) {
  cat(sprintf("Found %d consensus outliers\n", 
              outliers$consensus$n_outliers))
  print(outliers$consensus$outlier_indices)
}

# 8. Summary report
cat("\n=== Final Report ===\n")
cat(sprintf("Distribution: %s\n", best_model))
cat(sprintf("Sample size: %d\n", best_fit$n))
cat(sprintf("Parameters: %s\n", 
            paste(names(best_fit$params), 
                  round(best_fit$params, 3), 
                  sep = "=", collapse = ", ")))
cat(sprintf("GOF: %s\n", 
            ifelse(gof$all_passed, "PASSED", "FAILED")))
cat(sprintf("Outliers: %d\n", 
            outliers$consensus$n_outliers))
```

## Tips & Best Practices

### Choosing a Distribution

1. **Plot your data first:**
   ```r
   hist(data, breaks = 30, main = "Data Distribution")
   ```

2. **Consider data characteristics:**
   - Positive only? Try gamma, weibull, lognormal, exponential
   - Bounded [0,1]? Use beta
   - Symmetric? Try normal, studentt
   - Heavy tails? Try studentt, pareto

3. **Use model selection criteria:**
   - AIC for prediction
   - BIC for explanation (penalizes complexity more)

### Choosing Estimation Method

- **MLE (default):** Most efficient, best for large samples
- **MME:** Simple, robust, good for small samples
- **QME:** Good when you care about specific quantiles

### Choosing Bootstrap Method

- **Parametric:** Fastest, assumes model is correct
- **Non-parametric:** Robust, no assumptions
- **BCa:** Most accurate, slowest, best for final analysis

### Sample Size Guidelines

- **Minimum:** 30 observations
- **GOF tests:** 50+ recommended
- **Bootstrap:** 100+ for reliable CI
- **BCa method:** 200+ for stability

## Common Patterns

### Pattern 1: Quick Fit and Test

```r
fit <- fit_distribution(data, "normal")
gof_tests(fit)
```

### Pattern 2: Full Analysis

```r
fit <- fit_distribution(data, "normal")
gof <- gof_tests(fit)
ci <- bootstrap_ci(fit, n_bootstrap = 1000)
diag <- diagnostics(fit)
plot(diag)
```

### Pattern 3: Model Comparison

```r
candidates <- c("normal", "gamma", "weibull")
fits <- lapply(candidates, function(d) fit_distribution(data, d))
aics <- sapply(fits, function(f) f$aic)
best <- fits[[which.min(aics)]]
```

### Pattern 4: Multilingual Report

```r
for (lang in c("en", "fa", "de")) {
  set_language(lang)
  cat(sprintf("\n=== Report in %s ===\n", lang))
  print(fit)
  print(gof_tests(fit))
}
set_language("en")
```

## Getting Help

```r
# Function help
?fit_distribution
?gof_tests
?bootstrap_ci
?diagnostics

# Package overview
help(package = "distfitr")

# Examples
example(fit_distribution)

# Vignettes (coming soon)
vignette("distfitr-intro")
```

## More Resources

- **GitHub:** https://github.com/alisadeghiaghili/distfitr
- **Issues:** https://github.com/alisadeghiaghili/distfitr/issues
- **CHANGELOG:** See version history and new features
- **TESTING.md:** Full testing guide
- **tests/manual_test_all.R:** Comprehensive test script

---

**Ready to analyze?** Start with:
```r
library(distfitr)
data <- rnorm(100, 10, 2)
fit <- fit_distribution(data, "normal")
print(fit)
```

**Happy fitting!** 🚀
