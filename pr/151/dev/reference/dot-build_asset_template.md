# Build a generic asset template

Build a generic asset template

## Usage

``` r
.build_asset_template(
  strTitle,
  intIndex,
  lHeaders = list(),
  chrBody = character()
)
```

## Arguments

- strTitle:

  (`string`) Display title.

- intIndex:

  (`numeric`) Sort-order index. `NULL`, `NA`, and length-0 vectors are
  treated as absent.

- lHeaders:

  (`list`) Additional YAML header fields as a named list. Requires the
  yaml package when non-empty.

- chrBody:

  (`character`) Lines of content after the front matter.

## Value

Character vector of template lines.
