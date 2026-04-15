# gsm.utils

<!-- badges: start -->

<div class="pkgdown-release">

[![R-CMD-check](https://github.com/Gilead-BioStats/gsm.utils/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Gilead-BioStats/gsm.utils/actions/workflows/R-CMD-check.yaml)

</div>

<div class="pkgdown-devel">

[![R-CMD-check](https://github.com/Gilead-BioStats/gsm.utils/actions/workflows/R-CMD-check-dev.yaml/badge.svg)](https://github.com/Gilead-BioStats/gsm.utils/actions/workflows/R-CMD-check-dev.yaml)

</div>

<!-- badges: end -->

Tools to make an `OpenRBQM` developer’s life easier including standard
GitHub actions, issue and pull request templates and utility functions.

## Installation

You can install the latest release of gsm.utils from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("Gilead-BioStats/gsm.utils@*release⁠")
```

<div class="pkgdown-devel">

You can install the development version of gsm.utils from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("Gilead-BioStats/gsm.utils")
```

</div>

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

- Creates package skeleton using `usethis::create_package()`
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
### `check_workflow_compliance()`

Checks if a package's GitHub Actions workflows comply with gsm.utils
templates:

``` r
check_workflow_compliance(strPackageDir = ".")
```

- Verifies that required workflow files are present
- Checks version headers match the current gsm.utils version
- Compares critical workflow content against templates
- Provides detailed reporting of compliance issues
- Can be used in CI/CD to enforce workflow standards
## GitHub Actions Workflows

The `inst/gha_templates/workflows` directory contains standardized
GitHub Actions workflow templates for Gilead packages:

- **`pkgdown-cleanup.yaml`**: Automatically removes pkgdown PR preview
  directories from the gh-pages branch when pull requests are closed to
  keep the repository clean.

- **`pkgdown-with-assets.yaml`**: Builds and deploys pkgdown documentation sites 
  with automatic menu addition and asset creation via 
  `gsm.utils::build_assets()`. Creates PR preview sites at `/pr/{number}` (or, 
  depending on your pkgdown configuration, `/pr/{number}/dev`), and deploys 
  production and/or `/dev` sites on push to `main` or `dev`.

- **`R-CMD-check-dev.yaml`**: Lightweight R package check for PRs to `dev` 
  branch, running on Ubuntu with current and minimum supported R versions for 
  faster CI feedback during development.

- **`R-CMD-check.yaml`**: Runs comprehensive R package checks on PRs to `main` 
  across multiple platforms (macOS, Windows, Ubuntu) and R versions to ensure 
  package integrity before release.

- **`r_releaser-caller.yaml`**: Reusable workflow for building and attaching R
  package source tarballs to GitHub releases, using the A2-ai/r-releaser action 
  with configurable options for data compression and vignette building.

- **`test-coverage.yaml`**: Computes test coverage using `covr` and logs the 
  result on every run. On pull requests, coverage is posted as a sticky comment 
  that updates on each push. `coverage-summary.json` (written via 
  `gsm.utils::emit_coverage_summary()`) is attached as a release asset when 
  triggered by a `release: published` event.

- **`workflow-template-check.yaml`**: Ensures workflow compliance by checking 
  that a package's `.github/workflows` directory matches the gsm.utils 
  templates. Runs on pushes to `main` or `release` branches and verifies 
  file presence, version headers, and critical content to maintain standardized 
  CI/CD across GSM packages.

## Code of Conduct

Please note that the gsm.utils project is released with a [Contributor
Code of
Conduct](https://gilead-biostats.github.io/gsm.utils/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
