# Ensure pkgdown menu section exists

Ensure pkgdown menu section exists

## Usage

``` r
ensure_pkgdown_menu_section(pkgdown_contents, menu)
```

## Arguments

- pkgdown_contents:

  List. The contents of `_pkgdown.yml`, as loaded by
  [`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html).

- menu:

  Character. Menu folder name.

## Value

An updated list of pkgdown YAML contents with the new menu added.
