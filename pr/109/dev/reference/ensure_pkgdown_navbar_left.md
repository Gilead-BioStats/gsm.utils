# Ensure pkgdown navbar structure left element exists

Ensure pkgdown navbar structure left element exists

## Usage

``` r
ensure_pkgdown_navbar_left(pkgdown_contents)
```

## Arguments

- pkgdown_contents:

  List. The contents of `_pkgdown.yml`, as loaded by
  [`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html).

## Value

An updated list of pkgdown YAML contents with `structure$left` in the
navbar.
