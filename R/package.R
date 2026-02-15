#' distfitr: Advanced Distribution Fitting for R
#'
#' @description
#' A comprehensive R package for statistical distribution fitting with enhanced
#' diagnostics, goodness-of-fit tests, bootstrap confidence intervals, and
#' multilingual support.
#'
#' @details
#' The distfitr package provides tools for:
#' \itemize{
#'   \item Fitting 10 probability distributions using MLE, MME, and QME methods
#'   \item Running 4 goodness-of-fit tests (KS, AD, Chi-Square, Cramer-von Mises)
#'   \item Computing bootstrap confidence intervals (parametric, non-parametric, BCa)
#'   \item Advanced diagnostics (residuals, influence measures, outlier detection)
#'   \item Full multilingual support (English, Persian/Farsi, German)
#'   \item Parallel processing for computationally intensive operations
#' }
#'
#' @section Main Functions:
#' \describe{
#'   \item{\code{\link{fit_distribution}}}{Fit a distribution to data}
#'   \item{\code{\link{gof_tests}}}{Run goodness-of-fit tests}
#'   \item{\code{\link{bootstrap_ci}}}{Compute bootstrap confidence intervals}
#'   \item{\code{\link{diagnostics}}}{Run comprehensive diagnostics}
#'   \item{\code{\link{detect_outliers}}}{Detect outliers using multiple methods}
#' }
#'
#' @section Multilingual Functions:
#' \describe{
#'   \item{\code{\link{set_language}}}{Set output language (en, fa, de)}
#'   \item{\code{\link{get_language}}}{Get current language}
#'   \item{\code{\link{list_languages}}}{List available languages}
#' }
#'
#' @section Supported Distributions:
#' \itemize{
#'   \item Normal (Gaussian)
#'   \item Log-Normal
#'   \item Gamma
#'   \item Weibull
#'   \item Exponential
#'   \item Beta
#'   \item Uniform
#'   \item Student's t
#'   \item Pareto
#'   \item Gumbel
#' }
#'
#' @examples
#' \dontrun{
#' # Basic workflow
#' library(distfitr)
#' 
#' # Generate sample data
#' set.seed(42)
#' data <- rnorm(100, mean = 10, sd = 2)
#' 
#' # Fit distribution
#' fit <- fit_distribution(data, "normal")
#' print(fit)
#' 
#' # Run GOF tests
#' gof <- gof_tests(fit)
#' print(gof)
#' 
#' # Bootstrap confidence intervals
#' ci <- bootstrap_ci(fit, n_bootstrap = 1000)
#' print(ci)
#' 
#' # Diagnostics
#' diag <- diagnostics(fit)
#' print(diag)
#' 
#' # Multilingual output
#' set_language("fa")  # Persian
#' print(fit)
#' }
#'
#' @author Ali Sadeghi Aghili \email{alisadeghiaghili@@gmail.com}
#'   (\href{https://orcid.org/0000-0002-5938-3291}{ORCID})
#'
#' @seealso
#' Useful links:
#' \itemize{
#'   \item \url{https://github.com/alisadeghiaghili/distfitr}
#'   \item Report bugs at \url{https://github.com/alisadeghiaghili/distfitr/issues}
#' }
#'
#' @keywords internal
"_PACKAGE"

# Package load hook
.onLoad <- function(libname, pkgname) {
  # Initialize i18n system
  init_i18n()
}

# Package startup message
.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    sprintf("distfitr v%s loaded. Use set_language() to change output language.",
            utils::packageVersion("distfitr"))
  )
}
