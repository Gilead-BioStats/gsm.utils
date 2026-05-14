# Add a Gilead GitHub Action to package

Add an official Gilead GitHub Action from
<https://github.com/Gilead-BioStats/gsm.utils@actions-v1> to a package,
or update an existing Gilead GitHub Actions to the latest version if
necessary.

## Usage

``` r
add_action(
  name,
  version,
  ...,
  workflows_path = "./.github/workflows",
  overwrite = TRUE,
  verbose = TRUE
)
```

## Arguments

- name:

  (`string`) The action to install.

- version:

  (`string`) The expected version of the action.

- ...:

  These dots are for future extensions and must be empty.

- workflows_path:

  (`string`) Path to the package workflows.

- overwrite:

  (`boolean`) Overwrite existing files? Default is `TRUE`.

- verbose:

  (`boolean`) Inform about changes? Default is `TRUE`.

## Value

The name of the workflow if it was updated, otherwise an empty character
vector.
