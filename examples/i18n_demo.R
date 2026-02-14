# Multilingual Support (i18n) Demo
# =================================

library(distfitr)

cat("\n===== distfitr Multilingual Support Demo =====\n\n")

# Generate sample data
set.seed(42)
data <- rnorm(100, mean = 10, sd = 2)

# ============================================
# Demo 1: English (Default)
# ============================================

cat("\n--- Demo 1: English ---\n\n")

set_language("en")

# Fit distribution
fit_en <- fit_distribution(data, "normal", method = "mle")
print(fit_en)

# GOF tests
gof_en <- gof_tests(fit_en)
print(gof_en)

# Check current language
cat("\nCurrent language:")
print(get_language())

# ============================================
# Demo 2: Persian (Farsi)
# ============================================

cat("\n--- Demo 2: Persian (Farsi) ---\n\n")

set_language("fa")

# Same fit, different language output
fit_fa <- fit_distribution(data, "normal", method = "mle")
print(fit_fa)

# GOF tests in Persian
gof_fa <- gof_tests(fit_fa)
print(gof_fa)

# Distribution names in Persian
cat("\nنام توزیع‌ها به فارسی:\n")
for (dist in c("normal", "gamma", "weibull", "pareto")) {
  cat(sprintf("  %s: %s\n", dist, get_dist_name(dist)))
}

# ============================================
# Demo 3: German (Deutsch)
# ============================================

cat("\n--- Demo 3: German (Deutsch) ---\n\n")

set_language("de")

# Same fit, German output
fit_de <- fit_distribution(data, "normal", method = "mle")
print(fit_de)

# GOF tests in German
gof_de <- gof_tests(fit_de)
print(gof_de)

# Distribution names in German
cat("\nVerteilungsnamen auf Deutsch:\n")
for (dist in c("normal", "gamma", "weibull", "pareto")) {
  cat(sprintf("  %s: %s\n", dist, get_dist_name(dist)))
}

# ============================================
# Demo 4: Switching Languages Dynamically
# ============================================

cat("\n--- Demo 4: Dynamic Language Switching ---\n\n")

# Bootstrap in different languages
for (lang in c("en", "fa", "de")) {
  set_language(lang)
  cat(sprintf("\n=== Bootstrap in %s ===\n\n", 
              switch(lang, 
                     en = "English", 
                     fa = "فارسی",
                     de = "Deutsch")))
  
  boot_result <- bootstrap_ci(fit_en, n_bootstrap = 100, seed = 42)
  print(boot_result)
}

# ============================================
# Demo 5: Available Languages
# ============================================

cat("\n--- Demo 5: Available Languages ---\n\n")

set_language("en")
cat("All available languages:\n")
print(list_languages())

# ============================================
# Demo 6: Number Formatting
# ============================================

cat("\n--- Demo 6: Locale-Specific Formatting ---\n\n")

test_numbers <- c(1234.5678, 0.05, 0.0001)

for (lang in c("en", "fa", "de")) {
  set_language(lang)
  cat(sprintf("\n%s:\n", 
              switch(lang, 
                     en = "English",
                     fa = "فارسی",
                     de = "Deutsch")))
  
  for (num in test_numbers) {
    cat(sprintf("  %f -> %s (number)\n", 
                num, locale_format(num, "number", 4)))
    if (num < 1) {
      cat(sprintf("  %f -> %s (pvalue)\n", 
                  num, locale_format(num, "pvalue")))
    }
  }
}

# ============================================
# Demo 7: RTL Detection
# ============================================

cat("\n--- Demo 7: Text Direction ---\n\n")

for (lang in c("en", "fa", "de")) {
  set_language(lang)
  cat(sprintf("%s: %s\n", 
              lang, 
              ifelse(is_rtl(), "RTL (Right-to-Left)", "LTR (Left-to-Right)")))
}

# Reset to English
set_language("en")

cat("\n===== Demo Completed =====\n\n")
