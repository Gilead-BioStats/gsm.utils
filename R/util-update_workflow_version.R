#' Update version in GitHub Actions workflow `.yaml` files
#'
#' @param dir `string` path to directory containing GitHub Actions workflow `.yaml` files
#' @param description_path `string` path to `DESCRIPTION` file
#' @param label `string` label to identify version line in workflow files
#' @param recursive `boolean` whether to search directories recursively
#' @param add_if_missing `boolean` whether to add version line if missing
#'
#' @export
#'
update_workflow_version <- function(
  dir = "inst/gha_templates/workflows",
  description_path = "DESCRIPTION",
  label = "# gsm.utils GHA version",
  recursive = TRUE,
  add_if_missing = TRUE
) {
  stopifnot(dir.exists(dir))
  stopifnot(file.exists(description_path))

  # Read DESCRIPTION version
  desc <- read.dcf(description_path)
  if (!"Version" %in% colnames(desc)) {
    stop("DESCRIPTION file does not contain a Version field.")
  }
  version <- desc[1, "Version"]

  # Discover .yaml files
  files <- list.files(
    dir,
    pattern = "\\.ya?ml$",
    recursive = recursive,
    full.names = TRUE
  )

  if (length(files) == 0) {
    warning("No .yaml files found.")
    return(invisible(NULL))
  }

  pattern <- paste0(label, "\\s*:")

  for (file in files) {
    lines <- readLines(file, warn = FALSE)

    if (any(grepl(pattern, lines))) {
      # Replace existing line
      lines[grep(pattern, lines)] <- paste0(label, ": ", version)
      action <- "UPDATED"
    } else if (add_if_missing) {
      # Append line to top of file
      lines <- c(paste0(label, ": ", version), lines)
      action <- "ADDED"
    } else {
      next
    }

    writeLines(lines, file)

    message(sprintf(
      "%s: %s -> %s",
      action,
      basename(file),
      version
    ))
  }
}
