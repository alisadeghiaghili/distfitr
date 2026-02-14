#' Fit Distribution to Data
#'
#' @description
#' Fit a probability distribution to observed data using various estimation methods.
#'
#' @param data Numeric vector of observations.
#' @param dist Character or distfitr_distribution object. Distribution to fit.
#' @param method Character. Estimation method: "mle" (Maximum Likelihood), 
#'   "mme" (Method of Moments), or "qme" (Quantile Matching). Default is "mle".
#' @param start Named list of starting parameter values (optional, for MLE).
#' @param ... Additional arguments passed to the optimization routine.
#'
#' @return An object of class "distfitr_fit" containing:
#'   \item{data}{Original data}
#'   \item{distribution}{Distribution object}
#'   \item{method}{Estimation method used}
#'   \item{params}{Estimated parameters}
#'   \item{loglik}{Log-likelihood value}
#'   \item{aic}{Akaike Information Criterion}
#'   \item{bic}{Bayesian Information Criterion}
#'   \item{n}{Sample size}
#'   \item{convergence}{Convergence information}
#'   
#' @export
#' @examples
#' # Generate data
#' set.seed(123)
#' x <- rnorm(100, mean = 5, sd = 2)
#' 
#' # Fit normal distribution
#' fit <- fit_distribution(x, "normal")
#' print(fit)
#' summary(fit)
#' 
#' # Fit using method of moments
#' fit_mme <- fit_distribution(x, "normal", method = "mme")
fit_distribution <- function(data, dist, method = "mle", start = NULL, ...) {
  
  # Input validation
  if (!is.numeric(data)) {
    stop("data must be numeric")
  }
  
  data <- as.numeric(data[!is.na(data)])
  n <- length(data)
  
  if (n < 2) {
    stop("data must contain at least 2 non-missing observations")
  }
  
  # Get distribution object
  if (is.character(dist)) {
    dist_obj <- get_distribution(dist)
  } else if (inherits(dist, "distfitr_distribution")) {
    dist_obj <- dist
  } else {
    stop("dist must be a character string or distfitr_distribution object")
  }
  
  # Estimate parameters based on method
  method <- tolower(method)
  
  if (method == "mle") {
    params <- fit_mle(data, dist_obj, start, ...)
  } else if (method == "mme") {
    params <- fit_mme(data, dist_obj)
  } else if (method == "qme") {
    params <- fit_qme(data, dist_obj, ...)
  } else {
    stop("method must be 'mle', 'mme', or 'qme'")
  }
  
  # Calculate log-likelihood
  loglik <- sum(log(do.call(dist_obj$dfunc, c(list(x = data), as.list(params)))))
  
  # Calculate AIC and BIC
  k <- length(params)
  aic <- 2 * k - 2 * loglik
  bic <- k * log(n) - 2 * loglik
  
  # Create fit object
  fit <- list(
    data = data,
    distribution = dist_obj,
    method = method,
    params = params,
    loglik = loglik,
    aic = aic,
    bic = bic,
    n = n,
    convergence = NULL  # Will be set by specific methods
  )
  
  class(fit) <- "distfitr_fit"
  
  return(fit)
}

#' Maximum Likelihood Estimation
#' @keywords internal
fit_mle <- function(data, dist_obj, start = NULL, ...) {
  
  # Negative log-likelihood function
  neg_loglik <- function(params) {
    # Ensure parameters are within bounds
    for (i in seq_along(params)) {
      param_name <- names(params)[i]
      bounds <- dist_obj$param_bounds[[param_name]]
      if (params[i] <= bounds[1] || params[i] >= bounds[2]) {
        return(Inf)
      }
    }
    
    # Calculate negative log-likelihood
    dens <- tryCatch(
      do.call(dist_obj$dfunc, c(list(x = data), as.list(params))),
      error = function(e) rep(0, length(data))
    )
    
    if (any(dens <= 0)) {
      return(Inf)
    }
    
    return(-sum(log(dens)))
  }
  
  # Starting values
  if (is.null(start)) {
    start <- get_starting_values(data, dist_obj)
  }
  
  # Optimize
  result <- stats::optim(
    par = start,
    fn = neg_loglik,
    method = "Nelder-Mead",
    control = list(maxit = 1000),
    ...
  )
  
  if (result$convergence != 0) {
    warning("MLE optimization may not have converged")
  }
  
  params <- result$par
  names(params) <- dist_obj$param_names
  
  return(params)
}

#' Method of Moments Estimation
#' @keywords internal
fit_mme <- function(data, dist_obj) {
  
  m1 <- mean(data)
  m2 <- var(data)
  
  params <- switch(
    dist_obj$name,
    
    normal = c(mean = m1, sd = sqrt(m2)),
    
    lognormal = {
      s2 <- log(1 + m2 / m1^2)
      c(meanlog = log(m1) - s2 / 2, sdlog = sqrt(s2))
    },
    
    gamma = {
      shape <- m1^2 / m2
      rate <- m1 / m2
      c(shape = shape, rate = rate)
    },
    
    weibull = {
      # Approximation
      shape <- 1.2 / sqrt(m2 / m1^2)
      scale <- m1 / gamma(1 + 1 / shape)
      c(shape = shape, scale = scale)
    },
    
    exponential = c(rate = 1 / m1),
    
    beta = {
      alpha <- m1 * (m1 * (1 - m1) / m2 - 1)
      beta <- (1 - m1) * (m1 * (1 - m1) / m2 - 1)
      c(shape1 = alpha, shape2 = beta)
    },
    
    uniform = c(min = min(data), max = max(data)),
    
    # For others, fall back to MLE
    fit_mle(data, dist_obj)
  )
  
  return(params)
}

#' Quantile Matching Estimation
#' @keywords internal
fit_qme <- function(data, dist_obj, probs = c(0.25, 0.75), ...) {
  
  empirical_quantiles <- stats::quantile(data, probs = probs)
  
  # Optimization function
  obj_func <- function(params) {
    theoretical_quantiles <- do.call(
      dist_obj$qfunc,
      c(list(p = probs), as.list(params))
    )
    
    sum((empirical_quantiles - theoretical_quantiles)^2)
  }
  
  # Starting values
  start <- get_starting_values(data, dist_obj)
  
  # Optimize
  result <- stats::optim(
    par = start,
    fn = obj_func,
    method = "Nelder-Mead",
    control = list(maxit = 1000),
    ...
  )
  
  params <- result$par
  names(params) <- dist_obj$param_names
  
  return(params)
}

#' Get Starting Values for Optimization
#' @keywords internal
get_starting_values <- function(data, dist_obj) {
  
  m1 <- mean(data)
  m2 <- var(data)
  
  start <- switch(
    dist_obj$name,
    normal = c(m1, sqrt(m2)),
    lognormal = c(log(m1), 0.5),
    gamma = c(2, 2 / m1),
    weibull = c(1.5, m1),
    exponential = c(1 / m1),
    beta = c(1, 1),
    uniform = c(min(data), max(data)),
    studentt = c(5, 0),
    pareto = c(min(data), 2),
    gumbel = c(m1, sqrt(m2) * sqrt(6) / pi),
    rep(1, length(dist_obj$param_names))
  )
  
  names(start) <- dist_obj$param_names
  return(start)
}

#' Print Fitted Distribution
#' @param x A distfitr_fit object
#' @param ... Additional arguments (unused)
#' @export
print.distfitr_fit <- function(x, ...) {
  cat(sprintf("Distribution: %s\n", x$distribution$display_name))
  cat(sprintf("Method: %s\n", toupper(x$method)))
  cat(sprintf("Sample size: %d\n\n", x$n))
  
  cat("Estimated Parameters:\n")
  for (i in seq_along(x$params)) {
    cat(sprintf("  %s: %.4f\n", names(x$params)[i], x$params[i]))
  }
  
  cat(sprintf("\nLog-likelihood: %.2f\n", x$loglik))
  cat(sprintf("AIC: %.2f\n", x$aic))
  cat(sprintf("BIC: %.2f\n", x$bic))
  
  invisible(x)
}

#' Summary of Fitted Distribution
#' @param object A distfitr_fit object
#' @param ... Additional arguments (unused)
#' @export
summary.distfitr_fit <- function(object, ...) {
  print(object)
  invisible(object)
}
