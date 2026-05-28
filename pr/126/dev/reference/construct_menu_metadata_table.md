# Construct a data frame of menu metadata from md files

Construct a data frame of menu metadata from md files

## Usage

``` r
construct_menu_metadata_table(menu_subdir)
```

## Arguments

- menu_subdir:

  (`string`) Path to the subdirectory containing `.*md` files to render
  and add to pkgdown.

## Value

A data.frame with columns `html_file`, `title`, and `index` for each md
file in the menu subdirectory.
