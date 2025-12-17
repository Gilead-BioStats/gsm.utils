# Create GitHub Actions Manifest This function generates a JSON manifest file summarizing the GitHub Actions workflows

Create GitHub Actions Manifest This function generates a JSON manifest
file summarizing the GitHub Actions workflows

## Usage

``` r
create_gha_manifest(
  workflows_dir = "inst/gha_templates/workflows",
  issue_templates_dir = "inst/gha_templates/ISSUE_TEMPLATE",
  repository = "https://github.com/Gilead-BioStats/gsm.utils",
  description_path = "DESCRIPTION",
  output_path = "inst/gha_templates/gha_version.json"
)
```

## Arguments

- workflows_dir:

  `string` path to directory containing GitHub Actions workflow `.yaml`
  files

- issue_templates_dir:

  `string` path to directory containing GitHub issue template `.md`
  files

- repository:

  `string` URL of the GitHub repository

- description_path:

  `string` path to `DESCRIPTION` file

- output_path:

  `string` path to output JSON manifest file
