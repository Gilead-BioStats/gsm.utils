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
