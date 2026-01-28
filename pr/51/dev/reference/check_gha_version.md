# Check GitHub Actions version in a package

Checks the version of GitHub Actions (GHA) workflows installed in a
package against the version available in gsm.utils. This helps identify
if workflows need to be updated.

## Usage

``` r
check_gha_version(strPackageDir = ".", bVerbose = TRUE)
```

## Arguments

- strPackageDir:

  `character` path to package directory. Default is `"."`.

- bVerbose:

  `logical` whether to print detailed information. Default is `TRUE`.

## Value

A list with the following components:

- package_version:

  Version found in the package workflows (or NA)

- gsm_utils_version:

  Current version available in gsm.utils

- is_current:

  Logical indicating if package version matches gsm.utils version

- workflows_found:

  Character vector of workflow files found

- workflows_missing:

  Character vector of workflow files missing from package

## Examples

``` r
if (FALSE) { # \dontrun{
# Check current package
check_gha_version()

# Check another package
check_gha_version("path/to/package")
} # }
```
