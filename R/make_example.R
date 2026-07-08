#' Create an example R Markdown template
#'
#' Creates a new example `.Rmd` file from a standard template.
#'
#' @param strName (`string`) Display name of the example.
#' @param strType (`string`) Type of example, either `"Example"` or
#'   `"Cookbook"`.
#' @param strDetails (`string`) Optional description for the example.
#' @param intIndex (`numeric`) Optional ordering index for the examples menu.
#' @param output_dir (`string`) Directory to write the example to.
#' @inheritParams .shared-params
#'
#' @returns Path to the created example file (invisibly).
#' @export
make_example <- function(
  strName = "Example_Name",
  strType = c("Example", "Cookbook"),
  strDetails = "<<Fill in Example description here>>",
  intIndex = 999,
  output_dir = "pkgdown/menus/examples",
  overwrite = FALSE,
  verbose = TRUE
) {
  rlang::check_required(strName)
  strType <- rlang::arg_match(strType, c("Example", "Cookbook"))
  make_asset(
    strFilename = build_example_filename(strName, strType),
    strMenu = basename(output_dir),
    strTemplate = build_example_template(
      strName = strName,
      strType = strType,
      strDetails = strDetails,
      intIndex = intIndex
    ),
    strMenuDir = dirname(output_dir),
    overwrite = overwrite,
    verbose = verbose
  )
}

#' Build a safe example filename
#'
#' @inheritParams make_example
#' @returns File name for the example.
#' @keywords internal
build_example_filename <- function(strName, strType) {
  safe_name <- gsub("[^A-Za-z0-9]+", "_", strName)
  safe_name <- gsub("^_|_$", "", safe_name)
  paste0(strType, "_", safe_name, ".Rmd")
}

#' Build template content for an example
#'
#' @inheritParams make_example
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
    "  fs::path_package(\"your.package\", \"report\", \"Report_Name.Rmd\"),",
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
