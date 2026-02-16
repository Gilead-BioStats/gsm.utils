---
name: gsm-release-prep
description: Prepares GSM R packages for release following the contributor guidelines at gilead-biostats.github.io/gsm.core/CONTRIBUTING.html. Use when preparing any GSM package (gsm.core, gsm.mapping, gsm.kri, etc.) for release by creating release branches, updating documentation, running quality checks, and preparing release PRs. Handles both regular and quarterly releases including proper dependency ordering.
license: Complete terms in LICENSE.txt
---

# GSM Package Release Preparation

## Overview

This skill automates the preparation of GSM R packages for release according to the established contributor guidelines. It handles version management, documentation updates, quality checks, and PR preparation for both regular and quarterly releases.

## Release Workflow

### Step 1: Create Release Branch
Create a `release-x.y.z` branch from `dev` using semantic versioning:

```bash
git checkout dev
git pull origin dev  
git checkout -b release-x.y.z
```

### Step 2: Update Version and Documentation

**Version Management:**
- Update version number in `DESCRIPTION` file following semantic versioning
- Update `NEWS.md` with comprehensive release notes
- Include all changes, bug fixes, and new features

**Documentation Requirements:**
- Ensure all functions have complete roxygen2 documentation:
  - `@param` for all parameters
  - `@return` for return values
  - `@export` where appropriate
  - Working examples that run successfully
- Update README.md if significant changes made
- Update any affected vignettes

### Step 3: Apply Code Style Standards

Apply GSM code style using the custom styler configuration:

```r
double_indent_style <- styler::tidyverse_style()
double_indent_style$indention$unindent_fun_dec <- NULL
double_indent_style$indention$update_indention_ref_fun_dec <- NULL
double_indent_style$line_break$remove_line_breaks_in_fun_dec <- NULL
styler::style_dir("R", transformers = double_indent_style)
styler::style_dir("tests", recursive = TRUE, transformers = double_indent_style)
```

### Step 4: Run Quality Checks

Execute comprehensive validation:

```r
# Essential checks - all must pass
devtools::check()               # No errors, warnings, or notes
devtools::test()               # All unit tests pass  
pkgdown::build_site()          # Documentation site builds
devtools::spell_check()        # No spelling errors
devtools::install()            # Package installs cleanly
```

**Additional Validations:**
- Verify test coverage is adequate
- Run qualification tests if required
- Test package in clean R environment
- Validate all dependencies are properly declared

**DESCRIPTION File Checks:**
- Update dependency versions to align with release plan
- Verify all imports are declared
- Ensure suggests packages are appropriate
- Validate file format and completeness

### Step 5: Prepare Release PR

**Commit and Push:**
```bash
git add .
git commit -m "Prepare release v x.y.z"
git push origin release-x.y.z
```

**Create Pull Request:**
- Open PR from `release-x.y.z` to `main`
- Use release PR template
- Assign yourself
- Request QC reviewer
- Link to milestone/issues in GSM Roadmap project board
- Include comprehensive release notes