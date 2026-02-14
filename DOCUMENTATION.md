# Documentation Guide for distfitr

## Current Status

✅ **Roxygen2 documentation added for:**
- Package-level documentation (`R/package.R`)
- Main fitting functions (`R/fitting.R`)
- Core S3 methods (print, summary)

⏳ **TODO: Add documentation for:**
- GOF tests functions
- Bootstrap functions
- Diagnostics functions
- i18n functions
- Outlier detection functions
- Distribution system functions

## Generating Documentation

### Step 1: Install roxygen2

```r
install.packages("roxygen2")
```

### Step 2: Generate documentation

```r
# From package root directory
devtools::document()

# This will:
# 1. Parse roxygen comments from R/*.R files
# 2. Generate man/*.Rd files
# 3. Update NAMESPACE
```

### Step 3: Check documentation

```r
# View help for specific function
?fit_distribution
?gof_tests
?bootstrap_ci

# View package help
?distfitr

# Check all help files
help(package = "distfitr")
```

### Step 4: Build and check

```r
# Build package with documentation
devtools::build()

# Run R CMD check (includes documentation checks)
devtools::check()
```

## Roxygen2 Basics

### Function Documentation Template

```r
#' Function Title (Short, One Line)
#'
#' @description
#' Longer description of what the function does.
#' Can span multiple lines.
#'
#' @param param_name Description of parameter
#' @param another_param Description of another parameter
#'
#' @return Description of what the function returns
#'
#' @export
#' @examples
#' # Example 1
#' result <- my_function(data, param = "value")
#' 
#' # Example 2 (not run)
#' \dontrun{
#'   advanced_example()
#' }
my_function <- function(param_name, another_param) {
  # Function body
}
```

### Common Roxygen Tags

- `@title` - Function title (optional, first line is used if omitted)
- `@description` - Detailed description
- `@param` - Parameter description
- `@return` - Return value description
- `@export` - Export function in NAMESPACE
- `@examples` - Usage examples
- `@seealso` - Related functions
- `@references` - Academic references
- `@author` - Function author
- `@keywords` - Keywords for search
- `@family` - Group related functions

### S3 Method Documentation

```r
#' Print Method for distfitr_fit
#'
#' @param x A distfitr_fit object
#' @param ... Additional arguments (unused)
#' @return The input object (invisibly)
#' @export
print.distfitr_fit <- function(x, ...) {
  # Method body
}
```

### Internal Functions

For functions not exported:

```r
#' Internal Helper Function
#' @keywords internal
#' @noRd
internal_helper <- function(x) {
  # Body
}
```

## Documentation Standards for distfitr

### Required for All Exported Functions

1. ✅ Title (first line)
2. ✅ Description
3. ✅ All parameters documented with `@param`
4. ✅ Return value documented with `@return`
5. ✅ At least one example
6. ✅ `@export` tag

### Example Structure

```r
#' Fit Distribution to Data
#'
#' @description
#' Fits a probability distribution to observed data using maximum likelihood
#' estimation (MLE), method of moments (MME), or quantile matching (QME).
#'
#' @param data Numeric vector of observations to fit
#' @param dist Character string naming the distribution (e.g., "normal", "gamma")
#'   or a distfitr_distribution object
#' @param method Character string specifying estimation method: "mle" (default),
#'   "mme", or "qme"
#' @param start Optional named list of starting parameter values for MLE
#' @param ... Additional arguments passed to optimization routines
#'
#' @return An object of class "distfitr_fit" containing:
#'   \item{data}{Original data vector}
#'   \item{distribution}{Distribution object used}
#'   \item{method}{Estimation method}
#'   \item{params}{Named vector of estimated parameters}
#'   \item{loglik}{Log-likelihood at estimated parameters}
#'   \item{aic}{Akaike Information Criterion}
#'   \item{bic}{Bayesian Information Criterion}
#'   \item{n}{Sample size}
#'
#' @export
#' @examples
#' # Fit normal distribution
#' set.seed(42)
#' data <- rnorm(100, mean = 5, sd = 2)
#' fit <- fit_distribution(data, "normal")
#' print(fit)
#' 
#' # Use method of moments
#' fit_mme <- fit_distribution(data, "normal", method = "mme")
#' 
#' # Compare multiple distributions
#' fit_gamma <- fit_distribution(data, "gamma")
#' fit_weibull <- fit_distribution(data, "weibull")
#' 
#' # Compare AICs
#' c(normal = fit$aic, gamma = fit_gamma$aic, weibull = fit_weibull$aic)
```

## Quick Commands

### Daily Workflow

```r
# After adding/modifying roxygen comments
devtools::document()  # Generate documentation
devtools::load_all()  # Load package
?function_name        # Check help

# Before commit
devtools::check()     # Full check including docs
```

### Build PDF Manual

```r
# Build PDF reference manual
devtools::build_manual()
```

### Check Specific Documentation

```r
# Check if all exported functions are documented
tools::undoc(package = "distfitr")

# Check for missing documentation
devtools::missing_s3()
```

## Current Documentation Coverage

### ✅ Documented

**Core Functions:**
- `fit_distribution()` - Full documentation
- `print.distfitr_fit()` - Full documentation
- `summary.distfitr_fit()` - Full documentation
- Package-level documentation

### 📝 Need Documentation

**GOF Tests:**
- `gof_tests()`
- `ks_test()`
- `ad_test()`
- `chi_square_test()`
- `cvm_test()`

**Bootstrap:**
- `bootstrap_ci()`

**Diagnostics:**
- `diagnostics()`
- `calculate_residuals()`
- `calculate_influence()`
- `detect_outliers()`

**i18n:**
- `set_language()`
- `get_language()`
- `list_languages()`
- `tr()`
- `get_dist_name()`
- `locale_format()`

**Distributions:**
- `get_distribution()`
- `list_distributions()`

## After Running devtools::document()

Expected output:
```
ℹ Updating distfitr documentation
ℹ Loading distfitr
Writing NAMESPACE
Writing distfitr-package.Rd
Writing fit_distribution.Rd
Writing print.distfitr_fit.Rd
Writing summary.distfitr_fit.Rd
```

Expected file structure:
```
distfitr/
├── man/
│   ├── distfitr-package.Rd
│   ├── fit_distribution.Rd
│   ├── gof_tests.Rd
│   ├── bootstrap_ci.Rd
│   ├── diagnostics.Rd
│   ├── detect_outliers.Rd
│   ├── set_language.Rd
│   ├── get_distribution.Rd
│   ├── list_distributions.Rd
│   ├── print.distfitr_fit.Rd
│   └── summary.distfitr_fit.Rd
```

## Testing Documentation

### Check Examples Run

```r
# Run all examples
devtools::run_examples()

# Run examples for specific function
tools::testInstalledBasic("fit_distribution")
```

### Check Links

```r
# Check all cross-references work
tools::checkDocFiles(dir = "man")
```

## Tips

1. **Keep examples simple** - Should run in <5 seconds
2. **Use `\dontrun{}` for slow examples** - Won't execute during check
3. **Cross-reference related functions** - Use `\code{\link{function_name}}`
4. **Include typical use cases** - Show common workflows
5. **Document edge cases** - Mention special behavior
6. **Keep descriptions concise** - Details go in @details section
7. **Use markdown** - Roxygen2 supports markdown formatting

## Next Steps

1. **Add roxygen comments to remaining functions**
2. **Run `devtools::document()` to generate .Rd files**
3. **Test with `devtools::check()`**
4. **Review generated help files**
5. **Build PDF manual for distribution**

---

**Note:** Once all functions are documented, the "No man pages found" warning
will disappear and users will have access to comprehensive help documentation
via `?function_name` and `help(package = "distfitr")`.
