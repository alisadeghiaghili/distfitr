#' Distribution Registry and Management
#'
#' @description
#' Core distribution definitions and utilities for the distfitr package.
#' Implements 10 essential probability distributions with consistent interface.
#'
#' @name distributions
#' @keywords internal
NULL

#' Get Distribution Object
#'
#' @description
#' Factory function to create distribution objects with standardized interface.
#'
#' @param dist Character. Distribution name. One of: "normal", "lognormal", 
#'   "gamma", "weibull", "exponential", "beta", "uniform", "studentt", 
#'   "pareto", "gumbel".
#'   
#' @return A list with class "distfitr_distribution" containing:
#'   \item{name}{Distribution name}
#'   \item{display_name}{Human-readable name}
#'   \item{param_names}{Parameter names}
#'   \item{param_bounds}{Parameter bounds (lower, upper)}
#'   \item{support}{Distribution support (lower, upper)}
#'   \item{type}{"continuous" or "discrete"}
#'   \item{dfunc}{Density/mass function}
#'   \item{pfunc}{Cumulative distribution function}
#'   \item{qfunc}{Quantile function}
#'   \item{rfunc}{Random generation function}
#'   
#' @export
#' @examples
#' # Get normal distribution
#' normal_dist <- get_distribution("normal")
#' print(normal_dist$display_name)
#' 
#' # Get gamma distribution
#' gamma_dist <- get_distribution("gamma")
#' print(gamma_dist$param_names)
get_distribution <- function(dist) {
  dist <- tolower(dist)
  
  # Distribution registry
  registry <- list(
    normal = list(
      name = "normal",
      display_name = "Normal (Gaussian)",
      param_names = c("mean", "sd"),
      param_bounds = list(
        mean = c(-Inf, Inf),
        sd = c(0, Inf)
      ),
      support = c(-Inf, Inf),
      type = "continuous",
      dfunc = stats::dnorm,
      pfunc = stats::pnorm,
      qfunc = stats::qnorm,
      rfunc = stats::rnorm
    ),
    
    lognormal = list(
      name = "lognormal",
      display_name = "Log-Normal",
      param_names = c("meanlog", "sdlog"),
      param_bounds = list(
        meanlog = c(-Inf, Inf),
        sdlog = c(0, Inf)
      ),
      support = c(0, Inf),
      type = "continuous",
      dfunc = stats::dlnorm,
      pfunc = stats::plnorm,
      qfunc = stats::qlnorm,
      rfunc = stats::rlnorm
    ),
    
    gamma = list(
      name = "gamma",
      display_name = "Gamma",
      param_names = c("shape", "rate"),
      param_bounds = list(
        shape = c(0, Inf),
        rate = c(0, Inf)
      ),
      support = c(0, Inf),
      type = "continuous",
      dfunc = stats::dgamma,
      pfunc = stats::pgamma,
      qfunc = stats::qgamma,
      rfunc = stats::rgamma
    ),
    
    weibull = list(
      name = "weibull",
      display_name = "Weibull",
      param_names = c("shape", "scale"),
      param_bounds = list(
        shape = c(0, Inf),
        scale = c(0, Inf)
      ),
      support = c(0, Inf),
      type = "continuous",
      dfunc = stats::dweibull,
      pfunc = stats::pweibull,
      qfunc = stats::qweibull,
      rfunc = stats::rweibull
    ),
    
    exponential = list(
      name = "exponential",
      display_name = "Exponential",
      param_names = c("rate"),
      param_bounds = list(
        rate = c(0, Inf)
      ),
      support = c(0, Inf),
      type = "continuous",
      dfunc = stats::dexp,
      pfunc = stats::pexp,
      qfunc = stats::qexp,
      rfunc = stats::rexp
    ),
    
    beta = list(
      name = "beta",
      display_name = "Beta",
      param_names = c("shape1", "shape2"),
      param_bounds = list(
        shape1 = c(0, Inf),
        shape2 = c(0, Inf)
      ),
      support = c(0, 1),
      type = "continuous",
      dfunc = stats::dbeta,
      pfunc = stats::pbeta,
      qfunc = stats::qbeta,
      rfunc = stats::rbeta
    ),
    
    uniform = list(
      name = "uniform",
      display_name = "Uniform",
      param_names = c("min", "max"),
      param_bounds = list(
        min = c(-Inf, Inf),
        max = c(-Inf, Inf)
      ),
      support = c(NA, NA),  # Data-dependent
      type = "continuous",
      dfunc = stats::dunif,
      pfunc = stats::punif,
      qfunc = stats::qunif,
      rfunc = stats::runif
    ),
    
    studentt = list(
      name = "studentt",
      display_name = "Student's t",
      param_names = c("df", "ncp"),
      param_bounds = list(
        df = c(0, Inf),
        ncp = c(-Inf, Inf)
      ),
      support = c(-Inf, Inf),
      type = "continuous",
      dfunc = function(x, df, ncp = 0) stats::dt(x, df, ncp),
      pfunc = function(q, df, ncp = 0) stats::pt(q, df, ncp),
      qfunc = function(p, df, ncp = 0) stats::qt(p, df, ncp),
      rfunc = function(n, df, ncp = 0) stats::rt(n, df, ncp)
    ),
    
    pareto = list(
      name = "pareto",
      display_name = "Pareto",
      param_names = c("scale", "shape"),
      param_bounds = list(
        scale = c(0, Inf),
        shape = c(0, Inf)
      ),
      support = c(NA, Inf),  # scale-dependent
      type = "continuous",
      dfunc = function(x, scale, shape) {
        ifelse(x >= scale, shape * scale^shape / x^(shape + 1), 0)
      },
      pfunc = function(q, scale, shape) {
        ifelse(q >= scale, 1 - (scale / q)^shape, 0)
      },
      qfunc = function(p, scale, shape) {
        scale / (1 - p)^(1 / shape)
      },
      rfunc = function(n, scale, shape) {
        scale / runif(n)^(1 / shape)
      }
    ),
    
    gumbel = list(
      name = "gumbel",
      display_name = "Gumbel (Type I Extreme Value)",
      param_names = c("location", "scale"),
      param_bounds = list(
        location = c(-Inf, Inf),
        scale = c(0, Inf)
      ),
      support = c(-Inf, Inf),
      type = "continuous",
      dfunc = function(x, location, scale) {
        z <- (x - location) / scale
        (1 / scale) * exp(-(z + exp(-z)))
      },
      pfunc = function(q, location, scale) {
        z <- (q - location) / scale
        exp(-exp(-z))
      },
      qfunc = function(p, location, scale) {
        location - scale * log(-log(p))
      },
      rfunc = function(n, location, scale) {
        location - scale * log(-log(runif(n)))
      }
    )
  )
  
  if (!dist %in% names(registry)) {
    stop(sprintf(
      "Distribution '%s' not found. Available: %s",
      dist,
      paste(names(registry), collapse = ", ")
    ))
  }
  
  dist_obj <- registry[[dist]]
  class(dist_obj) <- "distfitr_distribution"
  
  return(dist_obj)
}

#' List Available Distributions
#'
#' @description
#' Get a list of all available distributions in distfitr.
#'
#' @param type Character. Filter by type: "all" (default), "continuous", 
#'   or "discrete".
#'   
#' @return Character vector of distribution names.
#' 
#' @export
#' @examples
#' # All distributions
#' list_distributions()
#' 
#' # Only continuous
#' list_distributions("continuous")
list_distributions <- function(type = "all") {
  all_dists <- c(
    "normal", "lognormal", "gamma", "weibull", "exponential",
    "beta", "uniform", "studentt", "pareto", "gumbel"
  )
  
  if (type == "all") {
    return(all_dists)
  }
  
  # For now all are continuous (discrete coming in Phase 2)
  if (type == "continuous") {
    return(all_dists)
  } else if (type == "discrete") {
    return(character(0))
  } else {
    stop("type must be 'all', 'continuous', or 'discrete'")
  }
}

#' Print Distribution Object
#' 
#' @param x A distfitr_distribution object
#' @param ... Additional arguments (unused)
#' @export
print.distfitr_distribution <- function(x, ...) {
  cat(sprintf("Distribution: %s\n", x$display_name))
  cat(sprintf("Type: %s\n", x$type))
  cat(sprintf("Parameters: %s\n", paste(x$param_names, collapse = ", ")))
  cat(sprintf("Support: [%s, %s]\n", 
              ifelse(is.na(x$support[1]), "data", x$support[1]),
              ifelse(is.na(x$support[2]), "data", x$support[2])))
  invisible(x)
}
