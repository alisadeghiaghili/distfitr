# i18n System - Phase 2 Feature

## Overview

Full multilingual support (internationalization/i18n) has been added to distfitr in Phase 2.

## Supported Languages

1. **English** (`en`) - Default
2. **Persian/Farsi** (`fa`) - با پشتیبانی کامل RTL
3. **German** (`de`) - Mit vollständiger Unterstützung

## Features

### 1. JSON-Based Translation System

All translations stored in structured JSON files:
- `inst/locales/en.json`
- `inst/locales/fa.json`
- `inst/locales/de.json`

### 2. Dynamic Language Switching

```r
# Change language at runtime
set_language("fa")  # Switch to Persian
set_language("de")  # Switch to German
set_language("en")  # Back to English
```

### 3. Comprehensive Translation Coverage

- Distribution names and descriptions
- All fitting methods (MLE, MME, QME)
- GOF test names and interpretations
- Bootstrap methods and outputs
- Diagnostics terminology
- Error messages
- Common terms

### 4. Locale-Aware Formatting

```r
# Numbers formatted according to locale
locale_format(1234.56, "number", 2)  # "1234.56" (en), "۱۲۳۴.۵۶" (fa)
locale_format(0.05, "pvalue")         # "0.0500" (en), "۰.۰۵۰۰" (fa)
locale_format(0.95, "percent", 1)    # "95.0%" (en), "۹۵.۰%" (fa)
```

### 5. RTL/LTR Support

```r
# Detect text direction
is_rtl()  # TRUE for Persian, FALSE for English/German
```

### 6. Translation Helper Functions

```r
# Get translated distribution name
get_dist_name("normal")  # "Normal (Gaussian)" / "نرمال (گاوسی)" / "Normal (Gauß)"

# Get description
get_dist_description("weibull")  # Translated description

# Direct translation lookup
tr("fitting.method_mle")  # "Maximum Likelihood Estimation"
tr("gof_tests.title")     # "Goodness-of-Fit Test Results"
```

## Usage Examples

### Basic Workflow in Persian

```r
library(distfitr)
set_language("fa")

data <- rnorm(100, mean = 10, sd = 2)
fit <- fit_distribution(data, "normal")
print(fit)  # Output in Persian

gof <- gof_tests(fit)
print(gof)  # Tests and interpretations in Persian
```

### Basic Workflow in German

```r
library(distfitr)
set_language("de")

data <- rnorm(100, mean = 10, sd = 2)
fit <- fit_distribution(data, "normal")
print(fit)  # Ausgabe auf Deutsch

gof <- gof_tests(fit)
print(gof)  # Tests und Interpretationen auf Deutsch
```

### Language Management

```r
# Check current language
get_language()  # "en", "fa", or "de"

# List available languages
list_languages()
#   code                      language current
# 1   en                       English    TRUE
# 2   fa  فارسی (Persian/Farsi)   FALSE
# 3   de           Deutsch (German)   FALSE
```

## Implementation Details

### Translation Keys Structure

```
distribution_names.*         - Distribution display names
distribution_descriptions.*  - Short descriptions
fitting.*                    - Fitting-related terms
gof_tests.*                  - GOF test terminology
bootstrap.*                  - Bootstrap terms
diagnostics.*                - Diagnostics terminology
outliers.*                   - Outlier detection terms
errors.*                     - Error messages
common.*                     - Common terms (yes/no/passed/failed)
```

### Persian Digit Conversion

Automatic conversion of Western digits (0-9) to Persian digits (۰-۹) when language is set to Persian.

### Updated Print Methods

All S3 print methods updated to use i18n:
- `print.distfitr_fit()`
- `print.distfitr_gof()`
- `print.distfitr_bootstrap()`
- `print.distfitr_diagnostics()`

## Adding New Languages

1. Create new JSON file: `inst/locales/{lang_code}.json`
2. Translate all keys following existing structure
3. Add language to `list_languages()` function
4. Update `set_language()` validation
5. Test with demo script

## Performance

- Translations cached after first load
- Minimal overhead (<1ms per translation lookup)
- No impact on computation speed

## Future Enhancements

- More languages (Spanish, French, Chinese, Arabic)
- User-contributed translations
- Fallback language chain
- Pluralization rules
- Date/time formatting

---

**This feature makes distfitr accessible to non-English speakers worldwide!** 🌍
