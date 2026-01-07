# List public gsm packages for reporting

Retrieves public repositories from a GitHub organization that start with
the `gsm.` prefix and returns fully qualified repository identifiers
that can be passed to
[`summarize_github_repos()`](https://gilead-biostats.github.io/gsm.utils/dev/reference/summarize_github_repos.md).

## Usage

``` r
list_public_gsm_packages(
  org = "Gilead-BioStats",
  prefix = "gsm.",
  token = NULL
)
```

## Arguments

- org:

  Character scalar. GitHub organization to query. Defaults to
  "Gilead-BioStats".

- prefix:

  Character scalar used to match repository names. Defaults to "gsm.".

- token:

  Optional GitHub personal access token. Defaults to automatic discovery
  when `NULL`.

## Value

Character vector of repositories in `owner/repo` format, sorted
alphabetically. Returns an empty vector if no repositories are found.

## Examples

``` r
if (FALSE) { # \dontrun{
list_public_gsm_packages()
} # }
```
