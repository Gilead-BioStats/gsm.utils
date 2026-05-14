# gsm.utils

<!-- badges: start -->

<div class="pkgdown-release">

[![R-CMD-check](https://github.com/Gilead-BioStats/gsm.utils/actions/workflows/R-CMD-check.yaml/badge.svg?branch=main)](https://github.com/Gilead-BioStats/gsm.utils/actions/workflows/R-CMD-check.yaml)
[![test-coverage](https://github.com/Gilead-BioStats/gsm.utils/actions/workflows/test-coverage.yaml/badge.svg?branch=main)](https://github.com/Gilead-BioStats/gsm.utils/actions/workflows/test-coverage.yaml)
[![pkgdown-all](https://github.com/Gilead-BioStats/gsm.utils/actions/workflows/pkgdown-all.yaml/badge.svg?branch=main)](https://github.com/Gilead-BioStats/gsm.utils/actions/workflows/pkgdown-all.yaml)

</div>

<div class="pkgdown-devel">

[![R-CMD-check](https://github.com/Gilead-BioStats/gsm.utils/actions/workflows/R-CMD-check.yaml/badge.svg?branch=dev)](https://github.com/Gilead-BioStats/gsm.utils/actions/workflows/R-CMD-check.yaml)
[![test-coverage](https://github.com/Gilead-BioStats/gsm.utils/actions/workflows/test-coverage.yaml/badge.svg?branch=dev)](https://github.com/Gilead-BioStats/gsm.utils/actions/workflows/test-coverage.yaml)
[![pkgdown-all](https://github.com/Gilead-BioStats/gsm.utils/actions/workflows/pkgdown-all.yaml/badge.svg?branch=dev)](https://github.com/Gilead-BioStats/gsm.utils/actions/workflows/pkgdown-all.yaml)

</div>

<!-- badges: end -->

Tools to make an `OpenRBQM` developer's life easier including standard GitHub actions, issue and pull request templates, and utility functions.

## Installation

You can install the latest release of gsm.utils from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("Gilead-BioStats/gsm.utils@*release")
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

The package provides two main functions to streamline package development:

### `init_gsm_package()`

Initializes a new extension package with standardized structure and configuration:

``` r
init_gsm_package(
  strPackageDir = "path/to/new/package",
  lDescriptionFields = list(),
  bIncludeWorkflowDir = TRUE,
  strOrg = "Gilead-BioStats"
)
```

- Creates package skeleton using `usethis::create_package()`
- Sets up pkgdown documentation with GitHub Pages
- Configures testthat for unit testing
- Calls `update_gsm_package()` to update issue templates and GitHub Actions workflows

### `update_gsm_package()`

Updates an existing GSM package with the latest standardized templates:

``` r
update_gsm_package(strPackageDir = ".")
```

- Installs/updates GitHub issue templates with `add_gsm_issue_templates()`
- Removes deprecated issue templates with `remove_deprecated_issue_templates()`
- Installs/updates GitHub Actions workflows from the [`actions-v1` branch of this repo](https://github.com/Gilead-BioStats/gsm.utils/tree/actions-v1/workflow_templates) with `add_actions()`
- Removes deprecated issue templates with `remove_deprecated_actions()`

## GitHub Actions Workflows

The [`actions-v1` branch of this repo](https://github.com/Gilead-BioStats/gsm.utils/tree/actions-v1/workflow_templates) contains standardized GitHub Actions workflow templates for Gilead packages:

- **`R-CMD-check.yaml`**: Runs R package checks on PRs to ensure package integrity.

- **`pkgdown-all.yaml`**: Builds and deploys pkgdown documentation sites with automatic menu addition and asset creation via `gsm.utils::build_assets()`.
  Creates PR preview sites at `/pr/{number}` (or, depending on your pkgdown configuration, `/pr/{number}/dev`) and deletes such sites once the PR is closed, and deploys production and/or `/dev` sites on push to `main` or `dev`.

- **`r_releaser-caller.yaml`**: Reusable workflow for building and attaching R package source tarballs to GitHub releases, using the A2-ai/r-releaser action with configurable options for data compression and vignette building.

- **`test-coverage.yaml`**: Computes test coverage using `covr` and logs the result on every run.
  On pull requests, coverage is posted as a sticky comment that updates on each push. `coverage-summary.json` (written via `gsm.utils::emit_coverage_summary()`) is attached as a release asset when triggered by a `release: published` event.

- **`workflow-template-check.yaml`**: Ensures workflow compliance by checking that a package's `.github/workflows` directory matches these templates.
  Runs on pull requests and verifies file presence and version headers to maintain standardized CI/CD across GSM packages.

## Code of Conduct

Please note that the gsm.utils project is released with a [Contributor Code of Conduct](https://gilead-biostats.github.io/gsm.utils/CODE_OF_CONDUCT.html). 
By contributing to this project, you agree to abide by its terms.
