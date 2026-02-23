# distfitr 🎯

**برازش حرفه‌ای توزیع آماری برای R**

یک پکیج R جامع برای برازش توزیع‌های آماری با تست‌های نیکویی برازش، فواصل اطمینان bootstrap، تشخیص‌های پیشرفته و پشتیبانی چندزبانه.

[![R-CMD-check](https://github.com/alisadeghiaghili/distfitr/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/alisadeghiaghili/distfitr/actions/workflows/R-CMD-check.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.1.0-green.svg)](https://github.com/alisadeghiaghili/distfitr/releases)

[English](README.md) | **فارسی** | [Deutsch](README.de.md)

---

## distfitr چیست؟

distfitr توزیع‌های آماری را روی داده برازش می‌دهد و همه چیزی که برای ارزیابی برازش نیاز دارید در اختیارتان می‌گذارد: برآورد پارامترها، تست‌های نیکویی برازش، فواصل اطمینان bootstrap، و تشخیص‌ها — با API یکپارچه و خروجی چندزبانه.

---

## نصب

```r
# از GitHub
devtools::install_github("alisadeghiaghili/distfitr")
```

پیش‌نیازها: R >= 4.0.0، پکیج‌ها: `stats`, `graphics`, `grDevices`, `parallel`, `jsonlite`

---

## شروع سریع

```r
library(distfitr)

# تنظیم زبان فارسی
set_language("fa")

set.seed(42)
data <- rnorm(1000, mean = 10, sd = 2)

# برازش
fit <- fit_distribution(data, "normal", method = "mle")
print(fit)

# تست‌های نیکویی برازش
gof <- gof_tests(fit)
print(gof)

# فواصل اطمینان bootstrap
ci <- bootstrap_ci(fit, n_bootstrap = 1000)
print(ci)

# تشخیص‌ها و تشخیص نقاط پرت
diag <- diagnostics(fit)
outliers <- detect_outliers(fit, method = "all")
```

---

## پشتیبانی چندزبانه 🌐

```r
set_language("en")   # English
set_language("fa")   # فارسی (پیش‌فرض فارسی)
set_language("de")   # Deutsch

get_language()
list_languages()
```

---

## توزیع‌های پشتیبانی‌شده

| توزیع | کاربرد رایج |
|---|---|
| نرمال | قد، خطاهای اندازه‌گیری |
| لگ‌نرمال | درآمد، قیمت سهام |
| وایبول | قابلیت اطمینان، طول عمر |
| گاما | زمان انتظار، بارندگی |
| نمایی | زمان بین رویدادها |
| بتا | احتمالات، نرخ‌ها |
| یکنواخت | شبیه‌سازی |
| t استیودنت | نمونه‌های کوچک، دم سنگین |
| پارتو | پدیده‌های قانون توان |
| گامبل | تحلیل مقادیر فرین |

```r
list_distributions()
```

---

## ویژگی‌های اصلی

**۳ روش برآورد:** حداکثر درستنمایی (MLE)، روش گشتاورها، تطابق کوانتایل

**۴ تست نیکویی برازش:** کولموگروف-اسمیرنوف، اندرسون-دارلینگ، خی‌دو، کرامر-فون‌میزس

**۳ روش bootstrap:** پارامتریک، ناپارامتریک، BCa — با پردازش موازی

**تشخیص‌ها:** ۴ نوع باقیمانده، معیارهای تأثیرگذاری (فاصله کوک، اهرم، DFFITS)، ۴ روش تشخیص نقاط پرت

**انتخاب مدل:**
```r
candidates <- c("normal", "lognormal", "gamma", "weibull")
fits <- lapply(candidates, function(d) fit_distribution(data, d))
aics <- sapply(fits, function(f) f$aic)
best <- candidates[which.min(aics)]
```

---

## مجوز

MIT — فایل [LICENSE](LICENSE) را ببینید.

---

## تماس

**علی صادقی آقیلی**  
🌐 [zil.ink/thedatascientist](https://zil.ink/thedatascientist) | 💻 [@alisadeghiaghili](https://github.com/alisadeghiaghili)
