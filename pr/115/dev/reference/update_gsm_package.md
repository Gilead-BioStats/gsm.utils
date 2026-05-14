# Update GSM package with global issue templates and GH actions

Add standard GSM issue templates
([`add_gsm_issue_templates()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/add_gsm_issue_templates.md))
and actions
([`add_actions()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/add_actions.md)),
and remove deprecated versions of each
([`remove_deprecated_issue_templates()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/remove_deprecated_issue_templates.md)
and
[`remove_deprecated_actions()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/remove_deprecated_actions.md).

## Usage

``` r
update_gsm_package(strPackageDir = ".", overwrite = TRUE, verbose = TRUE)
```

## Arguments

- strPackageDir:

  (`string`) Path to the package directory.

- overwrite:

  (`boolean`) Overwrite existing files? Default is `TRUE`.

- verbose:

  (`boolean`) Inform about changes? Default is `TRUE`.
