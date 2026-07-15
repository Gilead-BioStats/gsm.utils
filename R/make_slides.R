#' Create a slide deck template
#'
#' Creates a new RevealJS `.qmd` file from a standard template.
#'
#' @inheritParams .shared-params
#'
#' @returns Path to the created slide deck file (invisibly).
#' @export
make_slides <- function(
  strTitle = "Slide Deck Title",
  intIndex = 999,
  output_dir = "pkgdown/menus/slides",
  overwrite = FALSE,
  verbose = TRUE
) {
  rlang::check_required(strTitle)
  make_asset(
    strFilename = .build_slides_filename(strTitle),
    strMenu = basename(output_dir),
    strTemplate = .build_slides_template(
      strTitle = strTitle,
      intIndex = intIndex
    ),
    strMenuDir = dirname(output_dir),
    overwrite = overwrite,
    verbose = verbose
  )
}

#' Build a safe slides filename
#'
#' Converts a title to a lowercase, hyphen-separated `.qmd` filename.
#'
#' @inheritParams make_slides
#' @returns File name for the slide deck.
#' @keywords internal
.build_slides_filename <- function(strTitle) {
  safe_name <- tolower(strTitle)
  safe_name <- gsub("[^a-z0-9]+", "-", safe_name)
  safe_name <- gsub("^-|-$", "", safe_name)
  paste0(safe_name, ".qmd")
}

#' Build template content for a slide deck
#'
#' @inheritParams make_slides
#' @returns Character vector of template lines.
#' @keywords internal
.build_slides_template <- function(strTitle, intIndex) {
  .build_asset_template(
    strTitle = strTitle,
    intIndex = intIndex,
    lHeaders = list(
      execute = list(eval = FALSE, echo = TRUE),
      format = list(
        revealjs = list(
          theme = "dark",
          `link-external-newwindow` = TRUE,
          transition = "slide",
          incremental = FALSE
        )
      )
    ),
    chrBody = c(
      "",
      "## First Slide Title",
      "",
      "- Bullet point",
      "- Another point",
      "",
      "## Slide with Two Columns",
      "",
      ":::: columns",
      "",
      "::: {.column width=\"60%\"}",
      "",
      "Content for the left column.",
      "",
      ":::",
      "",
      "::: {.column width=\"40%\"}",
      "",
      "Content for the right column.",
      "",
      ":::",
      "",
      "::::",
      "",
      "# Section Header Slide",
      "",
      "## Another Slide",
      "",
      "Content here."
    )
  )
}
