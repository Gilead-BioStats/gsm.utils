# Adding Examples and Other Assets to a pkgdown Site

GSM packages frequently ship runnable example reports alongside their
pkgdown reference docs. `gsm.utils` standardizes that workflow: drop
`.Rmd` (or `.qmd`) files into a subdirectory of `pkgdown/menus/`, call
[`build_assets()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/build_assets.md),
and you get rendered HTML in `pkgdown/assets/` plus a matching menu in
the navbar of your pkgdown site.

This vignette walks through that workflow end to end using the
`examples` menu, then shows how the same machinery applies to other
asset types like slide decks.

## Mental model

Three locations stay in lockstep:

| Location | Role |
|----|----|
| `pkgdown/menus/<menu>/*.Rmd \| *.qmd` | Source files you author and commit |
| `pkgdown/assets/<menu>/*.html` | Rendered HTML (copied verbatim by pkgdown) |
| `_pkgdown.yml > navbar.components.<menu>` | Auto-generated navbar dropdown |

The subdirectory name under `pkgdown/menus/` is the menu name. A folder
called `examples/` becomes an “Examples” dropdown; a folder called
`slides/` becomes a “Slides” dropdown.
[`build_assets()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/build_assets.md)
discovers them automatically — no per-menu configuration required.

## Quick start

``` r

# 1. Scaffold a new example from a template.
gsm.utils::make_example(
  strName = "My First Example",
  strType = "Example",
  intIndex = 1
)

# 2. Render every example (and any other menu under pkgdown/menus/) and
#    update _pkgdown.yml in place.
gsm.utils::build_assets(verbose = TRUE)

# 3. Preview locally.
pkgdown::build_site()
```

After step 2 you should see:

- `pkgdown/menus/examples/Example_My_First_Example.Rmd` — your source
- `pkgdown/assets/examples/Example_My_First_Example.html` — rendered
- a new `navbar.components.examples` block in `_pkgdown.yml`

## Authoring an example

[`make_example()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/make_example.md)
writes a standard template to `pkgdown/menus/examples/` by default. The
template includes the YAML front matter that
[`build_assets()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/build_assets.md)
reads when constructing the menu:

``` yaml
---
title: "My First Example"
author: "[your.package] Example"
description: "<<Fill in Example description here>>"
index: 1
date: "May 13, 2026 09:49:52 UTC"
output: html_document
---
```

Two fields drive the menu:

- **`title`** — used as the menu label. If missing, the filename is
  title-cased instead (e.g. `example_hello_world.Rmd` →
  `"Example Hello World"`). HTML in the title is stripped, so titles
  authored for QMD slides still render cleanly in the navbar.
- **`index`** — numeric ordering key. Lower indices appear first; ties
  fall back to alphabetical title order. Missing or non-numeric values
  are treated as `Inf`, sending the entry to the end.

`strType` controls only the filename prefix (`Example_` vs `Cookbook_`).
Both end up in the same menu unless you split them across separate
subdirectories of `pkgdown/menus/`.

### Embedding a report

The default template includes a
[`knitr::knit_child()`](https://rdrr.io/pkg/knitr/man/knit_child.html)
stub for embedding a report Rmd that lives inside another GSM package:

``` r

child_env <- list2env(list(params = list()), parent = environment())
child_report <- knitr::knit_child(
  fs::path_package("your.package", "report", "Report_Name.Rmd"),
  envir = child_env,
  quiet = TRUE
)
cat(child_report, sep = "\n")
```

Replace `"your.package"` and `"Report_Name.Rmd"` with the package and
report you want to demonstrate. Setting `params` in `child_env` lets you
parameterize the embedded report without touching its source.

## What `build_assets()` does

[`build_assets()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/build_assets.md)
is a thin orchestrator:

1.  Walks every subdirectory of `source_dir` (default `pkgdown/menus/`).
2.  For each subdirectory, renders all `.Rmd` files via
    [`render_rmd()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/render_rmd.md)
    and all `.qmd` files via
    [`quarto::quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.html),
    writing the HTML to `pkgdown/assets/<menu>/`.
3.  Reads front-matter metadata from the source files to determine menu
    labels and order.
4.  Updates `_pkgdown.yml` in place: adds the menu component, inserts it
    into `navbar.structure.left`, and writes a sorted `menu:` list of
    `text` / `href` entries.
5.  Removes a menu entirely when its subdirectory contains no
    successfully rendered assets.

Existing menu items whose target HTML still exists on disk are preserved
across rebuilds, so you can hand-edit `_pkgdown.yml` to add curated
links (e.g. to externally hosted content) without losing them on the
next run.

Render failures are surfaced as
[`cli::cli_warn()`](https://cli.r-lib.org/reference/cli_abort.html)
messages of class `gsm.utils-render_failure`; the offending file is
skipped and the rest of the menu is built normally.

## Wiring up CI

The `pkgdown-all` workflow (in `inst/gha_templates/workflows/`) runs the
same pipeline on every push and pull request via the shared composite
action `gilead-biostats/gsm.utils/actions/pkgdown-deploy@actions-v1`. To
adopt it in a downstream package, run:

``` r

gsm.utils::update_gsm_package(".")
```

This drops the latest `pkgdown-all.yaml` into `.github/workflows/`. The
workflow:

- builds the site against the current branch,
- deploys production to `gh-pages` on push to `main` or `dev`,
- deploys a per-PR preview to `gh-pages/pr/<number>/` and comments the
  URL on the PR,
- cleans up the preview directory when the PR is closed.

No per-package configuration is required as long as your sources live in
`pkgdown/menus/` and your output target is `pkgdown/assets/`.

## Other assets (e.g. slide decks)

The “menu = subdirectory” convention is generic. To publish a deck of
Quarto slides next to your examples:

    pkgdown/
      menus/
        examples/
          Example_helloworld.Rmd
        slides/
          intro.qmd      # format: revealjs in the YAML
          deep-dive.qmd

Run
[`build_assets()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/build_assets.md)
and you get a “Slides” dropdown alongside “Examples”, with each `.qmd`
rendered to a self-contained HTML file (Quarto renders are forced to
`embed-resources: true` so no supporting assets need to be copied).

A couple of practical notes:

- Slide title labels can include inline HTML in the YAML `title:` field;
  [`build_assets()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/build_assets.md)
  strips tags before writing the navbar entry.
- For pre-rendered or third-party HTML you want to host without
  re-rendering, drop it directly into `pkgdown/assets/<menu>/` and add
  the entry manually to `_pkgdown.yml`. As long as the target file
  exists, subsequent
  [`build_assets()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/build_assets.md)
  runs will preserve it.
- Any subdirectory name works (`tutorials/`, `whitepapers/`, …). The
  menu label is derived by title-casing the directory name with acronyms
  preserved (`api_reference/` → “API Reference”).

## Troubleshooting

- **Menu didn’t appear.** Confirm that `pkgdown/assets/<menu>/` contains
  at least one non-`index.html` file after
  [`build_assets()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/build_assets.md)
  runs. An empty asset directory causes the menu to be removed from
  `_pkgdown.yml`.
- **Wrong title or order.** Check the YAML front matter of the source
  file. Missing `title` falls back to a title-cased filename; missing or
  non-numeric `index` sorts to the end.
- **Render failures in CI but not locally.** Render errors are warned,
  not thrown, so
  [`build_assets()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/build_assets.md)
  returns successfully even when individual files fail. Inspect the
  workflow logs for the `gsm.utils-render_failure` warnings.
- **Quarto path errors.**
  [`render_qmd_assets()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/render_qmd_assets.md)
  copies sources into a space-free temp directory before rendering to
  avoid Quarto’s long-standing issues with spaces in paths. If you see
  “file not found” errors referencing a path with spaces, upgrade to the
  current version of `gsm.utils`.

## See also

- [`?gsm.utils::make_example`](https://gilead-biostats.github.io/gsm.utils/dev/reference/make_example.md)
- [`?gsm.utils::build_assets`](https://gilead-biostats.github.io/gsm.utils/dev/reference/build_assets.md)
- [`?gsm.utils::render_rmd`](https://gilead-biostats.github.io/gsm.utils/dev/reference/render_rmd.md)
- `inst/gha_templates/workflows/pkgdown-all.yaml`
