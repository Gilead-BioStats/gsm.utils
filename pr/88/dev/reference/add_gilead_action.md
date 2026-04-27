# Add a Gilead GitHub Action to package

Add an official Gilead GitHub Action from
<https://github.com/Gilead-BioStats/gsm.utils@actions-v1> to a package,
or update an existing Gilead GitHub Actions to the latest version if
necessary.

## Usage

``` r
add_gilead_action(
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

  String. The action to install.

- version:

  String. The expected version of the action.

- ...:

  These dots are for future extensions and must be empty.

- workflows_path:

  String. Path to the package workflows.

- overwrite:

  Logical. Overwrite existing files?

- verbose:

  Logical. Inform about changes?

## Value

The name of the workflow if it was updated, otherwise an empty character
vector.
