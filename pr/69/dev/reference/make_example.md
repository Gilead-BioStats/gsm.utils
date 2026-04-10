# Create an example R Markdown template

Creates a new example `.Rmd` file from a standard template in
`inst/examples`.

## Usage

``` r
make_example(
  strName = "Example_Name",
  strType = c("Example", "Cookbook"),
  strDetails = "<<Fill in Example description here>>",
  intIndex = 999,
  output_dir = "inst/examples",
  overwrite = FALSE
)
```

## Arguments

- strName:

  Character. Display name of the example.

- strType:

  Character. Type of example, either `"Example"` or `"Cookbook"`.

- strDetails:

  Character. Optional description for the example.

- intIndex:

  Numeric. Optional ordering index for the examples menu.

- output_dir:

  Character. Directory to write the example to.

- overwrite:

  Logical. Whether to overwrite an existing file.

## Value

Path to the created example file (invisibly).
