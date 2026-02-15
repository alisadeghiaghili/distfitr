#' Bootstrap Confidence Intervals
#'
#' @description
#' Calculate bootstrap confidence intervals for distribution parameters using
#' parametric, non-parametric, or BCa (bias-corrected and accelerated) methods.
#' Supports parallel processing for faster computation.
#'
#' @name bootstrap
NULL

#' Bootstrap Confidence Intervals for Distribution Parameters
#'
#' @description
#' Generate bootstrap confidence intervals for fitted distribution parameters.
#'
#' @param fit A distfitr_fit object from \code{fit_distribution()}.
#' @param method Character. Bootstrap method: "parametric", "nonparametric", 
#'   or "bca" (bias-corrected and accelerated). Default is "parametric".
#' @param n_bootstrap Integer. Number of bootstrap samples (default: 1000).
#' @param conf_level Numeric. Confidence level (default: 0.95).
#' @param parallel Logical. Use parallel processing? (default: FALSE)
#' @param n_cores Integer. Number of cores to use. -1 for all available cores.
#'   (default: -1)
#' @param seed Integer. Random seed for reproducibility (default: NULL).
#'   
#' @return An object of class "distfitr_bootstrap" containing:
#'   \item{params}{Original parameter estimates}
#'   \item{bootstrap_samples}{Matrix of bootstrap parameter estimates}
#'   \item{ci}{Confidence intervals for each parameter}
#'   \item{method}{Bootstrap method used}
#'   \item{n_bootstrap}{Number of bootstrap samples}
#'   \item{conf_level}{Confidence level}
#'   
#' @export
#' @examples
#' # Fit distribution
#' set.seed(123)
#' data <- rnorm(100, mean = 5, sd = 2)
#' fit <- fit_distribution(data, "normal")
#' 
#' # Parametric bootstrap
#' boot_result <- bootstrap_ci(fit, n_bootstrap = 500)
#' print(boot_result)
#' 
#' \donttest{
#' # With parallel processing (slower in examples, fast in practice)
#' boot_result_parallel <- bootstrap_ci(fit, n_bootstrap = 1000, parallel = TRUE)
#' }
bootstrap_ci <- function(fit, method = "parametric", n_bootstrap = 1000,
                        conf_level = 0.95, parallel = FALSE, 
                        n_cores = -1, seed = NULL) {
  
  if (!inherits(fit, "distfitr_fit")) {
    stop("fit must be a distfitr_fit object")
  }
  
  if (!is.null(seed)) {
    set.seed(seed)
  }
  
  method <- tolower(method)
  
  if (method == "parametric") {
    result <- bootstrap_parametric(fit, n_bootstrap, conf_level, parallel, n_cores)
  } else if (method == "nonparametric") {
    result <- bootstrap_nonparametric(fit, n_bootstrap, conf_level, parallel, n_cores)
  } else if (method == "bca") {
    result <- bootstrap_bca(fit, n_bootstrap, conf_level, parallel, n_cores)
  } else {
    stop("method must be 'parametric', 'nonparametric', or 'bca'")
  }
  
  result$method <- method
  result$n_bootstrap <- n_bootstrap
  result$conf_level <- conf_level
  
  class(result) <- "distfitr_bootstrap"
  
  return(result)
}

#' Parametric Bootstrap
#' @keywords internal
bootstrap_parametric <- function(fit, n_bootstrap, conf_level, parallel, n_cores) {
  
  data <- fit$data
  dist_obj <- fit$distribution
  params <- fit$params
  n <- length(data)
  n_params <- length(params)
  
  # Bootstrap function
  boot_func <- function(i) {
    # Generate data from fitted distribution
    boot_data <- do.call(
      dist_obj$rfunc,
      c(list(n = n), as.list(params))
    )
    
    # Fit to bootstrap data
    tryCatch({
      boot_fit <- fit_distribution(boot_data, dist_obj, method = fit$method)
      return(boot_fit$params)
    }, error = function(e) {
      return(rep(NA, n_params))
    })
  }
  
  # Run bootstrap
  if (parallel) {
    boot_samples <- run_parallel_bootstrap(boot_func, n_bootstrap, n_cores)
  } else {
    boot_samples <- run_serial_bootstrap(boot_func, n_bootstrap)
  }
  
  # Calculate confidence intervals
  ci <- calculate_bootstrap_ci(boot_samples, params, conf_level)
  
  return(list(
    params = params,
    bootstrap_samples = boot_samples,
    ci = ci
  ))
}

#' Non-parametric Bootstrap
#' @keywords internal
bootstrap_nonparametric <- function(fit, n_bootstrap, conf_level, parallel, n_cores) {
  
  data <- fit$data
  dist_obj <- fit$distribution
  params <- fit$params
  n <- length(data)
  n_params <- length(params)
  
  # Bootstrap function
  boot_func <- function(i) {
    # Resample data with replacement
    boot_data <- sample(data, size = n, replace = TRUE)
    
    # Fit to bootstrap data
    tryCatch({
      boot_fit <- fit_distribution(boot_data, dist_obj, method = fit$method)
      return(boot_fit$params)
    }, error = function(e) {
      return(rep(NA, n_params))
    })
  }
  
  # Run bootstrap
  if (parallel) {
    boot_samples <- run_parallel_bootstrap(boot_func, n_bootstrap, n_cores)
  } else {
    boot_samples <- run_serial_bootstrap(boot_func, n_bootstrap)
  }
  
  # Calculate confidence intervals
  ci <- calculate_bootstrap_ci(boot_samples, params, conf_level)
  
  return(list(
    params = params,
    bootstrap_samples = boot_samples,
    ci = ci
  ))
}

#' BCa (Bias-Corrected and Accelerated) Bootstrap
#' @keywords internal
bootstrap_bca <- function(fit, n_bootstrap, conf_level, parallel, n_cores) {
  
  # First get standard bootstrap samples
  boot_result <- bootstrap_nonparametric(fit, n_bootstrap, conf_level, parallel, n_cores)
  
  boot_samples <- boot_result$bootstrap_samples
  params <- fit$params
  data <- fit$data
  dist_obj <- fit$distribution
  n <- length(data)
  
  # Calculate BCa intervals for each parameter
  alpha <- 1 - conf_level
  
  ci_list <- list()
  
  for (i in seq_along(params)) {
    param_name <- names(params)[i]
    boot_param <- boot_samples[, i]
    boot_param <- boot_param[!is.na(boot_param)]
    
    # Bias correction factor (z0)
    n_below <- sum(boot_param < params[i])
    p_below <- n_below / length(boot_param)
    z0 <- qnorm(p_below)
    
    # Acceleration factor (a) using jackknife
    jack_estimates <- numeric(n)
    for (j in 1:n) {
      jack_data <- data[-j]
      jack_fit <- tryCatch(
        fit_distribution(jack_data, dist_obj, method = fit$method),
        error = function(e) NULL
      )
      if (!is.null(jack_fit)) {
        jack_estimates[j] <- jack_fit$params[i]
      } else {
        jack_estimates[j] <- params[i]
      }
    }
    
    jack_mean <- mean(jack_estimates)
    numerator <- sum((jack_mean - jack_estimates)^3)
    denominator <- 6 * sum((jack_mean - jack_estimates)^2)^1.5
    a <- numerator / (denominator + 1e-10)
    
    # Adjusted percentiles
    z_lower <- qnorm(alpha / 2)
    z_upper <- qnorm(1 - alpha / 2)
    
    p_lower <- pnorm(z0 + (z0 + z_lower) / (1 - a * (z0 + z_lower)))
    p_upper <- pnorm(z0 + (z0 + z_upper) / (1 - a * (z0 + z_upper)))
    
    # Ensure valid percentiles
    p_lower <- max(0.001, min(0.999, p_lower))
    p_upper <- max(0.001, min(0.999, p_upper))
    
    # Calculate CI
    ci_lower <- quantile(boot_param, probs = p_lower)
    ci_upper <- quantile(boot_param, probs = p_upper)
    
    ci_list[[param_name]] <- c(
      lower = as.numeric(ci_lower),
      estimate = params[i],
      upper = as.numeric(ci_upper)
    )
  }
  
  return(list(
    params = params,
    bootstrap_samples = boot_samples,
    ci = ci_list
  ))
}

#' Run Bootstrap in Parallel
#' @keywords internal
run_parallel_bootstrap <- function(boot_func, n_bootstrap, n_cores) {
  
  # Determine number of cores
  if (n_cores == -1) {
    n_cores <- parallel::detectCores() - 1
  }
  n_cores <- max(1, n_cores)
  
  # Run in parallel
  if (.Platform$OS.type == "windows") {
    # Windows: use parLapply
    cl <- parallel::makeCluster(n_cores)
    on.exit(parallel::stopCluster(cl))
    
    # Export necessary objects
    parallel::clusterExport(cl, varlist = ls(envir = parent.frame()), 
                          envir = parent.frame())
    
    boot_list <- parallel::parLapply(cl, 1:n_bootstrap, boot_func)
  } else {
    # Unix-like: use mclapply
    boot_list <- parallel::mclapply(1:n_bootstrap, boot_func, 
                                   mc.cores = n_cores)
  }
  
  # Convert to matrix
  boot_samples <- do.call(rbind, boot_list)
  
  return(boot_samples)
}

#' Run Bootstrap Serially
#' @keywords internal
run_serial_bootstrap <- function(boot_func, n_bootstrap) {
  
  boot_list <- lapply(1:n_bootstrap, function(i) {
    if (i %% 100 == 0) {
      message(sprintf("Bootstrap iteration %d/%d", i, n_bootstrap))
    }
    boot_func(i)
  })
  
  boot_samples <- do.call(rbind, boot_list)
  
  return(boot_samples)
}

#' Calculate Bootstrap Confidence Intervals
#' @keywords internal
calculate_bootstrap_ci <- function(boot_samples, params, conf_level) {
  
  alpha <- 1 - conf_level
  probs <- c(alpha / 2, 1 - alpha / 2)
  
  ci_list <- list()
  
  for (i in seq_along(params)) {
    param_name <- names(params)[i]
    boot_param <- boot_samples[, i]
    
    # Remove NAs
    boot_param <- boot_param[!is.na(boot_param)]
    
    if (length(boot_param) < 10) {
      warning(sprintf(
        "Too few successful bootstrap samples for %s. CI may be unreliable.",
        param_name
      ))
    }
    
    # Percentile method
    ci <- quantile(boot_param, probs = probs)
    
    ci_list[[param_name]] <- c(
      lower = as.numeric(ci[1]),
      estimate = params[i],
      upper = as.numeric(ci[2])
    )
  }
  
  return(ci_list)
}

#' Print Bootstrap Results
#' @param x A distfitr_bootstrap object
#' @param ... Additional arguments (unused)
#' @export
print.distfitr_bootstrap <- function(x, ...) {
  cat("\n===== Bootstrap Confidence Intervals =====\n\n")
  cat(sprintf("Method: %s\n", 
              switch(x$method,
                     parametric = "Parametric Bootstrap",
                     nonparametric = "Non-parametric Bootstrap",
                     bca = "BCa (Bias-Corrected and Accelerated)")))
  cat(sprintf("Bootstrap samples: %d\n", x$n_bootstrap))
  cat(sprintf("Confidence level: %.1f%%\n\n", x$conf_level * 100))
  
  cat("Parameter Estimates with Confidence Intervals:\n\n")
  
  for (param_name in names(x$ci)) {
    ci <- x$ci[[param_name]]
    cat(sprintf("  %s:\n", param_name))
    cat(sprintf("    Estimate: %.4f\n", ci["estimate"]))
    cat(sprintf("    %.1f%% CI: [%.4f, %.4f]\n",
                x$conf_level * 100, ci["lower"], ci["upper"]))
    cat("\n")
  }
  
  # Calculate success rate
  n_success <- sum(complete.cases(x$bootstrap_samples))
  success_rate <- n_success / x$n_bootstrap * 100
  
  if (success_rate < 95) {
    cat(sprintf("Warning: Only %.1f%% of bootstrap samples converged.\n",
                success_rate))
  }
  
  cat("=========================================\n")
  
  invisible(x)
}
