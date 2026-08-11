# Turn a string into a regex pattern to match pieces of that string

Turn a string into a regex pattern to match pieces of that string

## Usage

``` r
extract_pattern(x)
```

## Arguments

- x:

  A string in "camelCase", "snake_case", "kebab-case", "Title Case",
  "Sentence case", or "lowercase" format. Strings of capital letters
  within the string (e.g. "API" in "TheAPIClient") will be treated a
  group.

## Value

A regex pattern to match pieces of the input string, ignoring separators
and case.
