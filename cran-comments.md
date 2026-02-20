## R CMD check results

0 errors | 0 warnings | 1 note

## Notes

### checking for hidden files and directories

```
Found the following hidden files and directories:
  .github
```

The `.github` directory contains GitHub Actions CI/CD workflow files.
It is listed in `.Rbuildignore` and is not part of the distributed package.
This note is expected and acceptable per CRAN policy.

## Test environments

* Windows Server 2022 x64, R 4.5.2 (GitHub Actions, x86_64-w64-mingw32)
* macOS Sequoia 15.7.3, R 4.5.2 (GitHub Actions, aarch64-apple-darwin20)

## Downstream dependencies

None. This is a new package submission.
