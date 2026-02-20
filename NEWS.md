# distfitr 1.1.0

## New features

* Added `significance_level` parameter to all goodness-of-fit test functions
  (`ks_test()`, `ad_test()`, `cvm_test()`, `chi_square_test()`, `gof_tests()`).
* Added `alpha` parameter to `gof_tests()` as a deprecated alias for
  `significance_level` (backwards compatibility).
* Added multilingual output support: English, Persian/Farsi (`fa`), German (`de`).
* Bootstrap confidence intervals now support parametric, non-parametric, and
  BCa (bias-corrected and accelerated) methods.
* Added parallel processing support in `bootstrap_ci()` via the `parallel`
  argument.

## Bug fixes

* Fixed `bootstrap_ci()` returning `NA` for the `estimate` field in confidence
  interval output. Caused by R's named vector coercion inside `c()`; fixed
  with `unname()`.
* Fixed `bootstrap_ci()` not throwing an error when `n_bootstrap` is negative
  or zero. `1:(-10)` in R produces a non-empty sequence; added explicit
  validation.

# distfitr 1.0.0

## Initial release

* Core distribution fitting: `fit_distribution()` with MLE, MME, and QME.
* Goodness-of-fit tests: KS, Anderson-Darling, Chi-Square, Cramer-von Mises.
* Diagnostics: `diagnostics()`, `calculate_residuals()`, `detect_outliers()`.
* Bootstrap confidence intervals: `bootstrap_ci()`.
* Supported distributions: normal, lognormal, gamma, Weibull, exponential,
  beta, uniform, Student-t, Pareto, Gumbel.
