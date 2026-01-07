# Summarize GitHub repository status for gsm packages

`summarize_github_repos()` retrieves release and milestone metadata for
a set of GitHub repositories and returns a data frame summarizing their
status.

## Usage

``` r
summarize_github_repos(repos, token = NULL)
```

## Arguments

- repos:

  Character vector of repositories in the form `owner/repo`.

- token:

  Optional GitHub personal access token. Defaults to the token
  discovered automatically by the gh package when `NULL`.

## Value

A data frame with columns `repo`, `latest_release`, and
`upcoming_milestones`.

## Examples

``` r
if (FALSE) { # \dontrun{
summarize_github_repos(c("Gilead-BioStats/gsm.utils"))
} # }
```
