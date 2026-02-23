# distfitr 🎯

**Professionelle Verteilungsanpassung für R**

Ein umfassendes R-Paket für statistische Verteilungsanpassung mit Anpassungstests, Bootstrap-Konfidenzintervallen, erweiterten Diagnosen und mehrsprachiger Ausgabe.

[![R-CMD-check](https://github.com/alisadeghiaghili/distfitr/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/alisadeghiaghili/distfitr/actions/workflows/R-CMD-check.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.1.0-green.svg)](https://github.com/alisadeghiaghili/distfitr/releases)

[English](README.md) | [فارسی](README.fa.md) | **Deutsch**

---

## Was ist distfitr?

distfitr passt statistische Verteilungen an Daten an und liefert alles, was zur Bewertung der Anpassungsgüte benötigt wird: Parameterschätzungen, Anpassungstests, Bootstrap-Konfidenzintervalle und Diagnosen — mit einer einheitlichen API und mehrsprachiger Ausgabe.

---

## Installation

```r
# Von GitHub
devtools::install_github("alisadeghiaghili/distfitr")
```

Voraussetzungen: R >= 4.0.0, Pakete: `stats`, `graphics`, `grDevices`, `parallel`, `jsonlite`

---

## Schnellstart

```r
library(distfitr)

# Deutsche Ausgabe aktivieren
set_language("de")

set.seed(42)
daten <- rnorm(1000, mean = 10, sd = 2)

# Anpassung
fit <- fit_distribution(daten, "normal", method = "mle")
print(fit)

# Anpassungstests
gof <- gof_tests(fit)
print(gof)

# Bootstrap-Konfidenzintervalle
ci <- bootstrap_ci(fit, n_bootstrap = 1000)
print(ci)

# Diagnosen und Ausreißererkennung
diag <- diagnostics(fit)
ausreisser <- detect_outliers(fit, method = "all")
```

---

## Mehrsprachige Ausgabe 🌐

```r
set_language("en")   # English
set_language("fa")   # فارسی
set_language("de")   # Deutsch

get_language()
list_languages()
```

---

## Unterstützte Verteilungen

| Verteilung | Typische Anwendung |
|---|---|
| Normalverteilung | Körpergröße, Messfehler |
| Lognormalverteilung | Einkommen, Aktienkurse |
| Weibull-Verteilung | Zuverlässigkeit, Lebensdauern |
| Gamma-Verteilung | Wartezeiten, Niederschlag |
| Exponentialverteilung | Zeit zwischen Ereignissen |
| Beta-Verteilung | Wahrscheinlichkeiten, Raten |
| Gleichverteilung | Simulation |
| Student-t-Verteilung | Kleine Stichproben, schwere Ränder |
| Pareto-Verteilung | Potenzgesetz-Phänomene |
| Gumbel-Verteilung | Extremwertanalyse |

```r
list_distributions()
```

---

## Hauptfunktionen

**3 Schätzmethoden:** Maximum-Likelihood (MLE), Momentenmethode, Quantil-Anpassung

**4 Anpassungstests:** Kolmogorov-Smirnov, Anderson-Darling, Chi-Quadrat, Cramér-von-Mises

**3 Bootstrap-Methoden:** Parametrisch, Nicht-parametrisch, BCa — mit Parallelverarbeitung

**Diagnosen:** 4 Residualstypen, Einflussmaße (Cook's Distanz, Hebelwerte, DFFITS), 4 Ausreißererkennungsmethoden

**Modellauswahl:**
```r
kandidaten <- c("normal", "lognormal", "gamma", "weibull")
anpassungen <- lapply(kandidaten, function(d) fit_distribution(daten, d))
aics <- sapply(anpassungen, function(f) f$aic)
beste <- kandidaten[which.min(aics)]
```

---

## Lizenz

MIT — siehe [LICENSE](LICENSE).

---

## Kontakt

**Ali Sadeghi Aghili**  
🌐 [zil.ink/thedatascientist](https://zil.ink/thedatascientist) | 💻 [@alisadeghiaghili](https://github.com/alisadeghiaghili)
