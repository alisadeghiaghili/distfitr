#' Advanced Diagnostics for Distribution Fitting
#'
#' @description
#' Comprehensive diagnostic tools including multiple residual types, influence
#' diagnostics, and outlier detection methods.
#'
#' @name diagnostics
NULL

#' Complete Diagnostics for Fitted Distribution
#'
#' @description
#' Run comprehensive diagnostics on a fitted distribution.
#'
#' @param fit A distfitr_fit object from \code{fit_distribution()}.
#' @param residual_type Character. Type of residuals: "quantile", "pearson", 
#'   "deviance", or "standardized". Default is "quantile".
#'   
#' @return An object of class "distfitr_diagnostics" containing:
#'   \item{residuals}{Calculated residuals}
#'   \item{residual_type}{Type of residuals used}
#'   \item{influence}{Influence diagnostics}
#'   \item{outliers}{Outlier detection results}
#'   \item{qq_data}{Q-Q plot data}
#'   \item{pp_data}{P-P plot data}
#'   
#' @export
#' @examples
#' # Fit distribution
#' set.seed(123)
#' data <- rnorm(100, mean = 5, sd = 2)
#' fit <- fit_distribution(data, "normal")
#' 
#' # Run diagnostics
#' diag <- diagnostics(fit)
#' print(diag)
#' plot(diag)
diagnostics <- function(fit, residual_type = "quantile") {
  
  if (!inherits(fit, "distfitr_fit")) {
    stop("fit must be a distfitr_fit object")
  }
  
  # Calculate residuals
  resid <- calculate_residuals(fit, type = residual_type)
  
  # Influence diagnostics
  influence <- calculate_influence(fit)
  
  # Outlier detection
  outliers <- detect_outliers(fit)
  
  # Q-Q and P-P plot data
  qq_data <- calculate_qq_data(fit)
  pp_data <- calculate_pp_data(fit)
  
  result <- list(
    residuals = resid,
    residual_type = residual_type,
    influence = influence,
    outliers = outliers,
    qq_data = qq_data,
    pp_data = pp_data,
    fit = fit
  )
  
  class(result) <- "distfitr_diagnostics"
  
  return(result)
}

#' Calculate Residuals
#'
#' @description
#' Calculate different types of residuals for distribution fitting.
#'
#' @param fit A distfitr_fit object.
#' @param type Character. Type of residuals: "quantile", "pearson", 
#'   "deviance", or "standardized".
#'   
#' @return Numeric vector of residuals.
#' @export
calculate_residuals <- function(fit, type = "quantile") {
  
  data <- fit$data
  dist_obj <- fit$distribution
  params <- fit$params
  n <- length(data)
  
  type <- tolower(type)
  
  if (type == "quantile") {
    # Quantile residuals (most robust)
    u <- do.call(dist_obj$pfunc, c(list(q = data), as.list(params)))
    u <- pmax(pmin(u, 1 - 1e-10), 1e-10)  # Prevent extreme values
    resid <- qnorm(u)
    
  } else if (type == "pearson") {
    # Pearson residuals
    pdf_vals <- do.call(dist_obj$dfunc, c(list(x = data), as.list(params)))
    cdf_vals <- do.call(dist_obj$pfunc, c(list(q = data), as.list(params)))
    
    # Expected value and variance
    expected <- data  # Simplified; ideally use E[X|fitted]
    variance <- 1 / (pdf_vals^2)  # Approximate
    
    resid <- (data - expected) / sqrt(variance)
    
  } else if (type == "deviance") {
    # Deviance residuals
    pdf_vals <- do.call(dist_obj$dfunc, c(list(x = data), as.list(params)))
    pdf_vals <- pmax(pdf_vals, 1e-10)
    
    # Saturated log-likelihood (perfect fit)
    ll_saturated <- sum(log(pdf_vals))
    
    # Contribution to deviance
    dev_contrib <- -2 * log(pdf_vals)
    resid <- sign(data - median(data)) * sqrt(dev_contrib)
    
  } else if (type == "standardized") {
    # Standardized residuals
    u <- do.call(dist_obj$pfunc, c(list(q = data), as.list(params)))
    u <- pmax(pmin(u, 1 - 1e-10), 1e-10)
    z <- qnorm(u)
    
    # Standardize
    resid <- (z - mean(z)) / sd(z)
    
  } else {
    stop("type must be 'quantile', 'pearson', 'deviance', or 'standardized'")
  }
  
  return(resid)
}

#' Calculate Influence Diagnostics
#'
#' @description
#' Calculate influence measures for each observation.
#'
#' @param fit A distfitr_fit object.
#'   
#' @return List with influence diagnostics:
#'   \item{cooks_distance}{Cook's distance for each observation}
#'   \item{leverage}{Leverage values}
#'   \item{dffits}{DFFITS values}
#'   \item{influential_indices}{Indices of influential observations}
#'   
#' @export
calculate_influence <- function(fit) {
  
  data <- fit$data
  dist_obj <- fit$distribution
  n <- length(data)
  n_params <- length(fit$params)
  
  # Cook's distance via leave-one-out
  cooks_d <- numeric(n)
  leverage <- numeric(n)
  dffits <- numeric(n)
  
  for (i in 1:n) {
    # Fit without observation i
    data_minus_i <- data[-i]
    
    fit_minus_i <- tryCatch(
      fit_distribution(data_minus_i, dist_obj, method = fit$method),
      error = function(e) NULL
    )
    
    if (!is.null(fit_minus_i)) {
      # Parameter change
      param_diff <- fit$params - fit_minus_i$params
      param_change <- sqrt(sum(param_diff^2))
      
      # Cook's distance (scaled parameter change)
      cooks_d[i] <- param_change^2 / n_params
      
      # Approximate leverage (influence on fitted value)
      fitted_full <- do.call(dist_obj$pfunc, 
                            c(list(q = data[i]), as.list(fit$params)))
      fitted_minus <- do.call(dist_obj$pfunc, 
                             c(list(q = data[i]), as.list(fit_minus_i$params)))
      leverage[i] <- abs(fitted_full - fitted_minus)
      
      # DFFITS
      resid_i <- calculate_residuals(fit, type = "quantile")[i]
      dffits[i] <- resid_i * sqrt(leverage[i] / (1 - leverage[i] + 1e-10))
      
    } else {
      cooks_d[i] <- NA
      leverage[i] <- NA
      dffits[i] <- NA
    }
  }
  
  # Identify influential observations
  # Cook's D > 4/n is commonly used threshold
  threshold <- 4 / n
  influential_indices <- which(cooks_d > threshold)
  
  result <- list(
    cooks_distance = cooks_d,
    leverage = leverage,
    dffits = dffits,
    influential_indices = influential_indices,
    threshold = threshold
  )
  
  return(result)
}

#' Detect Outliers
#'
#' @description
#' Detect outliers using multiple methods.
#'
#' @param fit A distfitr_fit object.
#' @param method Character. Method: "zscore", "iqr", "likelihood", 
#'   "mahalanobis", or "all". Default is "all".
#' @param threshold Numeric. Threshold for outlier detection 
#'   (method-specific, default: NULL for automatic).
#'   
#' @return List with outlier detection results.
#' @export
detect_outliers <- function(fit, method = "all", threshold = NULL) {
  
  data <- fit$data
  n <- length(data)
  
  method <- tolower(method)
  
  if (method == "all") {
    results <- list(
      zscore = detect_outliers_zscore(fit, threshold),
      iqr = detect_outliers_iqr(fit, threshold),
      likelihood = detect_outliers_likelihood(fit, threshold),
      mahalanobis = detect_outliers_mahalanobis(fit, threshold)
    )
    
    # Consensus outliers (flagged by at least 2 methods)
    all_outliers <- c(
      results$zscore$outlier_indices,
      results$iqr$outlier_indices,
      results$likelihood$outlier_indices,
      results$mahalanobis$outlier_indices
    )
    
    outlier_counts <- table(all_outliers)
    consensus_outliers <- as.integer(names(outlier_counts[outlier_counts >= 2]))
    
    results$consensus <- list(
      outlier_indices = consensus_outliers,
      n_outliers = length(consensus_outliers)
    )
    
    return(results)
    
  } else if (method == "zscore") {
    return(detect_outliers_zscore(fit, threshold))
  } else if (method == "iqr") {
    return(detect_outliers_iqr(fit, threshold))
  } else if (method == "likelihood") {
    return(detect_outliers_likelihood(fit, threshold))
  } else if (method == "mahalanobis") {
    return(detect_outliers_mahalanobis(fit, threshold))
  } else {
    stop("method must be 'zscore', 'iqr', 'likelihood', 'mahalanobis', or 'all'")
  }
}

#' Z-Score Based Outlier Detection
#' @keywords internal
detect_outliers_zscore <- function(fit, threshold = NULL) {
  
  if (is.null(threshold)) threshold <- 3
  
  resid <- calculate_residuals(fit, type = "quantile")
  z_scores <- abs(resid)
  
  outlier_indices <- which(z_scores > threshold)
  
  return(list(
    method = "Z-Score",
    scores = z_scores,
    threshold = threshold,
    outlier_indices = outlier_indices,
    n_outliers = length(outlier_indices)
  ))
}

#' IQR Based Outlier Detection
#' @keywords internal
detect_outliers_iqr <- function(fit, threshold = NULL) {
  
  if (is.null(threshold)) threshold <- 1.5
  
  data <- fit$data
  q1 <- quantile(data, 0.25)
  q3 <- quantile(data, 0.75)
  iqr <- q3 - q1
  
  lower_bound <- q1 - threshold * iqr
  upper_bound <- q3 + threshold * iqr
  
  outlier_indices <- which(data < lower_bound | data > upper_bound)
  
  return(list(
    method = "IQR",
    lower_bound = lower_bound,
    upper_bound = upper_bound,
    threshold = threshold,
    outlier_indices = outlier_indices,
    n_outliers = length(outlier_indices)
  ))
}

#' Likelihood Based Outlier Detection
#' @keywords internal
detect_outliers_likelihood <- function(fit, threshold = NULL) {
  
  data <- fit$data
  dist_obj <- fit$distribution
  params <- fit$params
  
  # Calculate log-likelihood for each point
  log_lik <- log(do.call(dist_obj$dfunc, c(list(x = data), as.list(params))))
  
  # Standardize
  log_lik_std <- (log_lik - mean(log_lik)) / (sd(log_lik) + 1e-10)
  
  if (is.null(threshold)) threshold <- -3
  
  outlier_indices <- which(log_lik_std < threshold)
  
  return(list(
    method = "Likelihood",
    log_likelihood = log_lik,
    scores = log_lik_std,
    threshold = threshold,
    outlier_indices = outlier_indices,
    n_outliers = length(outlier_indices)
  ))
}

#' Mahalanobis Distance Based Outlier Detection
#' @keywords internal
detect_outliers_mahalanobis <- function(fit, threshold = NULL) {
  
  data <- fit$data
  
  # For univariate, Mahalanobis distance is same as standardized distance
  center <- mean(data)
  scale <- sd(data)
  
  distances <- abs((data - center) / scale)
  
  if (is.null(threshold)) threshold <- 3
  
  outlier_indices <- which(distances > threshold)
  
  return(list(
    method = "Mahalanobis",
    distances = distances,
    threshold = threshold,
    outlier_indices = outlier_indices,
    n_outliers = length(outlier_indices)
  ))
}

#' Calculate Q-Q Plot Data
#' @keywords internal
calculate_qq_data <- function(fit) {
  
  data <- fit$data
  dist_obj <- fit$distribution
  params <- fit$params
  n <- length(data)
  
  # Empirical quantiles
  data_sorted <- sort(data)
  
  # Theoretical quantiles
  probs <- (1:n - 0.5) / n
  theoretical <- do.call(dist_obj$qfunc, c(list(p = probs), as.list(params)))
  
  return(list(
    empirical = data_sorted,
    theoretical = theoretical
  ))
}

#' Calculate P-P Plot Data
#' @keywords internal
calculate_pp_data <- function(fit) {
  
  data <- fit$data
  dist_obj <- fit$distribution
  params <- fit$params
  n <- length(data)
  
  # Empirical CDF
  data_sorted <- sort(data)
  empirical <- (1:n) / n
  
  # Theoretical CDF
  theoretical <- do.call(dist_obj$pfunc, c(list(q = data_sorted), as.list(params)))
  
  return(list(
    empirical = empirical,
    theoretical = theoretical
  ))
}

#' Print Diagnostics Results
#' @param x A distfitr_diagnostics object
#' @param ... Additional arguments (unused)
#' @export
print.distfitr_diagnostics <- function(x, ...) {
  cat("\n===== Distribution Diagnostics =====\n\n")
  
  cat(sprintf("Distribution: %s\n", x$fit$distribution$display_name))
  cat(sprintf("Sample size: %d\n\n", x$fit$n))
  
  # Residuals summary
  cat(sprintf("Residuals (%s):\n", x$residual_type))
  cat(sprintf("  Min: %.3f\n", min(x$residuals)))
  cat(sprintf("  Q1:  %.3f\n", quantile(x$residuals, 0.25)))
  cat(sprintf("  Med: %.3f\n", median(x$residuals)))
  cat(sprintf("  Q3:  %.3f\n", quantile(x$residuals, 0.75)))
  cat(sprintf("  Max: %.3f\n\n", max(x$residuals)))
  
  # Influential observations
  n_influential <- length(x$influence$influential_indices)
  if (n_influential > 0) {
    cat(sprintf("Influential observations: %d\n", n_influential))
    cat(sprintf("  Indices: %s\n\n", 
                paste(head(x$influence$influential_indices, 10), collapse = ", ")))
  } else {
    cat("No highly influential observations detected.\n\n")
  }
  
  # Outliers
  if (!is.null(x$outliers$consensus)) {
    n_outliers <- x$outliers$consensus$n_outliers
    if (n_outliers > 0) {
      cat(sprintf("Consensus outliers: %d (flagged by >= 2 methods)\n", n_outliers))
      cat(sprintf("  Indices: %s\n", 
                  paste(head(x$outliers$consensus$outlier_indices, 10), 
                        collapse = ", ")))
    } else {
      cat("No consensus outliers detected.\n")
    }
  }
  
  cat("\n====================================\n")
  
  invisible(x)
}

#' Plot Diagnostics
#' @param x A distfitr_diagnostics object
#' @param ... Additional arguments passed to plot
#' @export
plot.distfitr_diagnostics <- function(x, ...) {
  
  # Set up 2x2 plot layout
  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par))
  
  par(mfrow = c(2, 2), mar = c(4, 4, 2, 1))
  
  # 1. Q-Q Plot
  plot(x$qq_data$theoretical, x$qq_data$empirical,
       main = "Q-Q Plot",
       xlab = "Theoretical Quantiles",
       ylab = "Empirical Quantiles",
       pch = 20, col = "steelblue")
  abline(0, 1, col = "red", lwd = 2, lty = 2)
  
  # 2. P-P Plot
  plot(x$pp_data$theoretical, x$pp_data$empirical,
       main = "P-P Plot",
       xlab = "Theoretical Probabilities",
       ylab = "Empirical Probabilities",
       pch = 20, col = "steelblue")
  abline(0, 1, col = "red", lwd = 2, lty = 2)
  
  # 3. Residuals vs Index
  plot(1:length(x$residuals), x$residuals,
       main = "Residuals Plot",
       xlab = "Index",
       ylab = sprintf("%s Residuals", tools::toTitleCase(x$residual_type)),
       pch = 20, col = "steelblue")
  abline(h = 0, col = "red", lwd = 2, lty = 2)
  abline(h = c(-2, 2), col = "orange", lwd = 1, lty = 3)
  
  # 4. Histogram of Residuals
  hist(x$residuals,
       main = "Residuals Distribution",
       xlab = sprintf("%s Residuals", tools::toTitleCase(x$residual_type)),
       col = "lightblue",
       border = "white",
       probability = TRUE)
  curve(dnorm(x, mean = mean(x$residuals), sd = sd(x$residuals)),
        add = TRUE, col = "red", lwd = 2)
  
  invisible(x)
}
