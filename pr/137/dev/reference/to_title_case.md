# Convert a string to title case, preserving acronyms

Convert a string to title case, preserving acronyms

## Usage

``` r
to_title_case(x)
```

## Arguments

- x:

  A string in "camelCase", "snake_case", "kebab-case", "Title Case",
  "Sentence case", or "lowercase" format. Strings of capital letters
  within the string (e.g. "API" in "TheAPIClient") will be treated a
  group.

## Value

The string in Title Case, with separators removed and acronyms
preserved. For example, "theAPIClient" and "the_API_client" both become
"The API Client".
