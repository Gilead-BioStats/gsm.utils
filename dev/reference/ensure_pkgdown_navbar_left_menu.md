# Ensure pkgdown navbar structure left element contains menu

Ensure pkgdown navbar structure left element contains menu

## Usage

``` r
ensure_pkgdown_navbar_left_menu(pkgdown_contents, menu)
```

## Arguments

- pkgdown_contents:

  List. The contents of `_pkgdown.yml`, as loaded by
  [`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html).

- menu:

  Character. Menu folder name.

## Value

An updated list of pkgdown YAML contents with the menu in
`navbar$structure$left`.
