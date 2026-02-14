# Tests for i18n (internationalization)

test_that("set_language works for all supported languages", {
  # Store original language
  original_lang <- get_language()
  
  # Test English
  set_language("en")
  expect_equal(get_language(), "en")
  
  # Test Persian
  set_language("fa")
  expect_equal(get_language(), "fa")
  
  # Test German
  set_language("de")
  expect_equal(get_language(), "de")
  
  # Restore original
  set_language(original_lang)
})

test_that("set_language fails for unsupported language", {
  expect_error(set_language("fr"))  # French not yet supported
  expect_error(set_language("xx"))  # Invalid code
  expect_error(set_language(123))   # Non-character
})

test_that("list_languages returns all languages", {
  langs <- list_languages()
  
  expect_s3_class(langs, "data.frame")
  expect_true("code" %in% names(langs))
  expect_true("language" %in% names(langs))
  expect_true("current" %in% names(langs))
  
  expect_true("en" %in% langs$code)
  expect_true("fa" %in% langs$code)
  expect_true("de" %in% langs$code)
})

test_that("tr() translates keys correctly", {
  original_lang <- get_language()
  
  # English
  set_language("en")
  expect_match(tr("fitting.method_mle"), "Maximum Likelihood")
  expect_match(tr("common.passed"), "PASSED")
  
  # Persian
  set_language("fa")
  expect_match(tr("fitting.method_mle"), "[آبردو]")
  expect_match(tr("common.passed"), "موفق")
  
  # German
  set_language("de")
  expect_match(tr("fitting.method_mle"), "Maximum-Likelihood")
  expect_match(tr("common.passed"), "BESTANDEN")
  
  set_language(original_lang)
})

test_that("tr() returns key if translation not found", {
  result <- tr("nonexistent.key.here")
  expect_equal(result, "nonexistent.key.here")
})

test_that("tr() with sprintf formatting works", {
  original_lang <- get_language()
  set_language("en")
  
  # This key has %s placeholders
  result <- tr("errors.invalid_distribution", "test", "normal, gamma")
  expect_type(result, "character")
  
  set_language(original_lang)
})

test_that("get_dist_name translates distribution names", {
  original_lang <- get_language()
  
  set_language("en")
  expect_match(get_dist_name("normal"), "Normal")
  expect_match(get_dist_name("weibull"), "Weibull")
  
  set_language("fa")
  expect_match(get_dist_name("normal"), "نرمال")
  expect_match(get_dist_name("weibull"), "وایبول")
  
  set_language("de")
  expect_match(get_dist_name("normal"), "Normal")
  expect_match(get_dist_name("weibull"), "Weibull")
  
  set_language(original_lang)
})

test_that("get_dist_description works", {
  original_lang <- get_language()
  
  set_language("en")
  desc_en <- get_dist_description("normal")
  expect_type(desc_en, "character")
  expect_true(nchar(desc_en) > 10)
  
  set_language("fa")
  desc_fa <- get_dist_description("normal")
  expect_type(desc_fa, "character")
  expect_true(nchar(desc_fa) > 10)
  
  set_language(original_lang)
})

test_that("locale_format works for numbers", {
  original_lang <- get_language()
  
  set_language("en")
  expect_match(locale_format(1234.5678, "number", 2), "1234\\.57")
  
  set_language("fa")
  result_fa <- locale_format(1234.5678, "number", 2)
  expect_true(grepl("۱", result_fa))  # Contains Persian digit
  
  set_language(original_lang)
})

test_that("locale_format works for p-values", {
  original_lang <- get_language()
  set_language("en")
  
  expect_match(locale_format(0.0534, "pvalue"), "0\\.0534")
  expect_match(locale_format(0.00001, "pvalue"), "< 0\\.0001")
  
  set_language(original_lang)
})

test_that("is_rtl detects RTL languages correctly", {
  original_lang <- get_language()
  
  set_language("en")
  expect_false(is_rtl())
  
  set_language("fa")
  expect_true(is_rtl())
  
  set_language("de")
  expect_false(is_rtl())
  
  set_language(original_lang)
})

test_that("print methods use i18n", {
  set.seed(42)
  data <- rnorm(50, mean = 5, sd = 2)
  fit <- fit_distribution(data, "normal")
  
  original_lang <- get_language()
  
  # English output
  set_language("en")
  output_en <- capture.output(print(fit))
  expect_true(any(grepl("Method", output_en)))
  
  # Persian output
  set_language("fa")
  output_fa <- capture.output(print(fit))
  expect_true(any(grepl("روش", output_fa)))  # "Method" in Persian
  
  set_language(original_lang)
})
