#' distfitr: Advanced Distribution Fitting with Enhanced Diagnostics
#'
#' @description
#' A comprehensive R package for statistical distribution fitting that goes beyond
#' basic parameter estimation. distfitr provides advanced goodness-of-fit tests,
#' comprehensive diagnostics, bootstrap confidence intervals, and powerful outlier
#' detection - all with human-readable outputs.
#'
#' @details
#' ## Key Features
#'
#' ### Distributions (10 in Phase 1)
#' - Normal (Gaussian)
#' - Log-Normal  
#' - Gamma
#' - Weibull
#' - Exponential
#' - Beta
#' - Uniform
#' - Student's t
#' - Pareto
#' - Gumbel
#'
#' ### Estimation Methods (3)
#' - Maximum Likelihood Estimation (MLE)
#' - Method of Moments (MME)
#' - Quantile Matching Estimation (QME)
#'
#' ### Goodness-of-Fit Tests (4)
#' - Kolmogorov-Smirnov
#' - Anderson-Darling (enhanced tail sensitivity)
#' - Chi-Square (with automatic binning)
#' - Cramér-von Mises
#'
#' ### Bootstrap Methods (3)
#' - Parametric Bootstrap
#' - Non-parametric Bootstrap
#' - BCa (Bias-Corrected and Accelerated)
#'
#' ### Diagnostics
#' - 4 residual types (quantile, Pearson, deviance, standardized)
#' - Influence diagnostics (Cook's distance, leverage, DFFITS)
#' - 4 outlier detection methods
#' - Q-Q and P-P plots
#'
#' ## Basic Workflow
#'
#' 1. **Fit** a distribution to your data:
#'    \preformatted{
#'    fit <- fit_distribution(data, "normal", method = "mle")
#'    }
#'
#' 2. **Test** the goodness-of-fit:
#'    \preformatted{
#'    gof <- gof_tests(fit)
#'    }
#'
#' 3. **Quantify uncertainty** with bootstrap:
#'    \preformatted{
#'    boot_ci <- bootstrap_ci(fit, n_bootstrap = 1000, parallel = TRUE)
#'    }
#'
#' 4. **Diagnose** potential issues:
#'    \preformatted{
#'    diag <- diagnostics(fit)
#'    plot(diag)
#'    }
#'
#' ## Why distfitr?
#'
#' **Enhanced companion to fitdistrplus**:
#' - Built-in comprehensive GOF tests (fitdistrplus has visualization only)
#' - Advanced diagnostics with multiple residual types
#' - Sophisticated outlier detection (4 methods + consensus)
#' - BCa bootstrap for more accurate confidence intervals
#' - Parallel processing for faster computation
#' - Human-readable, self-documenting outputs
#'
#' ## Package Philosophy
#'
#' distfitr is designed with three principles:
#'
#' 1. **Human-First**: Every output should be immediately understandable
#' 2. **Production-Ready**: Robust error handling and validation
#' 3. **Enhanced, Not Replacement**: Complements existing tools like fitdistrplus
#'
#' @section Main Functions:
#'
#' **Core Fitting**:
#' \itemize{
#'   \item \code{\link{fit_distribution}} - Fit a distribution to data
#'   \item \code{\link{get_distribution}} - Get distribution object
#'   \item \code{\link{list_distributions}} - List available distributions
#' }
#'
#' **Goodness-of-Fit**:
#' \itemize{
#'   \item \code{\link{gof_tests}} - Run all GOF tests
#'   \item \code{\link{ks_test}} - Kolmogorov-Smirnov test
#'   \item \code{\link{ad_test}} - Anderson-Darling test
#'   \item \code{\link{chi_square_test}} - Chi-Square test
#'   \item \code{\link{cvm_test}} - Cramér-von Mises test
#' }
#'
#' **Bootstrap**:
#' \itemize{
#'   \item \code{\link{bootstrap_ci}} - Bootstrap confidence intervals
#' }
#'
#' **Diagnostics**:
#' \itemize{
#'   \item \code{\link{diagnostics}} - Comprehensive diagnostics
#'   \item \code{\link{calculate_residuals}} - Calculate residuals
#'   \item \code{\link{calculate_influence}} - Influence diagnostics
#'   \item \code{\link{detect_outliers}} - Outlier detection
#' }
#'
#' @section Example:
#' \preformatted{
#' # Load package
#' library(distfitr)
#' 
#' # Generate sample data
#' set.seed(42)
#' data <- rnorm(200, mean = 10, sd = 2)
#' 
#' # Fit distribution
#' fit <- fit_distribution(data, "normal", method = "mle")
#' print(fit)
#' 
#' # Test goodness-of-fit
#' gof <- gof_tests(fit)
#' print(gof)
#' 
#' # Bootstrap confidence intervals
#' boot_ci <- bootstrap_ci(fit, n_bootstrap = 500)
#' print(boot_ci)
#' 
#' # Diagnostics
#' diag <- diagnostics(fit)
#' plot(diag)
#' }
#'
#' @section Package Status:
#' **Version 1.1.0** - Feature release with S3 method support
#'
#' This release adds standard R S3 methods for seamless integration with
#' the R statistical ecosystem. Future versions will add:
#' - More distributions (Phase 2)
#' - Weighted data support (Phase 2)
#' - Censored data (Phase 3)
#'
#' @section Getting Help:
#' - GitHub Issues: \url{https://github.com/alisadeghiaghili/distfitr/issues}
#' - Examples: See vignettes and function examples
#' - Documentation: Type \code{?distfitr} or \code{help(package="distfitr")}
#'
#' @section Author:
#' Ali Sadeghi Aghili
#'
#' Contact:
#' - GitHub: \url{https://github.com/alisadeghiaghili}
#' - Web: \url{https://linktr.ee/aliaghili}
#'
#' @section License:
#' MIT License - Free for commercial and personal use
#'
#' @keywords internal
"_PACKAGE"

#' @importFrom stats dnorm pnorm qnorm rnorm
#' @importFrom stats dlnorm plnorm qlnorm rlnorm  
#' @importFrom stats dgamma pgamma qgamma rgamma
#' @importFrom stats dweibull pweibull qweibull rweibull
#' @importFrom stats dexp pexp qexp rexp
#' @importFrom stats dbeta pbeta qbeta rbeta
#' @importFrom stats dt pt qt rt
#' @importFrom stats dunif punif qunif runif
#' @importFrom stats ks.test chisq.test pchisq
#' @importFrom stats optim optimize quantile median sd var
#' @importFrom graphics plot hist lines points abline par curve
#' @importFrom grDevices dev.off
#' @importFrom boot boot boot.ci
#' @importFrom parallel detectCores mclapply makeCluster stopCluster clusterExport parLapply
NULL

# Package startup message
.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    sprintf(
      "distfitr v%s loaded. Use set_language() to change output language.",
      utils::packageVersion("distfitr")
    )
  )
}
