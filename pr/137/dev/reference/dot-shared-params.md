# Shared parameters

These parameters are used in multiple functions. They are defined here
to make them easier to import and to find.

## Arguments

- assets_dir:

  (`string`) Path to the directory where rendered `.html` files should
  be saved. Default is `"pkgdown/assets"`.

- existing_menu:

  List. Existing menu items from the pkgdown YAML contents, if any, to
  preserve when adding new menu items for rendered assets.

- intIndex:

  (`numeric`) Sort-order index. `NULL`, `NA`, and length-0 vectors are
  treated as absent.

- menu:

  (`string`) Menu folder name.

- menu_subdir:

  (`string`) Path to the subdirectory containing `.*md` files to render
  and add to pkgdown.

- output_dir:

  (`string`) Directory to write the asset to.

- output_file:

  (`string`) Path to output HTML file to create.

- overwrite:

  (`boolean`) Overwrite existing files?

- params:

  List. Optional list of parameters to pass to
  [`quarto::quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.html).

- pkgdown_contents:

  List. The contents of `_pkgdown.yml`, as loaded by
  [`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html).

- pkgdown_yml:

  (`string`) Path to the `_pkgdown.yml` file to update with new menu
  items, or from which to remove unused menu items.

- qmd_file:

  (`string`) Path to qmd file to render.

- rendered_assets:

  (`character`) Paths to successfully rendered HTML files to add to
  pkgdown menu.

- root_dir:

  (`string`) Path to the root directory of the package, used to
  construct absolute paths. Default is `"."`.

- source_dir:

  (`string`) Path to the directory containing subdirectories with `.*md`
  files to render. Default is `"pkgdown/menus"`.

- strPackageDir:

  (`string`) Path to the package directory.

- strTitle:

  (`string`) Display title.

- verbose:

  (`boolean`) Inform about changes? Default is `TRUE`.
