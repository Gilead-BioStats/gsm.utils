# Update pkgdown contents with menu

Update pkgdown contents with menu

## Usage

``` r
update_pkgdown_menu(
  pkgdown_contents,
  menu,
  menu_subdir,
  rendered_assets,
  existing_menu,
  verbose
)
```

## Arguments

- pkgdown_contents:

  List. The contents of `_pkgdown.yml`, as loaded by
  [`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html).

- menu:

  (`string`) Menu folder name.

- menu_subdir:

  (`string`) Path to the subdirectory containing `.*md` files to render
  and add to pkgdown.

- rendered_assets:

  (`character`) Paths to successfully rendered HTML files to add to
  pkgdown menu.

- existing_menu:

  List. Existing menu items from the pkgdown YAML contents, if any, to
  preserve when adding new menu items for rendered assets.

- verbose:

  (`boolean`) Inform about changes? Default is `TRUE`.

## Value

An updated list of pkgdown YAML contents with the new menu entries
added.
