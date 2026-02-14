# Helper functions for testing

# Suppress messages during tests
quiet <- function(x) {
  suppressMessages(suppressWarnings(x))
}

# Check if value is approximately equal
approx_equal <- function(x, y, tolerance = 1e-6) {
  abs(x - y) < tolerance
}

# Generate test data for specific distribution
generate_test_data <- function(dist_name, n = 100, seed = 42) {
  set.seed(seed)
  
  if (dist_name == "normal") {
    return(rnorm(n, mean = 5, sd = 2))
  } else if (dist_name == "lognormal") {
    return(rlnorm(n, meanlog = 1, sdlog = 0.5))
  } else if (dist_name == "gamma") {
    return(rgamma(n, shape = 2, rate = 1))
  } else if (dist_name == "weibull") {
    return(rweibull(n, shape = 2, scale = 1))
  } else if (dist_name == "exponential") {
    return(rexp(n, rate = 1))
  } else if (dist_name == "beta") {
    return(rbeta(n, shape1 = 2, shape2 = 5))
  } else if (dist_name == "uniform") {
    return(runif(n, min = 0, max = 10))
  } else if (dist_name == "studentt") {
    return(rt(n, df = 5))
  } else {
    stop("Unknown distribution for test data generation")
  }
}

# Check if CI is valid (lower < estimate < upper)
is_valid_ci <- function(ci) {
  ci["lower"] <= ci["estimate"] && ci["estimate"] <= ci["upper"]
}
