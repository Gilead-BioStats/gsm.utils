# Ensure pkgdown components element exists

Ensure pkgdown components element exists

## Usage

``` r
ensure_pkgdown_components(pkgdown_contents)
```

## Arguments

- pkgdown_contents:

  List. The contents of `_pkgdown.yml`, as loaded by
  [`yaml::read_yaml()`](https://yaml.r-lib.org/reference/read_yaml.html).

## Value

An updated list of pkgdown YAML contents with components in the navbar.
