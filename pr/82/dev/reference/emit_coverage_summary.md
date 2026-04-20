# Emit Coverage Summary Artifact

Computes test coverage for the current package using covr and writes a
normalized JSON summary file. Intended to be called from GitHub Actions
workflows, but works locally with explicit argument overrides.

## Usage

``` r
emit_coverage_summary(
  output_path = "coverage-summary.json",
  repo = NULL,
  sha = NULL,
  ref = NULL,
  runner_os = NULL,
  r_version = NULL,
  timestamp_utc = NULL,
  coverage = NULL,
  allow_fail = FALSE,
  quiet = TRUE
)
```

## Arguments

- output_path:

  `character` path for the output JSON file. Default is
  `"coverage-summary.json"`.

- repo:

  `character` repository name in `owner/repo` format. Defaults to the
  `GITHUB_REPOSITORY` environment variable, or `NA` if unset.

- sha:

  `character` full commit SHA. Defaults to the `GITHUB_SHA` environment
  variable, or `NA` if unset.

- ref:

  `character` git ref (e.g. `"refs/heads/main"`). Defaults to the
  `GITHUB_REF` environment variable, or `NA` if unset.

- runner_os:

  `character` runner OS label. Defaults to the `RUNNER_OS` environment
  variable, or `NA` if unset.

- r_version:

  `character` R version string. Defaults to
  `as.character(getRversion())`.

- timestamp_utc:

  `character` ISO-8601 UTC timestamp string. Defaults to the current
  time formatted as `"%Y-%m-%dT%H:%M:%SZ"`.

- coverage:

  a `covr` coverage object returned by
  [`covr::package_coverage()`](http://covr.r-lib.org/reference/package_coverage.md).
  If `NULL` (default), coverage is computed automatically.

- allow_fail:

  `logical` if `TRUE`, coverage computation errors are caught; the JSON
  is written with `coverage_percent: null` and an `error_message` field
  instead of stopping. Default is `FALSE`.

- quiet:

  `logical` suppress informational messages. Default is `TRUE`.

## Value

Invisibly returns the named list written to JSON.

## Examples

``` r
if (FALSE) { # \dontrun{
# Compute and write to default location
emit_coverage_summary()

# Override context fields for local testing
emit_coverage_summary(
  output_path = tempfile(fileext = ".json"),
  repo        = "Gilead-BioStats/gsm.utils",
  sha         = "abc1234"
)
} # }
```
