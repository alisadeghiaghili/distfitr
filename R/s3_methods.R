#' Enhanced S3 Methods for distfitr_fit
#'
#' @description
#' Standard S3 methods to make distfitr_fit objects compatible with 
#' R's generic statistical functions.
#' 
#' @name s3_methods
NULL

#' Extract Fitted Parameters
#'
#' @param object A distfitr_fit object
#' @param ... Additional arguments (unused)
#' 
#' @return Named numeric vector of estimated parameters
#' 
#' @export
#' @examples
#' set.seed(123)
#' x <- rnorm(100, mean = 5, sd = 2)
#' fit <- fit_distribution(x, "normal")
#' coef(fit)
coef.distfitr_fit <- function(object, ...) {
  return(object$params)
}

#' Extract Log-Likelihood
#'
#' @param object A distfitr_fit object
#' @param ... Additional arguments (unused)
#' 
#' @return An object of class "logLik" containing the log-likelihood value
#' 
#' @export
#' @examples
#' set.seed(123)
#' x <- rnorm(100, mean = 5, sd = 2)
#' fit <- fit_distribution(x, "normal")
#' logLik(fit)
logLik.distfitr_fit <- function(object, ...) {
  val <- object$loglik
  attr(val, "df") <- length(object$params)
  attr(val, "nobs") <- object$n
  class(val) <- "logLik"
  return(val)
}

#' Extract AIC
#'
#' @param fit A distfitr_fit object
#' @param ... Additional arguments (unused)
#' @param k Numeric, the penalty per parameter (default: 2)
#' 
#' @return Numeric AIC value
#' 
#' @export
#' @examples
#' set.seed(123)
#' x <- rnorm(100, mean = 5, sd = 2)
#' fit <- fit_distribution(x, "normal")
#' AIC(fit)
AIC.distfitr_fit <- function(fit, ..., k = 2) {
  return(fit$aic)
}

#' Extract BIC
#'
#' @param object A distfitr_fit object
#' @param ... Additional arguments (unused)
#' 
#' @return Numeric BIC value
#' 
#' @export
#' @examples
#' set.seed(123)
#' x <- rnorm(100, mean = 5, sd = 2)
#' fit <- fit_distribution(x, "normal")
#' BIC(fit)
BIC.distfitr_fit <- function(object, ...) {
  return(object$bic)
}

#' Extract Number of Observations
#'
#' @param object A distfitr_fit object
#' @param ... Additional arguments (unused)
#' 
#' @return Integer sample size
#' 
#' @export
#' @examples
#' set.seed(123)
#' x <- rnorm(100, mean = 5, sd = 2)
#' fit <- fit_distribution(x, "normal")
#' nobs(fit)
nobs.distfitr_fit <- function(object, ...) {
  return(object$n)
}

#' Calculate Residuals
#'
#' @param object A distfitr_fit object
#' @param type Character. Type of residuals: "quantile" (default), "pearson", 
#'   "deviance", or "standardized"
#' @param ... Additional arguments (unused)
#' 
#' @return Numeric vector of residuals
#' 
#' @export
#' @examples
#' set.seed(123)
#' x <- rnorm(100, mean = 5, sd = 2)
#' fit <- fit_distribution(x, "normal")
#' res <- residuals(fit)
#' head(res)
residuals.distfitr_fit <- function(object, type = "quantile", ...) {
  # Use existing calculate_residuals function if available
  # Otherwise compute quantile residuals
  
  if (exists("calculate_residuals", mode = "function")) {
    result <- calculate_residuals(object)
    return(switch(type,
                  quantile = result$quantile,
                  pearson = result$pearson,
                  deviance = result$deviance,
                  standardized = result$standardized,
                  result$quantile))
  }
  
  # Fallback: compute basic quantile residuals
  data <- object$data
  params <- as.list(object$params)
  
  # Compute CDF values
  cdf_vals <- do.call(object$distribution$pfunc, c(list(q = data), params))
  
  # Convert to quantile residuals (standard normal)
  residuals <- stats::qnorm(cdf_vals)
  
  return(residuals)
}

#' Predict Method for Fitted Distribution
#'
#' @param object A distfitr_fit object
#' @param newdata Numeric vector of new observations (optional)
#' @param type Character. Type of prediction: "density" (PDF), "prob" (CDF), 
#'   or "quantile". Default is "density"
#' @param ... Additional arguments passed to distribution functions
#' 
#' @return Numeric vector of predicted values
#' 
#' @export
#' @examples
#' set.seed(123)
#' x <- rnorm(100, mean = 5, sd = 2)
#' fit <- fit_distribution(x, "normal")
#' 
#' # Predict density at new points
#' new_points <- seq(0, 10, length.out = 5)
#' predict(fit, newdata = new_points, type = "density")
#' 
#' # Predict CDF
#' predict(fit, newdata = new_points, type = "prob")
predict.distfitr_fit <- function(object, newdata = NULL, type = "density", ...) {
  
  if (is.null(newdata)) {
    newdata <- object$data
  }
  
  params <- as.list(object$params)
  
  result <- switch(type,
    density = do.call(object$distribution$dfunc, c(list(x = newdata), params)),
    prob = do.call(object$distribution$pfunc, c(list(q = newdata), params)),
    quantile = {
      if (!all(newdata >= 0 & newdata <= 1)) {
        stop("For type='quantile', newdata must be probabilities in [0,1]")
      }
      do.call(object$distribution$qfunc, c(list(p = newdata), params))
    },
    stop("type must be 'density', 'prob', or 'quantile'")
  )
  
  return(result)
}

#' Plot Method for Fitted Distribution
#'
#' @param x A distfitr_fit object
#' @param type Character. Type of plot: "density" (histogram + fitted PDF), 
#'   "qq" (Q-Q plot), "pp" (P-P plot), or "all" (all three plots)
#' @param ... Additional arguments passed to plotting functions
#' 
#' @return NULL (invisibly). Creates plots as side effect.
#' 
#' @export
#' @examples
#' \dontrun{
#' set.seed(123)
#' x <- rnorm(100, mean = 5, sd = 2)
#' fit <- fit_distribution(x, "normal")
#' 
#' # Density plot
#' plot(fit, type = "density")
#' 
#' # Q-Q plot
#' plot(fit, type = "qq")
#' 
#' # All plots
#' plot(fit, type = "all")
#' }
plot.distfitr_fit <- function(x, type = "density", ...) {
  
  if (type == "all") {
    old_par <- graphics::par(mfrow = c(2, 2))
    on.exit(graphics::par(old_par))
    
    plot_density(x, ...)
    plot_qq(x, ...)
    plot_pp(x, ...)
    plot_cdf(x, ...)
    
    return(invisible(NULL))
  }
  
  switch(type,
    density = plot_density(x, ...),
    qq = plot_qq(x, ...),
    pp = plot_pp(x, ...),
    cdf = plot_cdf(x, ...),
    stop("type must be 'density', 'qq', 'pp', 'cdf', or 'all'")
  )
  
  invisible(NULL)
}

#' Plot Histogram with Fitted Density
#' @keywords internal
plot_density <- function(fit, main = NULL, xlab = "Value", ylab = "Density", ...) {
  
  if (is.null(main)) {
    main <- sprintf("Fitted %s Distribution", fit$distribution$display_name)
  }
  
  # Histogram
  graphics::hist(fit$data, probability = TRUE, main = main, 
                xlab = xlab, ylab = ylab, col = "lightgray", 
                border = "white", ...)
  
  # Fitted density curve
  x_range <- range(fit$data)
  x_seq <- seq(x_range[1], x_range[2], length.out = 200)
  
  params <- as.list(fit$params)
  y_fitted <- do.call(fit$distribution$dfunc, c(list(x = x_seq), params))
  
  graphics::lines(x_seq, y_fitted, col = "red", lwd = 2)
  graphics::legend("topright", legend = c("Data", "Fitted"), 
                  fill = c("lightgray", NA), border = c("white", NA),
                  lty = c(NA, 1), col = c(NA, "red"), lwd = c(NA, 2))
}

#' Plot Q-Q Plot
#' @keywords internal
plot_qq <- function(fit, main = NULL, xlab = "Theoretical Quantiles", 
                   ylab = "Sample Quantiles", ...) {
  
  if (is.null(main)) {
    main <- sprintf("Q-Q Plot: %s", fit$distribution$display_name)
  }
  
  # Sort data
  data_sorted <- sort(fit$data)
  n <- length(data_sorted)
  
  # Theoretical quantiles
  probs <- (1:n - 0.5) / n
  params <- as.list(fit$params)
  theoretical <- do.call(fit$distribution$qfunc, c(list(p = probs), params))
  
  # Plot
  graphics::plot(theoretical, data_sorted, main = main, 
                xlab = xlab, ylab = ylab, pch = 16, col = "blue", ...)
  graphics::abline(0, 1, col = "red", lwd = 2, lty = 2)
}

#' Plot P-P Plot
#' @keywords internal
plot_pp <- function(fit, main = NULL, xlab = "Theoretical Probabilities", 
                   ylab = "Empirical Probabilities", ...) {
  
  if (is.null(main)) {
    main <- sprintf("P-P Plot: %s", fit$distribution$display_name)
  }
  
  # Sort data
  data_sorted <- sort(fit$data)
  n <- length(data_sorted)
  
  # Empirical probabilities
  empirical <- (1:n - 0.5) / n
  
  # Theoretical probabilities
  params <- as.list(fit$params)
  theoretical <- do.call(fit$distribution$pfunc, c(list(q = data_sorted), params))
  
  # Plot
  graphics::plot(theoretical, empirical, main = main, 
                xlab = xlab, ylab = ylab, pch = 16, col = "blue", ...)
  graphics::abline(0, 1, col = "red", lwd = 2, lty = 2)
}

#' Plot Empirical and Fitted CDF
#' @keywords internal
plot_cdf <- function(fit, main = NULL, xlab = "Value", ylab = "Cumulative Probability", ...) {
  
  if (is.null(main)) {
    main <- sprintf("CDF: %s", fit$distribution$display_name)
  }
  
  # Empirical CDF
  data_sorted <- sort(fit$data)
  n <- length(data_sorted)
  empirical_cdf <- (1:n) / n
  
  # Plot empirical
  graphics::plot(data_sorted, empirical_cdf, type = "s", main = main,
                xlab = xlab, ylab = ylab, col = "blue", lwd = 1.5, ...)
  
  # Fitted CDF
  x_range <- range(fit$data)
  x_seq <- seq(x_range[1], x_range[2], length.out = 200)
  params <- as.list(fit$params)
  fitted_cdf <- do.call(fit$distribution$pfunc, c(list(q = x_seq), params))
  
  graphics::lines(x_seq, fitted_cdf, col = "red", lwd = 2)
  graphics::legend("bottomright", legend = c("Empirical", "Fitted"),
                  lty = c(1, 1), col = c("blue", "red"), lwd = c(1.5, 2))
}

#' Variance-Covariance Matrix (Placeholder)
#'
#' @param object A distfitr_fit object
#' @param ... Additional arguments (unused)
#' 
#' @return Matrix of parameter variances/covariances (currently returns NULL with message)
#' 
#' @export
#' @examples
#' set.seed(123)
#' x <- rnorm(100, mean = 5, sd = 2)
#' fit <- fit_distribution(x, "normal")
#' # vcov(fit)  # Currently not implemented
vcov.distfitr_fit <- function(object, ...) {
  message("vcov() not yet implemented for distfitr_fit objects.")
  message("Consider using bootstrap_ci() for parameter uncertainty.")
  return(NULL)
}

#' Confidence Intervals for Parameters
#'
#' @param object A distfitr_fit object
#' @param parm Character vector of parameter names (optional)
#' @param level Numeric confidence level (default: 0.95)
#' @param method Character. Method for CI: "bootstrap" (uses bootstrap_ci if available)
#' @param ... Additional arguments passed to bootstrap_ci
#' 
#' @return Matrix of confidence intervals
#' 
#' @export
#' @examples
#' \dontrun{
#' set.seed(123)
#' x <- rnorm(100, mean = 5, sd = 2)
#' fit <- fit_distribution(x, "normal")
#' confint(fit, level = 0.95)
#' }
confint.distfitr_fit <- function(object, parm = NULL, level = 0.95, 
                                  method = "bootstrap", ...) {
  
  if (method == "bootstrap" && exists("bootstrap_ci", mode = "function")) {
    boot_result <- bootstrap_ci(object, conf_level = level, ...)
    
    # Extract confidence intervals
    param_names <- names(object$params)
    if (!is.null(parm)) {
      param_names <- intersect(param_names, parm)
    }
    
    ci_matrix <- matrix(NA, nrow = length(param_names), ncol = 2)
    rownames(ci_matrix) <- param_names
    colnames(ci_matrix) <- c(sprintf("%.1f %%", (1-level)/2 * 100),
                             sprintf("%.1f %%", (1+level)/2 * 100))
    
    for (i in seq_along(param_names)) {
      pname <- param_names[i]
      if (pname %in% names(boot_result$intervals)) {
        ci_matrix[i, ] <- boot_result$intervals[[pname]]$ci
      }
    }
    
    return(ci_matrix)
  } else {
    message("Bootstrap method not available or bootstrap_ci() not found.")
    message("Returning NULL.")
    return(NULL)
  }
}

#' Update Fitted Distribution
#'
#' @param object A distfitr_fit object
#' @param data New data (optional)
#' @param method New method (optional)
#' @param ... Additional arguments passed to fit_distribution
#' 
#' @return Updated distfitr_fit object
#' 
#' @export
#' @examples
#' set.seed(123)
#' x <- rnorm(100, mean = 5, sd = 2)
#' fit <- fit_distribution(x, "normal", method = "mle")
#' 
#' # Update with different method
#' fit_updated <- update(fit, method = "mme")
update.distfitr_fit <- function(object, data = NULL, method = NULL, ...) {
  
  if (is.null(data)) {
    data <- object$data
  }
  
  if (is.null(method)) {
    method <- object$method
  }
  
  # Refit
  new_fit <- fit_distribution(data = data, 
                             dist = object$distribution, 
                             method = method, 
                             ...)
  
  return(new_fit)
}
