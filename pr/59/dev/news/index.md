# Changelog

## gsm.utils v0.3.0

This update of the gsm.utils package introduces the following features:

- Adds three new exported functions (`render_examples`, `render_rmd`,
  `make_example`) for managing R Markdown example files
- Updates `add_pkgdown_examples` to read metadata from source Rmd files
  for proper ordering and titles
- Reorganizes GitHub Actions workflows by splitting r-releaser into
  reusable and caller components

## gsm.utils v0.2.0

This is a major update of the gsm.utils package. It introduces:

- A full suite of CI/CD pipelines.
- Improved templates and documentation for contributors.
- More robust utility functions for setting up and maintaining GSM
  ecosystem packages.

The changes focus heavily on package developer experience, contributor
onboarding, workflow automation, and ensuring the package is well
integrated into an organization-wide standard for building and
maintaining GSM suite of packages.

### New features

- GitHub Actions workflows for example framework and building and
  attaching R package source tarballs to GitHub releases.
- Updated README.
- Initialized pkgdown website.
- Refactored utility functions for package and template management:
  [`init_gsm_package()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/init_gsm_package.md),
  [`update_gsm_package()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/update_gsm_package.md),
  [`add_gsm_issue_templates()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/add_gsm_issue_templates.md),
  [`add_gsm_actions()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/add_gsm_actions.md),
  [`add_contributor_guidelines()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/add_contributor_guidelines.md),
  [`add_pkgdown_examples()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/add_pkgdown_examples.md).
- Added versioning system for GitHub Actions templates\*\*
  ([\#36](https://github.com/Gilead-BioStats/gsm.utils/issues/36)):
