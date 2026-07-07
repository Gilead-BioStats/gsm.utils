# Changelog

## gsm.utils 0.4.0

This release standardizes actions and related functionality, and
solidifies this package:

- We now use the `fs` package for file manipulation
  ([\#25](https://github.com/Gilead-BioStats/gsm.utils/issues/25)).
- Actions have been standardized for gsm repos
  ([\#28](https://github.com/Gilead-BioStats/gsm.utils/issues/28),
  [\#31](https://github.com/Gilead-BioStats/gsm.utils/issues/31),
  [\#35](https://github.com/Gilead-BioStats/gsm.utils/issues/35),
  [\#40](https://github.com/Gilead-BioStats/gsm.utils/issues/40),
  [\#44](https://github.com/Gilead-BioStats/gsm.utils/issues/44),
  [\#45](https://github.com/Gilead-BioStats/gsm.utils/issues/45),
  [\#66](https://github.com/Gilead-BioStats/gsm.utils/issues/66),
  [\#67](https://github.com/Gilead-BioStats/gsm.utils/issues/67),
  [\#71](https://github.com/Gilead-BioStats/gsm.utils/issues/71),
  [\#73](https://github.com/Gilead-BioStats/gsm.utils/issues/73),
  [\#74](https://github.com/Gilead-BioStats/gsm.utils/issues/74),
  [\#75](https://github.com/Gilead-BioStats/gsm.utils/issues/75),
  [\#76](https://github.com/Gilead-BioStats/gsm.utils/issues/76),
  [\#77](https://github.com/Gilead-BioStats/gsm.utils/issues/77),
  [\#78](https://github.com/Gilead-BioStats/gsm.utils/issues/78),
  [\#90](https://github.com/Gilead-BioStats/gsm.utils/issues/90),
  [\#97](https://github.com/Gilead-BioStats/gsm.utils/issues/97),
  [\#106](https://github.com/Gilead-BioStats/gsm.utils/issues/106),
  [\#107](https://github.com/Gilead-BioStats/gsm.utils/issues/107),
  [\#114](https://github.com/Gilead-BioStats/gsm.utils/issues/114),
  [\#118](https://github.com/Gilead-BioStats/gsm.utils/issues/118)).
- New function
  [`build_assets()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/build_assets.md)
  (used in the shared `pkgdown-all.yaml` workflow) automatically adds
  rmarkdown and quarto files in `pkgdown/menus/*` to the pkgdown site,
  with a menu for each `*` subfolder. See
  [`vignette("pkgdown-assets")`](https://gilead-biostats.github.io/gsm.utils/dev/articles/pkgdown-assets.md)
  for details
  ([\#67](https://github.com/Gilead-BioStats/gsm.utils/issues/67),
  [\#89](https://github.com/Gilead-BioStats/gsm.utils/issues/89),
  [\#103](https://github.com/Gilead-BioStats/gsm.utils/issues/103),
  [\#108](https://github.com/Gilead-BioStats/gsm.utils/issues/108)).
- [`init_gsm_package()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/init_gsm_package.md)
  and
  [`update_gsm_package()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/update_gsm_package.md)
  no longer install a “Requirement” issue template, and they remove
  Requirement issue templates from packages that already have them
  ([\#100](https://github.com/Gilead-BioStats/gsm.utils/issues/100)).
- [`init_gsm_package()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/init_gsm_package.md)
  and
  [`update_gsm_package()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/update_gsm_package.md)
  shared underlying functionality to avoid surprises
  ([\#110](https://github.com/Gilead-BioStats/gsm.utils/issues/110)).
- Unused experimental functionality has been removed
  ([\#111](https://github.com/Gilead-BioStats/gsm.utils/issues/111)).

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
  `add_gsm_actions()`,
  [`add_contributor_guidelines()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/add_contributor_guidelines.md),
  `add_pkgdown_examples()`.
- Added versioning system for GitHub Actions templates\*\*
  ([\#36](https://github.com/Gilead-BioStats/gsm.utils/issues/36)):
