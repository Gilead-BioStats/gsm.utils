# gsm.utils

Tools to make an `OpenRBQM` developer’s life easier including standard
GitHub actions, issue and pull request templates and utility functions.

## Installation

You can install the latest release of gsm.utils from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("Gilead-BioStats/gsm.utils@*release⁠")
```

You can install the development version of gsm.utils from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("Gilead-BioStats/gsm.utils")
```

## Package Setup Utilities

The package provides two main functions to streamline package
development:

### `init_gsm_package()`

Initializes a new extension package with standardized structure and
configuration:

``` r
init_gsm_package(
  strPackageDir = "path/to/new/package",
  lDescriptionFields = list(),
  bIncludeWorkflowDir = TRUE
)
```

- Creates package skeleton using
  [`usethis::create_package()`](https://usethis.r-lib.org/reference/create_package.html)
- Sets up pkgdown documentation with GitHub Pages
- Configures testthat for unit testing
- Copies GitHub Actions workflows and issue templates from
  `inst/gha_templates`

### `update_gsm_package()`

Updates an existing GSM package with the latest standardized templates:

``` r
update_gsm_package(strPackageDir = ".")
```

- Refreshes `.github/ISSUE_TEMPLATE/` with current issue templates (Bug,
  Feature, Technical Task, Documentation Task)
- Updates `.github/workflows/` with latest GitHub Actions workflow
  definitions

Use this function to keep your package’s CI/CD infrastructure
synchronized with the latest conventions.

## GitHub Actions Workflows

The `inst/gha_templates/workflows` directory contains standardized
GitHub Actions workflow templates for GSM packages:

- **`R-CMD-check.yaml`**: Runs comprehensive R package checks on PRs to
  `main` across multiple platforms (macOS, Windows, Ubuntu) and R
  versions to ensure package integrity before release.

- **`R-CMD-check-dev.yaml`**: Lightweight R package check for PRs to
  `dev` branch, running on Ubuntu with current and minimum supported R
  versions for faster CI feedback during development.

- **`test-coverage.yaml`**: Measures and reports code test coverage
  using [covr](https://covr.r-lib.org), uploads results to Codecov, and
  archives test outputs for debugging failures.

- **`pkgdown-with-examples.yaml`**: Builds and deploys pkgdown
  documentation sites with automatic example indexing via
  [`add_pkgdown_examples()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/add_pkgdown_examples.md).
  Creates PR preview sites at `/pr/{number}` and deploys production
  sites to gh-pages on push to `main` or `dev`.

- **`pkgdown-cleanup.yaml`**: Automatically removes pkgdown PR preview
  directories from the gh-pages branch when pull requests are closed to
  keep the repository clean.

- **`format-suggest.yaml`**: Uses Posit’s `air` formatter to
  automatically check code formatting on pull requests and suggests
  corrections via reviewdog comments, requiring elevated permissions for
  external contributors.

- **`pr-commands.yaml`**: Enables maintainers to trigger actions via PR
  comments: `/document` runs `roxygen2::roxygenise()` to update
  documentation, and `/style` runs `styler::style_pkg()` to format code.

- **`r_releaser.yaml`**: Reusable workflow for building and attaching R
  package source tarballs to GitHub releases, using the A2-ai/r-releaser
  action with configurable options for data compression and vignette
  building.

## Code of Conduct

Please note that the gsm.utils project is released with a [Contributor
Code of
Conduct](https://gilead-biostats.github.io/gsm.utils/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
