#' Utility Functions for distfitr
#' 
#' @description
#' Internal utility functions for data validation, transformation, and helpers.
#' 
#' @name utils
#' @keywords internal
NULL

#' Validate Numeric Data
#' 
#' @param x Numeric vector to validate
#' @param name Variable name for error messages
#' @param allow_na Logical, allow NA values?
#' @param allow_inf Logical, allow infinite values?
#' @param min_length Minimum required length
#' @keywords internal
validate_data <- function(x, name = "data", allow_na = FALSE, 
                         allow_inf = FALSE, min_length = 1) {
  
  if (!is.numeric(x)) {
    stop(sprintf("%s must be numeric", name))
  }
  
  if (!allow_na && any(is.na(x))) {
    stop(sprintf("%s contains NA values", name))
  }
  
  if (!allow_inf && any(is.infinite(x))) {
    stop(sprintf("%s contains infinite values", name))
  }
  
  x_clean <- x[!is.na(x)]
  
  if (length(x_clean) < min_length) {
    stop(sprintf("%s must have at least %d non-missing values", 
                 name, min_length))
  }
  
  return(TRUE)
}

#' Calculate Summary Statistics
#' 
#' @param x Numeric vector
#' @return Named vector of statistics
#' @keywords internal
calculate_stats <- function(x) {
  x <- x[!is.na(x)]
  
  stats <- c(
    n = length(x),
    mean = mean(x),
    sd = sd(x),
    min = min(x),
    q25 = quantile(x, 0.25),
    median = median(x),
    q75 = quantile(x, 0.75),
    max = max(x),
    skewness = calculate_skewness(x),
    kurtosis = calculate_kurtosis(x)
  )
  
  return(stats)
}

#' Calculate Skewness
#' @param x Numeric vector
#' @keywords internal
calculate_skewness <- function(x) {
  n <- length(x)
  m <- mean(x)
  s <- sd(x)
  
  skew <- (sum((x - m)^3) / n) / s^3
  
  return(skew)
}

#' Calculate Excess Kurtosis
#' @param x Numeric vector
#' @keywords internal
calculate_kurtosis <- function(x) {
  n <- length(x)
  m <- mean(x)
  s <- sd(x)
  
  kurt <- (sum((x - m)^4) / n) / s^4 - 3
  
  return(kurt)
}

#' Format P-value
#' @param p Numeric p-value
#' @keywords internal
format_pval <- function(p) {
  if (p < 0.001) {
    return("< 0.001")
  } else if (p < 0.01) {
    return(sprintf("= %.3f", p))
  } else {
    return(sprintf("= %.2f", p))
  }
}

#' Safe Division
#' @param x Numerator
#' @param y Denominator
#' @keywords internal
safe_divide <- function(x, y) {
  result <- ifelse(y == 0, NA_real_, x / y)
  return(result)
}
