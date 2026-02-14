# distfitr Test Suite

Comprehensive test coverage for the distfitr package using testthat.

## Test Organization

### Core Functionality Tests

**`test-distributions.R`** (40+ tests)
- Distribution object creation and validation
- Distribution function correctness (PDF, CDF, quantile, random)
- Pareto and Gumbel custom implementations
- Error handling for invalid distributions

**`test-fitting.R`** (45+ tests)
- MLE, MME, and QME fitting methods
- Parameter estimation accuracy
- AIC/BIC calculations
- Fitting all 10 distributions
- Input validation and error handling
- Print and summary methods

**`test-gof.R`** (30+ tests)
- Kolmogorov-Smirnov test
- Anderson-Darling test
- Chi-Square test
- Cramér-von Mises test
- Overall GOF assessment
- Different significance levels
- Poor fit detection

**`test-bootstrap.R`** (25+ tests)
- Parametric bootstrap
- Non-parametric bootstrap
- BCa method
- Different confidence levels
- Reproducibility with seeds
- Parallel processing (conditional)
- Convergence handling

**`test-diagnostics.R`** (25+ tests)
- All 4 residual types
- Influence diagnostics (Cook's D, leverage, DFFITS)
- All 4 outlier detection methods
- Consensus outlier detection
- Q-Q and P-P plot data
- Residual normality checks

**`test-i18n.R`** (25+ tests)
- Language switching (en, fa, de)
- Translation system (tr function)
- Distribution name translations
- Locale-aware formatting
- RTL/LTR detection
- Persian digit conversion
- Print method internationalization

**`test-edge-cases.R`** (20+ tests)
- Extreme values
- Small and large sample sizes
- Constant data
- Boundary conditions
- Distribution-specific edge cases
- Convergence failures
- Single and multi-parameter distributions

**`helper-functions.R`**
- Test utilities
- Data generation helpers
- Validation functions

## Running Tests

### Run All Tests

```r
# From R console
devtools::test()

# Or with testthat directly
testthat::test_dir("tests/testthat")
```

### Run Specific Test File

```r
testthat::test_file("tests/testthat/test-fitting.R")
```

### Run Tests with Coverage

```r
covr::package_coverage()
```

### Run Tests in Parallel

```r
testthat::test_dir("tests/testthat", reporter = "progress", 
                   stop_on_failure = FALSE)
```

## Test Statistics

**Total Tests:** 210+

**Test Coverage by Component:**
- Distributions: 40+ tests (~20%)
- Fitting: 45+ tests (~21%)
- GOF Tests: 30+ tests (~14%)
- Bootstrap: 25+ tests (~12%)
- Diagnostics: 25+ tests (~12%)
- i18n: 25+ tests (~12%)
- Edge Cases: 20+ tests (~9%)

**Expected Coverage:** >85%

## Test Practices

### Test Naming

Tests follow the pattern:
```r
test_that("function_name does expected_behavior", { ... })
```

### Seed Usage

All tests using random data set a seed for reproducibility:
```r
set.seed(42)
data <- rnorm(100)
```

### CRAN Compatibility

Some tests are skipped on CRAN:
```r
skip_on_cran()  # For slow or resource-intensive tests
```

### Conditional Tests

Tests that require specific conditions:
```r
skip_if(parallel::detectCores() < 2, "Need multiple cores")
```

## Continuous Integration

Tests run automatically on:
- Every push to main branch
- Every pull request
- Scheduled nightly builds

Platforms tested:
- Ubuntu (latest)
- macOS (latest)
- Windows (latest)

R versions tested:
- R-release
- R-devel
- R-oldrel

## Test Coverage Report

Generate coverage report:
```r
library(covr)
cov <- package_coverage()
report(cov)
```

View coverage in browser:
```r
zero_coverage(cov)  # Show untested code
```

## Adding New Tests

### Template

```r
test_that("new_function works correctly", {
  # Setup
  input <- create_test_input()
  
  # Execute
  result <- new_function(input)
  
  # Assert
  expect_s3_class(result, "expected_class")
  expect_equal(result$value, expected_value)
  expect_true(all(is.finite(result$data)))
})
```

### Best Practices

1. **One concept per test**: Each test should check one specific behavior
2. **Clear test names**: Describe what is being tested
3. **Use appropriate expects**: Choose the right expectation function
4. **Test edge cases**: Include boundary conditions
5. **Test errors**: Ensure functions fail appropriately
6. **Use helpers**: Leverage helper-functions.R for common operations
7. **Keep tests fast**: Tests should run in <5 seconds total
8. **Document complex tests**: Add comments for non-obvious tests

## Common Expectations

```r
# Type checks
expect_type(x, "double")
expect_s3_class(x, "distfitr_fit")

# Value checks
expect_equal(x, 5, tolerance = 1e-6)
expect_true(x > 0)
expect_false(is.na(x))

# Structure checks
expect_length(x, 10)
expect_named(x, c("a", "b"))

# Output checks
expect_output(print(x), "pattern")
expect_message(func(), "message")
expect_warning(func(), "warning")
expect_error(func(), "error")

# Silent execution
expect_silent(func())
```

## Debugging Failed Tests

### Interactive Debugging

```r
# Run test interactively
testthat::test_file("tests/testthat/test-fitting.R", 
                   reporter = "location")

# Debug specific test
devtools::load_all()
browser()  # Set breakpoint
# Run failing test code
```

### Verbose Output

```r
testthat::test_dir("tests/testthat", 
                   reporter = testthat::DebugReporter$new())
```

## Performance Tests

Some tests are marked for performance monitoring:
```r
test_that("function is fast enough", {
  skip_on_cran()
  
  start_time <- Sys.time()
  result <- expensive_function(large_data)
  elapsed <- Sys.time() - start_time
  
  expect_true(elapsed < 5)  # Should complete in <5 seconds
})
```

## Test Maintenance

- Review test coverage quarterly
- Update tests when adding features
- Refactor slow tests
- Remove redundant tests
- Keep tests in sync with code

---

**Test Coverage Goal:** >90% by v1.0.0

**Current Status:** 210+ tests, comprehensive coverage of all major features
