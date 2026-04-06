#' Emit Coverage Summary Artifact
#'
#' @description
#' Computes test coverage for the current package using covr and writes a
#' normalized JSON summary file. Intended to be called from GitHub Actions
#' workflows, but works locally with explicit argument overrides.
#'
#' @param output_path `character` path for the output JSON file.
#'   Default is `"coverage-summary.json"`.
#' @param repo `character` repository name in `owner/repo` format. Defaults to
#'   the `GITHUB_REPOSITORY` environment variable, or `NA` if unset.
#' @param sha `character` full commit SHA. Defaults to the `GITHUB_SHA`
#'   environment variable, or `NA` if unset.
#' @param ref `character` git ref (e.g. `"refs/heads/main"`). Defaults to the
#'   `GITHUB_REF` environment variable, or `NA` if unset.
#' @param runner_os `character` runner OS label. Defaults to the `RUNNER_OS`
#'   environment variable, or `NA` if unset.
#' @param r_version `character` R version string. Defaults to
#'   `as.character(getRversion())`.
#' @param timestamp_utc `character` ISO-8601 UTC timestamp string.
#'   Defaults to the current time formatted as `"%Y-%m-%dT%H:%M:%SZ"`.
#' @param coverage a `covr` coverage object returned by
#'   `covr::package_coverage()`. If `NULL` (default), coverage is computed
#'   automatically.
#' @param allow_fail `logical` if `TRUE`, coverage computation errors are
#'   caught; the JSON is written with `coverage_percent: null` and an
#'   `error_message` field instead of stopping. Default is `FALSE`.
#' @param quiet `logical` suppress informational messages. Default is `TRUE`.
#'
#' @return Invisibly returns the named list written to JSON.
#' @export
#'
#' @examples
#' \dontrun{
#' # Compute and write to default location
#' emit_coverage_summary()
#'
#' # Override context fields for local testing
#' emit_coverage_summary(
#'   output_path = tempfile(fileext = ".json"),
#'   repo        = "Gilead-BioStats/gsm.utils",
#'   sha         = "abc1234"
#' )
#' }
emit_coverage_summary <- function(
  output_path   = "coverage-summary.json",
  repo          = NULL,
  sha           = NULL,
  ref           = NULL,
  runner_os     = NULL,
  r_version     = NULL,
  timestamp_utc = NULL,
  coverage      = NULL,
  allow_fail    = FALSE,
  quiet         = TRUE
) {
  repo          <- repo          %||% Sys.getenv("GITHUB_REPOSITORY", unset = NA_character_)
  sha           <- sha           %||% Sys.getenv("GITHUB_SHA",         unset = NA_character_)
  ref           <- ref           %||% Sys.getenv("GITHUB_REF",         unset = NA_character_)
  runner_os     <- runner_os     %||% Sys.getenv("RUNNER_OS",           unset = NA_character_)
  r_version     <- r_version     %||% as.character(getRversion())
  timestamp_utc <- timestamp_utc %||% format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

  pct_or_err <- tryCatch(
    compute_coverage_percent(coverage),
    error = function(e) {
      if (!allow_fail) {
        cli::cli_abort("Coverage computation failed: {conditionMessage(e)}")
      }
      if (!quiet) cli::cli_alert_warning("Coverage failed: {conditionMessage(e)}")
      list(error = conditionMessage(e))
    }
  )

  if (is.list(pct_or_err)) {
    summary <- list(
      repo             = repo,
      sha              = sha,
      ref              = ref,
      coverage_percent = NA_real_,
      error_message    = pct_or_err$error,
      timestamp_utc    = timestamp_utc,
      runner_os        = runner_os,
      r_version        = r_version
    )
  } else {
    summary <- list(
      repo             = repo,
      sha              = sha,
      ref              = ref,
      coverage_percent = pct_or_err,
      timestamp_utc    = timestamp_utc,
      runner_os        = runner_os,
      r_version        = r_version
    )
  }

  jsonlite::write_json(
    summary,
    path       = output_path,
    pretty     = TRUE,
    auto_unbox = TRUE,
    na         = "null"
  )

  if (!quiet) cli::cli_alert_success("Coverage summary written to {.path {output_path}}")
  invisible(summary)
}

#' @noRd
compute_coverage_percent <- function(coverage = NULL) {
  rlang::check_installed("covr", reason = "to compute test coverage")
  if (is.null(coverage)) {
    coverage <- covr::package_coverage()
  }
  as.numeric(covr::percent_coverage(coverage))
}
