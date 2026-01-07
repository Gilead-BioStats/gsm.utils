# Infer value from YAML/MD file This helper function extracts a value from a YAML or Markdown file based on a specified type.

Infer value from YAML/MD file This helper function extracts a value from
a YAML or Markdown file based on a specified type.

## Usage

``` r
infer_from_yaml(path, type)
```

## Arguments

- path:

  `string` path to the file

- type:

  `string` type of value to extract, as appears in file (e.g., "name",
  "type", "# Description")

## Value

`string` extracted value or `NA_character_` if not found
