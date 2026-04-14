# Asset params

Asset params

## Arguments

- assets_dir:

  Character. Path to the directory where rendered `.html` files should
  be saved. Default is `"pkgdown/assets"`.

- menu:

  Character. Menu folder name.

- menu_subdir:

  Character. Path to the subdirectory containing `.*md` files to render
  and add to pkgdown.

- output_dir:

  Character. Directory to write the example to.

- output_file:

  Character. Path to output HTML file to create.

- params:

  List. Optional list of parameters to pass to
  [`quarto::quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.html).

- pkgdown_contents:

  List. The contents of `_pkgdown.yml`, as loaded by
  [`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html).

- pkgdown_yml:

  Character. Path to the `_pkgdown.yml` file to update with new menu
  items, or from which to remove unused menu items.

- qmd_file:

  Character. Path to qmd file to render.

- rendered_assets:

  Character. Path to successfully rendered HTML files to add to pkgdown
  menu.

- root_dir:

  Character. Path to the root directory of the package, used to
  construct absolute paths. Default is `"."`.

- source_dir:

  Character. Path to the directory containing subdirectories with `.*md`
  files to render. Default is `"pkgdown/menus"`.

- verbose:

  Logical. Whether to print messages about rendered assets and menu
  updates.
