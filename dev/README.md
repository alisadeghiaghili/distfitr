# Development Tools

This directory contains scripts and tools for package development and testing.
These files are **not included** in the distributed CRAN package.

## Files

- `install_test.R` - Post-installation verification script
- `manual_test_all.R` - Comprehensive manual testing script

## Usage

### Post-Installation Test

After installing the package, run:

```r
source("dev/install_test.R")
```

This will verify that all core functionality works correctly.

### Comprehensive Manual Tests

To run all manual tests:

```r
source("dev/manual_test_all.R")
```

This performs extensive testing of all package features.

## Automated Tests

For formal unit tests, use:

```r
devtools::test()
```

For test coverage:

```r
covr::package_coverage()
```

For full R CMD check:

```r
devtools::check()
```
