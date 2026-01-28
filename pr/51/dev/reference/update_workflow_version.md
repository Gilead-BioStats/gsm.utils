# Update version in GitHub Actions workflow `.yaml` files

Update version in GitHub Actions workflow `.yaml` files

## Usage

``` r
update_workflow_version(
  dir = "inst/gha_templates/workflows",
  description_path = "DESCRIPTION",
  label = "# gsm.utils GHA version",
  recursive = TRUE,
  add_if_missing = TRUE
)
```

## Arguments

- dir:

  `string` path to directory containing GitHub Actions workflow `.yaml`
  files

- description_path:

  `string` path to `DESCRIPTION` file

- label:

  `string` label to identify version line in workflow files

- recursive:

  `boolean` whether to search directories recursively

- add_if_missing:

  `boolean` whether to add version line if missing
