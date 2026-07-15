# Build template content for an example

Build template content for an example

## Usage

``` r
.build_example_template(strName, strType, strDetails, intIndex)
```

## Arguments

- strName:

  (`string`) Display name of the example.

- strType:

  (`string`) Type of example, either `"Example"` or `"Cookbook"`.

- strDetails:

  (`string`) Optional description for the example.

- intIndex:

  (`numeric`) Sort-order index. `NULL`, `NA`, and length-0 vectors are
  treated as absent.

## Value

Character vector of template lines.
