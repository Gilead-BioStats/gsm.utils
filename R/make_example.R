#' Create an example R Markdown template
#'
#' Creates a new example `.Rmd` file from a standard template in
#' `inst/examples`.
#'
#' @param strName Character. Display name of the example.
#' @param strType Character. Type of example, either `"Example"` or
#'   `"Cookbook"`.
#' @param strDetails Character. Optional description for the example.
#' @param intIndex Numeric. Optional ordering index for the examples menu.
#' @param output_dir Character. Directory to write the example to.
#' @param overwrite Logical. Whether to overwrite an existing file.
#'
#' @returns Path to the created example file (invisibly).
#' @export
make_example <- function(
  strName = "Example_Name",
  strType = c("Example", "Cookbook"),
  strDetails = "<<Fill in Example description here>>",
  intIndex = 999,
  output_dir = "inst/examples",
  overwrite = FALSE
) {
  rlang::check_required(strName)
  strType <- rlang::arg_match(strType, c("Example", "Cookbook"))

  fs::dir_create(output_dir)

  file_name <- build_example_filename(strName, strType)
  output_path <- fs::path(output_dir, file_name)

  if (fs::file_exists(output_path) && !isTRUE(overwrite)) {
    cli::cli_abort("File already exists: {.path {output_path}}")
  }

  template <- build_example_template(
    strName = strName,
    strType = strType,
    strDetails = strDetails,
    intIndex = intIndex
  )

  writeLines(template, output_path)
  cli::cli_inform("Created example template at {.path {output_path}}.")
  invisible(output_path)
}

#' Build a safe example filename
#'
#' @param strName Character. Display name of the example.
#' @param strType Character. Example type prefix.
#' @returns File name for the example.
#' @keywords internal
build_example_filename <- function(strName, strType) {
  safe_name <- gsub("[^A-Za-z0-9]+", "_", strName)
  safe_name <- gsub("^_|_$", "", safe_name)
  paste0(strType, "_", safe_name, ".Rmd")
}

#' Build template content for an example
#'
#' @param strName Character. Display name of the example.
#' @param strType Character. Example type.
#' @param strDetails Character. Optional description.
#' @param intIndex Numeric. Optional ordering index.
#' @returns Character vector of template lines.
#' @keywords internal
build_example_template <- function(strName, strType, strDetails, intIndex) {
  description <- strDetails %||%
    paste0("Example of a ", strType, " generated using gsm packages.")
  index_line <- if (!is.na(intIndex)) paste0("index: ", intIndex) else NULL

  c(
    "---",
    paste0("title: \"", strName, "\""),
    "author: \"[gsm.utils](https://gilead-biostats.github.io/gsm.utils) Example\"",
    paste0("description: \"", description, "\""),
    index_line,
    "date: \"`r format(Sys.time(), '%B %d, %Y %H:%M:%S %Z')`\"",
    "output: html_document",
    "---",
    "",
    "# Set Up",
    "",
    "Describe the example and any setup steps here.",
    "",
    "<details>",
    "<summary>Setup</summary>",
    "",
    "```{r}",
    "# Load libraries and prepare data",
    "```",
    "",
    "</details>",
    "",
    "# Report",
    "",
    "Use `knitr::knit_child()` to embed an existing report Rmd (for example,",
    "from `inst/report`) into this example:",
    "",
    "```{r, echo=FALSE, results='asis'}",
    "child_env <- list2env(",
    "  list(params = list()),",
    "  parent = environment()",
    ")",
    "child_report <- knitr::knit_child(",
    "  system.file(\"report\", \"Report_Name.Rmd\", package = \"your.package\"),",
    "  envir = child_env,",
    "  quiet = TRUE",
    ")",
    "cat(child_report, sep = \"\\n\")",
    "```"
  )
}

#' Helper for missing values
#'
#' @name or_pipe
#' @param x Value to test.
#' @param y Fallback value.
#' @returns `x` if not `NULL`, otherwise `y`.
#' @keywords internal
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}