# gsm.utils 0.4.0

This release standardizes actions and related functionality, and solidifies this package:

- We now use the `fs` package for file manipulation (#25).
- Actions have been standardized for gsm repos (#28, #31, #35, #40, #44, #45, #66, #67, #71, #73, #74, #75, #76, #77, #78, #90, #97, #106, #107, #114, #118).
- New function `build_assets()` (used in the shared `pkgdown-all.yaml` workflow) automatically adds rmarkdown and quarto files in `pkgdown/menus/*` to the pkgdown site, with a menu for each `*` subfolder. See `vignette("pkgdown-assets")` for details (#67, #89, #103, #108).
- `init_gsm_package()` and `update_gsm_package()` no longer install a "Requirement" issue template, and they remove Requirement issue templates from packages that already have them (#100).
- `init_gsm_package()` and `update_gsm_package()` shared underlying functionality to avoid surprises (#110).
- Unused experimental functionality has been removed (#111).

# gsm.utils v0.3.0

This update of the gsm.utils package introduces the following features:

- Adds three new exported functions (`render_examples`, `render_rmd`, `make_example`) for managing R Markdown example files
- Updates `add_pkgdown_examples` to read metadata from source Rmd files for proper ordering and titles
- Reorganizes GitHub Actions workflows by splitting r-releaser into reusable and caller components

# gsm.utils v0.2.0

This is a major update of the gsm.utils package. It introduces:

- A full suite of CI/CD pipelines.
- Improved templates and documentation for contributors.
- More robust utility functions for setting up and maintaining GSM ecosystem packages.

The changes focus heavily on package developer experience, contributor onboarding, workflow automation, and ensuring the package is well integrated into an organization-wide standard for building and maintaining GSM suite of packages.

## New features

* GitHub Actions workflows for example framework and building and attaching R package source tarballs to GitHub releases.
* Updated README.
* Initialized pkgdown website.
* Refactored utility functions for package and template management: `init_gsm_package()`, `update_gsm_package()`, `add_gsm_issue_templates()`, `add_gsm_actions()`, `add_contributor_guidelines()`, `add_pkgdown_examples()`.
* Added versioning system for GitHub Actions templates** (#36):
