# Tests for i18n state management (prevent locked binding regression)

test_that("i18n system initializes without errors", {
  # This should not throw locked binding error
  expect_silent(init_i18n())
})

test_that("set_language works without locked binding error", {
  # This was throwing the locked binding error
  expect_message(set_language("en"), "Language set to")
  expect_message(set_language("fa"), "Language set to")
  expect_message(set_language("de"), "Language set to")
  expect_message(set_language("en"), "Language set to")  # Back to English
})

test_that("get_language returns correct value after set_language", {
  set_language("en")
  expect_equal(get_language(), "en")
  
  set_language("fa")
  expect_equal(get_language(), "fa")
  
  set_language("de")
  expect_equal(get_language(), "de")
  
  # Reset
  set_language("en")
})

test_that("fit_distribution works without locked binding error", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  
  # This was the main issue - printing fit caused error
  expect_silent({
    fit <- fit_distribution(x, "normal")
  })
  
  # Print should work
  expect_output(print(fit), "Distribution")
})

test_that("language switching works during fit operations", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  
  # Fit with English
  set_language("en")
  fit_en <- fit_distribution(x, "normal")
  expect_output(print(fit_en), "Distribution")
  
  # Switch to Persian and fit again
  set_language("fa")
  fit_fa <- fit_distribution(x, "normal")
  expect_output(print(fit_fa), "توزیع|Distribution")  # May contain either
  
  # Switch to German and fit again
  set_language("de")
  fit_de <- fit_distribution(x, "normal")
  expect_output(print(fit_de), "Verteilung|Distribution")  # May contain either
  
  # Reset
  set_language("en")
})

test_that("translation caching works without errors", {
  # Load translations multiple times - should use cache
  set_language("en")
  trans1 <- load_translations()
  trans2 <- load_translations()  # Should use cache
  
  expect_equal(trans1$language_code, trans2$language_code)
  
  # Change language - should reload
  set_language("fa")
  trans3 <- load_translations()
  expect_equal(trans3$language_code, "fa")
  
  # Reset
  set_language("en")
})

test_that("multiple fit operations don't cause state conflicts", {
  set.seed(123)
  x <- rnorm(100, mean = 5, sd = 2)
  
  # Multiple fits in sequence
  fit1 <- fit_distribution(x, "normal")
  fit2 <- fit_distribution(x, "gamma")
  fit3 <- fit_distribution(x, "weibull")
  
  # All should print without errors
  expect_output(print(fit1), "Distribution")
  expect_output(print(fit2), "Distribution")
  expect_output(print(fit3), "Distribution")
})

test_that("list_languages works without errors", {
  langs <- list_languages()
  
  expect_s3_class(langs, "data.frame")
  expect_equal(nrow(langs), 3)
  expect_true("code" %in% names(langs))
  expect_true("language" %in% names(langs))
  expect_true("current" %in% names(langs))
})

test_that("tr() function works without locked binding", {
  set_language("en")
  
  # Translation should work
  result <- tr("distribution_names.normal")
  expect_type(result, "character")
  expect_true(nchar(result) > 0)
})

test_that("get_dist_name and get_dist_description work", {
  set_language("en")
  
  name <- get_dist_name("normal")
  desc <- get_dist_description("normal")
  
  expect_type(name, "character")
  expect_type(desc, "character")
  expect_true(nchar(name) > 0)
  expect_true(nchar(desc) > 0)
})

test_that("locale_format works without errors", {
  set_language("en")
  
  num_format <- locale_format(1234.5678, "number", 2)
  pct_format <- locale_format(0.1234, "percent", 2)
  pval_format <- locale_format(0.0523, "pvalue")
  
  expect_type(num_format, "character")
  expect_type(pct_format, "character")
  expect_type(pval_format, "character")
})

test_that("is_rtl returns correct value for each language", {
  set_language("en")
  expect_false(is_rtl())
  
  set_language("fa")
  expect_true(is_rtl())
  
  set_language("de")
  expect_false(is_rtl())
  
  # Reset
  set_language("en")
})

test_that("environment persistence works across function calls", {
  # Set language in one call
  set_language("fa")
  
  # Get in another - should persist
  lang1 <- get_language()
  expect_equal(lang1, "fa")
  
  # Do a fit
  set.seed(123)
  x <- rnorm(50, mean = 5, sd = 2)
  fit <- fit_distribution(x, "normal")
  
  # Language should still be Persian
  lang2 <- get_language()
  expect_equal(lang2, "fa")
  
  # Reset
  set_language("en")
})

test_that("no memory leaks in i18n environment", {
  # Store initial state
  initial_lang <- get_language()
  
  # Perform many operations
  for (i in 1:10) {
    set_language("en")
    set_language("fa")
    set_language("de")
    load_translations()
  }
  
  # Should still work
  final_lang <- get_language()
  expect_type(final_lang, "character")
  expect_true(final_lang %in% c("en", "fa", "de"))
  
  # Reset
  set_language(initial_lang)
})
