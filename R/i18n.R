#' Multilingual Support (i18n)
#'
#' @description
#' Internationalization (i18n) system for distfitr package.
#' Supports multiple languages with easy switching.
#'
#' @name i18n
NULL

# Package-level environment to store state (avoids locked binding issues)
.pkg_env <- new.env(parent = emptyenv())
.pkg_env$language <- "en"
.pkg_env$translations <- NULL

#' Initialize i18n System
#' @keywords internal
init_i18n <- function() {
  if (is.null(.pkg_env$language)) {
    .pkg_env$language <- "en"
  }
  if (is.null(.pkg_env$translations)) {
    .pkg_env$translations <- NULL
  }
}

#' Set Package Language
#'
#' @description
#' Set the language for distfitr package outputs.
#'
#' @param lang Character. Language code: "en" (English), "fa" (Persian/Farsi),
#'   or "de" (German). Default is "en".
#'   
#' @return Invisibly returns the previous language setting.
#' @export
#' @examples
#' # Set to Persian
#' set_language("fa")
#' 
#' # Set to German
#' set_language("de")
#' 
#' # Back to English
#' set_language("en")
set_language <- function(lang = "en") {
  
  init_i18n()  # Ensure initialized
  
  available_langs <- c("en", "fa", "de")
  
  if (!lang %in% available_langs) {
    stop(sprintf(
      "Language '%s' not supported. Available languages: %s",
      lang,
      paste(available_langs, collapse = ", ")
    ))
  }
  
  old_lang <- .pkg_env$language
  
  # Update language
  .pkg_env$language <- lang
  
  # Clear cached translations to force reload
  .pkg_env$translations <- NULL
  
  message(sprintf("Language set to: %s", 
                  switch(lang,
                         en = "English",
                         fa = "\u0641\u0627\u0631\u0633\u06cc (Persian)",
                         de = "Deutsch (German)")))
  
  invisible(old_lang)
}

#' Get Current Language
#'
#' @description
#' Get the currently active language.
#'
#' @return Character. Current language code.
#' @export
#' @examples
#' get_language()
get_language <- function() {
  init_i18n()  # Ensure initialized
  if (is.null(.pkg_env$language)) return("en")
  return(.pkg_env$language)
}

#' List Available Languages
#'
#' @description
#' List all available languages in the package.
#'
#' @return Data frame with language codes and names.
#' @export
#' @examples
#' list_languages()
list_languages <- function() {
  
  init_i18n()  # Ensure initialized
  
  langs <- data.frame(
    code = c("en", "fa", "de"),
    language = c("English", "\u0641\u0627\u0631\u0633\u06cc (Persian/Farsi)", "Deutsch (German)"),
    stringsAsFactors = FALSE
  )
  
  # Mark current language
  current_lang <- get_language()
  langs$current <- langs$code == current_lang
  
  return(langs)
}

#' Load Translation File
#'
#' @description
#' Load translations from JSON file for a specific language.
#'
#' @param lang Character. Language code.
#'   
#' @return List with translations.
#' @keywords internal
load_translations <- function(lang = NULL) {
  
  init_i18n()  # Ensure initialized
  
  if (is.null(lang)) {
    lang <- get_language()
  }
  
  # Check cache first
  if (!is.null(.pkg_env$translations) && 
      !is.null(.pkg_env$translations$language_code) &&
      .pkg_env$translations$language_code == lang) {
    return(.pkg_env$translations)
  }
  
  # Find translation file
  locale_file <- system.file(
    "locales", 
    paste0(lang, ".json"), 
    package = "distfitr"
  )
  
  if (locale_file == "" || !file.exists(locale_file)) {
    warning(sprintf("Translation file for '%s' not found. Using English.", lang))
    locale_file <- system.file("locales", "en.json", package = "distfitr")
  }
  
  # Load JSON
  if (requireNamespace("jsonlite", quietly = TRUE)) {
    translations <- jsonlite::fromJSON(locale_file, simplifyVector = FALSE)
  } else {
    # Fallback if jsonlite not available
    warning("jsonlite package not available. Install with: install.packages('jsonlite')")
    translations <- list(language_code = "en")
  }
  
  # Cache translations
  .pkg_env$translations <- translations
  
  return(translations)
}

#' Translate Text
#'
#' @description
#' Internal function to translate a text key to the current language.
#'
#' @param key Character. Translation key in dot notation (e.g., "fitting.method_mle").
#' @param ... Additional arguments for sprintf formatting.
#'   
#' @return Translated text string.
#' @keywords internal
#' @noRd
tr <- function(key, ...) {
  
  translations <- load_translations()
  
  # Split key by dots
  keys <- strsplit(key, "\\.")[[1]]
  
  # Navigate nested list
  value <- translations
  for (k in keys) {
    if (is.list(value) && k %in% names(value)) {
      value <- value[[k]]
    } else {
      # Key not found, return key itself
      return(key)
    }
  }
  
  # If value is still a list, something went wrong
  if (is.list(value)) {
    return(key)
  }
  
  # Format with additional arguments if provided
  args <- list(...)
  if (length(args) > 0) {
    value <- do.call(sprintf, c(list(fmt = value), args))
  }
  
  return(value)
}

#' Get Distribution Name (Translated)
#'
#' @description
#' Get the translated name of a distribution.
#'
#' @param dist_name Character. Internal distribution name.
#'   
#' @return Translated distribution name.
#' @export
#' @examples
#' get_dist_name("normal")
get_dist_name <- function(dist_name) {
  key <- paste0("distribution_names.", dist_name)
  return(tr(key))
}

#' Get Distribution Description (Translated)
#'
#' @description
#' Get the translated description of a distribution.
#'
#' @param dist_name Character. Internal distribution name.
#'   
#' @return Translated distribution description.
#' @export
#' @examples
#' get_dist_description("normal")
get_dist_description <- function(dist_name) {
  key <- paste0("distribution_descriptions.", dist_name)
  return(tr(key))
}

#' Format with Current Locale
#'
#' @description
#' Internal function to format numbers and text according to current locale.
#'
#' @param x Numeric or character value to format.
#' @param type Character. Type of formatting: "number", "percent", "pvalue".
#' @param digits Integer. Number of decimal places.
#'   
#' @return Formatted string.
#' @keywords internal
#' @noRd
locale_format <- function(x, type = "number", digits = 4) {
  
  lang <- get_language()
  
  if (type == "number") {
    # Standard number formatting
    result <- sprintf(paste0("%.", digits, "f"), x)
    
    # Persian uses Persian digits
    if (lang == "fa") {
      result <- convert_to_persian_digits(result)
    }
    
    return(result)
    
  } else if (type == "percent") {
    # Percentage
    result <- sprintf(paste0("%.", digits, "f%%"), x * 100)
    
    if (lang == "fa") {
      result <- convert_to_persian_digits(result)
    }
    
    return(result)
    
  } else if (type == "pvalue") {
    # P-value formatting
    if (x < 0.0001) {
      result <- "< 0.0001"
    } else {
      result <- sprintf("%.4f", x)
    }
    
    if (lang == "fa") {
      result <- convert_to_persian_digits(result)
    }
    
    return(result)
    
  } else {
    return(as.character(x))
  }
}

#' Convert to Persian Digits
#' @keywords internal
convert_to_persian_digits <- function(text) {
  
  persian_digits <- c(
    "0" = "\u06f0", "1" = "\u06f1", "2" = "\u06f2", "3" = "\u06f3", "4" = "\u06f4",
    "5" = "\u06f5", "6" = "\u06f6", "7" = "\u06f7", "8" = "\u06f8", "9" = "\u06f9"
  )
  
  result <- text
  for (i in seq_along(persian_digits)) {
    result <- gsub(names(persian_digits)[i], persian_digits[i], result, fixed = TRUE)
  }
  
  return(result)
}

#' RTL/LTR Text Direction
#'
#' @description
#' Internal function to determine if current language is Right-to-Left.
#'
#' @return Logical. TRUE if RTL, FALSE if LTR.
#' @keywords internal
#' @noRd
is_rtl <- function() {
  lang <- get_language()
  return(lang == "fa")  # Persian is RTL
}

#' Get Formatted Header
#'
#' @description
#' Get a formatted section header respecting RTL/LTR.
#'
#' @param text Character. Header text.
#' @param level Integer. Header level (1, 2, 3).
#'   
#' @return Formatted header string.
#' @keywords internal
get_formatted_header <- function(text, level = 1) {
  
  if (level == 1) {
    separator <- "====="
  } else if (level == 2) {
    separator <- "-----"
  } else {
    separator <- "....."
  }
  
  header <- sprintf("\n%s %s %s\n", separator, text, separator)
  
  return(header)
}

#' Print Translation Info
#' @keywords internal
print_translation_info <- function() {
  
  translations <- load_translations()
  
  cat("\n===== distfitr Translation Info =====\n\n")
  cat(sprintf("Current Language: %s (%s)\n", 
              translations$language,
              translations$language_code))
  cat(sprintf("Direction: %s\n", ifelse(is_rtl(), "RTL", "LTR")))
  cat("\nAvailable Languages:\n")
  print(list_languages())
  cat("\n====================================\n")
}
