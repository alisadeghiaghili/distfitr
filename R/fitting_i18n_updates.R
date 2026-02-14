#' Updated Print Methods with i18n Support
#'
#' @description
#' These are updated print methods that use the i18n translation system.
#' They override the basic print methods from fitting.R
#'
#' @name print_i18n
NULL

#' Print Fitted Distribution with i18n
#' @param x A distfitr_fit object
#' @param ... Additional arguments (unused)
#' @export
print.distfitr_fit <- function(x, ...) {
  
  cat(get_formatted_header(tr("fitting.title", x$distribution$display_name), 1))
  
  cat(sprintf("%s: %s\n", tr("gof_tests.distribution"), 
              get_dist_name(x$distribution$name)))
  cat(sprintf("%s: %s\n", tr("common.method"), 
              tr(paste0("fitting.method_", tolower(x$method)))))
  cat(sprintf("%s: %s\n\n", tr("fitting.sample_size"), 
              locale_format(x$n, "number", 0)))
  
  cat(sprintf("%s:\n", tr("fitting.estimated_parameters")))
  for (i in seq_along(x$params)) {
    cat(sprintf("  %s: %s\n", 
                names(x$params)[i],
                locale_format(x$params[i], "number", 4)))
  }
  
  cat("\n")
  cat(sprintf("%s: %s\n", tr("fitting.log_likelihood"), 
              locale_format(x$loglik, "number", 2)))
  cat(sprintf("%s: %s\n", tr("fitting.aic"), 
              locale_format(x$aic, "number", 2)))
  cat(sprintf("%s: %s\n", tr("fitting.bic"), 
              locale_format(x$bic, "number", 2)))
  
  cat("\n" %+% strrep("=", 50) %+% "\n")
  
  invisible(x)
}

#' Print GOF Tests with i18n
#' @param x A distfitr_gof object
#' @param ... Additional arguments (unused)
#' @export
print.distfitr_gof <- function(x, ...) {
  
  cat(get_formatted_header(tr("gof_tests.title"), 1))
  
  cat(sprintf("%s: %s\n", tr("gof_tests.distribution"),
              get_dist_name(x$distribution_name)))
  cat(sprintf("%s: %s\n", tr("gof_tests.sample_size"),
              locale_format(x$n, "number", 0)))
  cat(sprintf("%s: %s\n\n", tr("gof_tests.significance_level"),
              locale_format(x$alpha, "number", 2)))
  
  cat(get_formatted_header(tr("gof_tests.test_statistics"), 2))
  cat("\n")
  
  # Print each test
  if (!is.null(x$ks)) {
    status <- ifelse(x$ks$passed, 
                    paste0("[", tr("common.passed"), "]"),
                    paste0("[", tr("common.failed"), "]"))
    cat(sprintf("%s %s:\n", status, tr("gof_tests.ks_test")))
    cat(sprintf("    %s = %s\n", tr("gof_tests.statistic"),
                locale_format(x$ks$statistic, "number", 4)))
    cat(sprintf("    %s = %s\n\n", tr("gof_tests.p_value"),
                locale_format(x$ks$p_value, "pvalue")))
  }
  
  if (!is.null(x$ad)) {
    status <- ifelse(x$ad$passed,
                    paste0("[", tr("common.passed"), "]"),
                    paste0("[", tr("common.failed"), "]"))
    cat(sprintf("%s %s:\n", status, tr("gof_tests.ad_test")))
    cat(sprintf("    %s = %s\n", tr("gof_tests.statistic"),
                locale_format(x$ad$statistic, "number", 3)))
    cat(sprintf("    %s = %s\n\n", tr("gof_tests.p_value"),
                locale_format(x$ad$p_value, "pvalue")))
  }
  
  if (!is.null(x$chisq)) {
    status <- ifelse(x$chisq$passed,
                    paste0("[", tr("common.passed"), "]"),
                    paste0("[", tr("common.failed"), "]"))
    cat(sprintf("%s %s:\n", status, tr("gof_tests.chisq_test")))
    cat(sprintf("    %s = %s\n", tr("gof_tests.statistic"),
                locale_format(x$chisq$statistic, "number", 2)))
    cat(sprintf("    %s = %s\n", tr("gof_tests.p_value"),
                locale_format(x$chisq$p_value, "pvalue")))
    cat(sprintf("    %s = %s\n\n", tr("gof_tests.df"),
                locale_format(x$chisq$df, "number", 0)))
  }
  
  if (!is.null(x$cvm)) {
    status <- ifelse(x$cvm$passed,
                    paste0("[", tr("common.passed"), "]"),
                    paste0("[", tr("common.failed"), "]"))
    cat(sprintf("%s %s:\n", status, tr("gof_tests.cvm_test")))
    cat(sprintf("    %s = %s\n", tr("gof_tests.statistic"),
                locale_format(x$cvm$statistic, "number", 3)))
    cat(sprintf("    %s = %s\n\n", tr("gof_tests.p_value"),
                locale_format(x$cvm$p_value, "pvalue")))
  }
  
  # Overall assessment
  cat(get_formatted_header(tr("gof_tests.overall_assessment"), 2))
  
  if (x$all_passed) {
    cat(sprintf("%s %s\n", 
                paste0("[", tr("common.passed"), "]"),
                tr("gof_tests.all_passed")))
  } else {
    n_failed <- sum(!c(x$ks$passed, x$ad$passed, x$chisq$passed, x$cvm$passed))
    cat(sprintf("%s %d %s\n",
                paste0("[", tr("common.failed"), "]"),
                n_failed,
                tr("gof_tests.some_failed")))
  }
  
  cat("\n" %+% strrep("=", 50) %+% "\n")
  
  invisible(x)
}

#' Print Bootstrap Results with i18n
#' @param x A distfitr_bootstrap object
#' @param ... Additional arguments (unused)
#' @export
print.distfitr_bootstrap <- function(x, ...) {
  
  cat(get_formatted_header(tr("bootstrap.title"), 1))
  
  method_key <- paste0("bootstrap.method_", x$method)
  cat(sprintf("%s: %s\n", tr("bootstrap.method"), tr(method_key)))
  cat(sprintf("%s: %s\n", tr("bootstrap.n_bootstrap"),
              locale_format(x$n_bootstrap, "number", 0)))
  cat(sprintf("%s: %s\n\n", tr("bootstrap.conf_level"),
              locale_format(x$conf_level, "percent", 1)))
  
  cat(sprintf("%s:\n\n", tr("bootstrap.parameter_estimates")))
  
  for (param_name in names(x$ci)) {
    ci <- x$ci[[param_name]]
    cat(sprintf("  %s:\n", param_name))
    cat(sprintf("    %s: %s\n", tr("bootstrap.estimate"),
                locale_format(ci["estimate"], "number", 4)))
    cat(sprintf("    %s%%: [%s, %s]\n",
                locale_format(x$conf_level * 100, "number", 1),
                locale_format(ci["lower"], "number", 4),
                locale_format(ci["upper"], "number", 4)))
    cat("\n")
  }
  
  # Calculate success rate
  n_success <- sum(complete.cases(x$bootstrap_samples))
  success_rate <- n_success / x$n_bootstrap * 100
  
  if (success_rate < 95) {
    cat(sprintf("%s: %s\n",
                tr("common.warning"),
                tr("bootstrap.convergence_warning", success_rate)))
  }
  
  cat("\n" %+% strrep("=", 50) %+% "\n")
  
  invisible(x)
}

#' Print Diagnostics with i18n
#' @param x A distfitr_diagnostics object
#' @param ... Additional arguments (unused)
#' @export
print.distfitr_diagnostics <- function(x, ...) {
  
  cat(get_formatted_header(tr("diagnostics.title"), 1))
  
  cat(sprintf("%s: %s\n", tr("diagnostics.distribution"),
              get_dist_name(x$fit$distribution$name)))
  cat(sprintf("%s: %s\n\n", tr("diagnostics.sample_size"),
              locale_format(x$fit$n, "number", 0)))
  
  # Residuals summary
  resid_type_key <- paste0("diagnostics.residual_types.", x$residual_type)
  cat(sprintf("%s (%s):\n", tr("diagnostics.residuals"), tr(resid_type_key)))
  cat(sprintf("  %s: %s\n", tr("diagnostics.min"),
              locale_format(min(x$residuals), "number", 3)))
  cat(sprintf("  %s:  %s\n", tr("diagnostics.q1"),
              locale_format(quantile(x$residuals, 0.25), "number", 3)))
  cat(sprintf("  %s: %s\n", tr("diagnostics.median"),
              locale_format(median(x$residuals), "number", 3)))
  cat(sprintf("  %s:  %s\n", tr("diagnostics.q3"),
              locale_format(quantile(x$residuals, 0.75), "number", 3)))
  cat(sprintf("  %s: %s\n\n", tr("diagnostics.max"),
              locale_format(max(x$residuals), "number", 3)))
  
  # Influential observations
  n_influential <- length(x$influence$influential_indices)
  if (n_influential > 0) {
    cat(sprintf("%s: %s\n", tr("diagnostics.influential_obs"),
                locale_format(n_influential, "number", 0)))
    cat(sprintf("  %s: %s\n\n", tr("diagnostics.indices"),
                paste(head(x$influence$influential_indices, 10), collapse = ", ")))
  } else {
    cat(sprintf("%s\n\n", tr("diagnostics.no_influential")))
  }
  
  # Outliers
  if (!is.null(x$outliers$consensus)) {
    n_outliers <- x$outliers$consensus$n_outliers
    if (n_outliers > 0) {
      cat(sprintf("%s: %s\n", tr("diagnostics.consensus_outliers"),
                  locale_format(n_outliers, "number", 0)))
      cat(sprintf("  %s: %s\n", tr("diagnostics.indices"),
                  paste(head(x$outliers$consensus$outlier_indices, 10),
                        collapse = ", ")))
    } else {
      cat(sprintf("%s\n", tr("diagnostics.no_outliers")))
    }
  }
  
  cat("\n" %+% strrep("=", 50) %+% "\n")
  
  invisible(x)
}

# Helper: String concatenation operator
`%+%` <- function(a, b) paste0(a, b)
