# Add a Gilead GitHub Action to package

Add an official Gilead GitHub Action to a package, or update an existing
Gilead GitHub Action to the latest version if necessary. The source
location is determined by the manifest fields `repo`, `ref`, and
`path_extra`.

## Usage

``` r
add_action(
  name,
  version,
  repo,
  ref,
  ...,
  path_extra = NULL,
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

- repo:

  (`string`) GitHub repository in `owner/repo` form.

- ref:

  (`string`) Git ref (branch, tag, or SHA) in `repo`.

- ...:

  These dots are for future extensions and must be empty.

- path_extra:

  (`string` or `NULL`) Optional subdirectory within the ref where the
  workflow file lives.

- workflows_path:

  (`string`) Path to the package workflows.

- overwrite:

  (`boolean`) Overwrite existing files? Default is `TRUE`.

- verbose:

  (`boolean`) Inform about changes? Default is `TRUE`.

## Value

The name of the workflow if it was updated, otherwise an empty character
vector.
