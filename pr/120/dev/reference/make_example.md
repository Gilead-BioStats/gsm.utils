# Create an example R Markdown template

Creates a new example `.Rmd` file from a standard template.

## Usage

``` r
make_example(
  strName = "Example_Name",
  strType = c("Example", "Cookbook"),
  strDetails = "<<Fill in Example description here>>",
  intIndex = 999,
  output_dir = "pkgdown/menus/examples",
  overwrite = FALSE
)
```

## Arguments

- strName:

  (`string`) Display name of the example.

- strType:

  (`string`) Type of example, either `"Example"` or `"Cookbook"`.

- strDetails:

  (`string`) Optional description for the example.

- intIndex:

  (`numeric`) Optional ordering index for the examples menu.

- output_dir:

  (`string`) Directory to write the example to.

- overwrite:

  (`boolean`) Overwrite existing files? Default is `TRUE`.

## Value

Path to the created example file (invisibly).
