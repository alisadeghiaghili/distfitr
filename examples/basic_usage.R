# Basic Usage Examples for distfitr
# ==================================

# Load package
library(distfitr)

# Set seed for reproducibility
set.seed(42)

# ============================================
# Example 1: Basic Fitting
# ============================================

cat("\n=== Example 1: Basic Distribution Fitting ===\n\n")

# Generate sample data from normal distribution
data_normal <- rnorm(200, mean = 10, sd = 2.5)

# Fit normal distribution
fit_normal <- fit_distribution(data_normal, "normal", method = "mle")

# View results
print(fit_normal)
summary(fit_normal)

# ============================================
# Example 2: Goodness-of-Fit Tests
# ============================================

cat("\n=== Example 2: Goodness-of-Fit Tests ===\n\n")

# Run all GOF tests
gof_results <- gof_tests(fit_normal)
print(gof_results)

# Individual tests
cat("\nKolmogorov-Smirnov Test:\n")
print(ks_test(fit_normal))

cat("\nAnderson-Darling Test:\n")
print(ad_test(fit_normal))

# ============================================
# Example 3: Bootstrap Confidence Intervals
# ============================================

cat("\n=== Example 3: Bootstrap Confidence Intervals ===\n\n")

# Parametric bootstrap (fast)
cat("Running parametric bootstrap (500 samples)...\n")
boot_param <- bootstrap_ci(
  fit_normal, 
  method = "parametric", 
  n_bootstrap = 500,
  conf_level = 0.95
)
print(boot_param)

# With parallel processing (much faster for large n_bootstrap)
if (parallel::detectCores() > 1) {
  cat("\nRunning parallel bootstrap (1000 samples)...\n")
  boot_parallel <- bootstrap_ci(
    fit_normal,
    method = "parametric",
    n_bootstrap = 1000,
    parallel = TRUE,
    n_cores = -1  # Use all available cores
  )
  print(boot_parallel)
}

# ============================================
# Example 4: Diagnostics
# ============================================

cat("\n=== Example 4: Comprehensive Diagnostics ===\n\n")

# Run diagnostics
diag_results <- diagnostics(fit_normal, residual_type = "quantile")
print(diag_results)

# Plot diagnostics
par(ask = FALSE)  # Don't ask for confirmation
plot(diag_results)

# Outlier detection
cat("\nOutlier Detection:\n")
outliers_all <- detect_outliers(fit_normal, method = "all")

cat(sprintf("Z-Score method: %d outliers\n", 
            outliers_all$zscore$n_outliers))
cat(sprintf("IQR method: %d outliers\n", 
            outliers_all$iqr$n_outliers))
cat(sprintf("Likelihood method: %d outliers\n", 
            outliers_all$likelihood$n_outliers))
cat(sprintf("Consensus: %d outliers\n", 
            outliers_all$consensus$n_outliers))

# ============================================
# Example 5: Comparing Distributions
# ============================================

cat("\n=== Example 5: Model Selection ===\n\n")

# Generate data from gamma distribution
data_gamma <- rgamma(150, shape = 2, rate = 0.5)

# Try multiple distributions
distributions <- c("normal", "lognormal", "gamma", "weibull")
results <- list()

for (dist_name in distributions) {
  fit <- fit_distribution(data_gamma, dist_name)
  results[[dist_name]] <- list(
    aic = fit$aic,
    bic = fit$bic,
    loglik = fit$loglik
  )
}

# Compare AICs
aic_values <- sapply(results, function(x) x$aic)
best_dist <- names(which.min(aic_values))

cat("AIC Values:\n")
for (dist_name in names(aic_values)) {
  cat(sprintf("  %s: %.2f%s\n", 
              dist_name, 
              aic_values[dist_name],
              ifelse(dist_name == best_dist, " (BEST)", "")))
}

cat(sprintf("\nBest distribution: %s\n", best_dist))

# ============================================
# Example 6: Different Fitting Methods
# ============================================

cat("\n=== Example 6: Comparing Fitting Methods ===\n\n")

data_test <- rnorm(100, mean = 5, sd = 1.5)

# MLE
fit_mle <- fit_distribution(data_test, "normal", method = "mle")
cat("MLE Results:\n")
cat(sprintf("  mean = %.4f, sd = %.4f\n", 
            fit_mle$params["mean"], fit_mle$params["sd"]))

# Method of Moments
fit_mme <- fit_distribution(data_test, "normal", method = "mme")
cat("\nMME Results:\n")
cat(sprintf("  mean = %.4f, sd = %.4f\n", 
            fit_mme$params["mean"], fit_mme$params["sd"]))

# Quantile Matching
fit_qme <- fit_distribution(data_test, "normal", method = "qme")
cat("\nQME Results:\n")
cat(sprintf("  mean = %.4f, sd = %.4f\n", 
            fit_qme$params["mean"], fit_qme$params["sd"]))

# ============================================
# Example 7: Different Residual Types
# ============================================

cat("\n=== Example 7: Residual Analysis ===\n\n")

fit_for_resid <- fit_distribution(data_normal, "normal")

residual_types <- c("quantile", "pearson", "deviance", "standardized")

for (rtype in residual_types) {
  resid <- calculate_residuals(fit_for_resid, type = rtype)
  cat(sprintf("%s residuals: mean = %.4f, sd = %.4f\n",
              tools::toTitleCase(rtype),
              mean(resid),
              sd(resid)))
}

# ============================================
# Example 8: Working with Other Distributions
# ============================================

cat("\n=== Example 8: Other Distributions ===\n\n")

# Weibull (reliability analysis)
data_weibull <- rweibull(100, shape = 2, scale = 10)
fit_weibull <- fit_distribution(data_weibull, "weibull")
cat("Weibull fit:\n")
print(fit_weibull)

# Beta (bounded [0,1] data)
data_beta <- rbeta(100, shape1 = 2, shape2 = 5)
fit_beta <- fit_distribution(data_beta, "beta")
cat("\nBeta fit:\n")
print(fit_beta)

# Pareto (heavy-tailed)
data_pareto <- get_distribution("pareto")$rfunc(100, scale = 1, shape = 2)
fit_pareto <- fit_distribution(data_pareto, "pareto")
cat("\nPareto fit:\n")
print(fit_pareto)

cat("\n=== Examples Completed Successfully! ===\n")
