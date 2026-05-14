# Construct a list of menu entries for rendered assets

Construct a list of menu entries for rendered assets

## Usage

``` r
construct_menu(rendered_assets, metadata, existing_menu = NULL)
```

## Arguments

- rendered_assets:

  (`character`) Paths to successfully rendered HTML files to add to
  pkgdown menu.

- existing_menu:

  List. Existing menu items from the pkgdown YAML contents, if any, to
  preserve when adding new menu items for rendered assets.

## Value

A list of lists with `text` and `href` entries for each rendered asset,
sorted by `index` and `title` metadata from the corresponding md file.
