# Build additional pkgdown assets

Scan a directory for subdirectories, render any `.*md` files in those
subdirectories to `.html`, and add them to the pkgdown index.

## Usage

``` r
build_assets(
  source_dir = "pkgdown/menus",
  assets_dir = "pkgdown/assets",
  pkgdown_yml = "_pkgdown.yml",
  root_dir = ".",
  verbose = FALSE
)
```

## Arguments

- source_dir:

  (`string`) Path to the directory containing subdirectories with `.*md`
  files to render. Default is `"pkgdown/menus"`.

- assets_dir:

  (`string`) Path to the directory where rendered `.html` files should
  be saved. Default is `"pkgdown/assets"`.

- pkgdown_yml:

  (`string`) Path to the `_pkgdown.yml` file to update with new menu
  items, or from which to remove unused menu items.

- root_dir:

  (`string`) Path to the root directory of the package, used to
  construct absolute paths. Default is `"."`.

- verbose:

  (`boolean`) Inform about changes? Default is `TRUE`.

## Value

`NULL` (invisibly). Called for the side effect of setting up pkgdown
assets.
