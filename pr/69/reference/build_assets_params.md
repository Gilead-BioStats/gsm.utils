# Add rendered assets to pkgdown navbar menu

Add rendered assets to pkgdown navbar menu

Update pkgdown contents with menu

Ensure pkgdown menu section exists

Update pkgdown contents with menu entries for rendered assets

Remove menu from pkgdown YAML

Asset params

Construct a data frame of menu metadata from md files

Construct a data frame of menu metadata from a single md file

## Usage

``` r
add_pkgdown_nav(pkgdown_yml, menu_subdir, rendered_assets, verbose)

update_pkgdown_menu(
  pkgdown_contents,
  menu,
  menu_subdir,
  rendered_assets,
  verbose
)

ensure_pkgdown_menu_section(pkgdown_contents, menu)

add_assets_to_pkgdown_menu(
  pkgdown_contents,
  menu,
  menu_subdir,
  rendered_assets
)

remove_pkgdown_menu(pkgdown_contents, menu, verbose)

construct_menu_metadata_table(menu_subdir)

construct_md_metadata_table(md_file)
```

## Arguments

- pkgdown_yml:

  Character. Path to the `_pkgdown.yml` file to update with new menu
  items, or from which to remove unused menu items.

- menu_subdir:

  Character. Path to the subdirectory containing `.*md` files to render
  and add to pkgdown.

- rendered_assets:

  Character. Path to successfully rendered HTML files to add to pkgdown
  menu.

- verbose:

  Logical. Whether to print messages about rendered assets and menu
  updates.

- pkgdown_contents:

  List. The contents of `_pkgdown.yml`, as loaded by
  [`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html).

- menu:

  Character. Menu folder name.

- assets_dir:

  Character. Path to the directory where rendered `.html` files should
  be saved. Default is `"pkgdown/assets"`.

- output_file:

  Character. Path to output HTML file to create.

- params:

  List. Optional list of parameters to pass to
  [`quarto::quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.html).

- qmd_file:

  Character. Path to qmd file to render.

- root_dir:

  Character. Path to the root directory of the package, used to
  construct absolute paths. Default is `"."`.

- source_dir:

  Character. Path to the directory containing subdirectories with `.*md`
  files to render. Default is `"pkgdown/menus"`.

## Value

`NULL` (invisibly). Updates `_pkgdown.yml` in place.

An updated list of pkgdown YAML contents with the new menu entries
added.

An updated list of pkgdown YAML contents with the new menu added.

An updated list of pkgdown YAML contents with the new menu entries
added.

An updated list of pkgdown YAML contents with the menu removed.

A data.frame with columns `html_file`, `title`, and `index` for each md
file in the menu subdirectory.

A data.frame with columns `html_file`, `title`, and `index` for one md
file.
