#' Summarize GitHub repository status for gsm packages
#'
#' `summarize_github_repos()` retrieves release and milestone metadata for a
#' set of GitHub repositories and returns a data frame summarizing their status.
#' @param repos Character vector of repositories in the form `owner/repo`.
#' @param token Optional GitHub personal access token. Defaults to the token
#'   discovered automatically by the gh package when `NULL`.
#'
#' @return A data frame with columns `repo`, `latest_release`, and
#'   `upcoming_milestones`.
#' @examples
#' \dontrun{
#' summarize_github_repos(c("Gilead-BioStats/gsm.utils"))
#' }
#' @export
#' @importFrom gh gh
#' @importFrom htmltools htmlEscape
summarize_github_repos <- function(repos, token = NULL) {
  validate_repo_vector(repos)

  results <- vector("list", length(repos))

  for (idx in seq_along(repos)) {
    owner_repo <- repos[[idx]]
    pieces <- strsplit(owner_repo, "/", fixed = TRUE)[[1]]
    owner <- pieces[[1]]
    repo <- pieces[[2]]

    release <- fetch_latest_release(owner, repo, token)
    milestones <- fetch_open_milestones(owner, repo, token)

    results[[idx]] <- list(
      repo = paste0(owner, "/", repo),
      latest_release = format_release_summary(release),
      upcoming_milestones = format_milestone_summary(milestones)
    )
  }

  data.frame(
    repo = vapply(results, `[[`, character(1), "repo"),
    latest_release = vapply(results, `[[`, character(1), "latest_release"),
    upcoming_milestones = vapply(results, `[[`, character(1), "upcoming_milestones"),
    stringsAsFactors = FALSE
  )
}

validate_repo_vector <- function(repos) {
  if (!is.character(repos)) {
    rlang::abort("`repos` must be a character vector.")
  }
  if (!length(repos)) {
    rlang::abort("`repos` must contain at least one repository identifier.")
  }
  if (any(!nzchar(repos))) {
    rlang::abort("`repos` cannot contain empty strings.")
  }
  invalid <- !grepl("^[^/]+/[^/]+$", repos)
  if (any(invalid)) {
    rlang::abort(
      paste0(
        "All entries in `repos` must follow the 'owner/repo' format. Invalid: ",
        paste(repos[invalid], collapse = ", ")
      )
    )
  }
  invisible(repos)
}

fetch_latest_release <- function(owner, repo, token) {
  safe_gh(
    gh::gh,
    "GET /repos/{owner}/{repo}/releases/latest",
    owner = owner,
    repo = repo,
    .token = token
  )
}

fetch_open_milestones <- function(owner, repo, token) {
  safe_gh(
    gh::gh,
    "GET /repos/{owner}/{repo}/milestones",
    owner = owner,
    repo = repo,
    state = "open",
    per_page = 100,
    .token = token
  )
}

safe_gh <- function(fun, ...) {
  tryCatch(
    fun(...),
    error = function(err) {
      is_404 <- inherits(err, "http_error_404") ||
        (inherits(err, c("gh_error", "github_error")) && has_status_code(err, 404))

      if (is_404) {
        return(NULL)
      }
      stop(err)
    }
  )
}

has_status_code <- function(err, code) {
  status <- tryCatch(err$response$status, error = function(...) NULL)
  if (is.null(status)) {
    status <- tryCatch(err$response_content$status, error = function(...) NULL)
  }
  if (is.null(status)) {
    status <- tryCatch(err$status, error = function(...) NULL)
  }

  if (is.character(status)) {
    status <- suppressWarnings(as.integer(status))
  }

  identical(status, code)
}

format_release_summary <- function(release) {
  if (is.null(release)) {
    return(tailwind_label(
      "No release",
      title = "No published release found",
      variant = "slate"
    ))
  }

  tag <- first_non_empty(release$tag_name, release$name, "Unnamed release")
  date <- release$published_at

  if (!is.null(date) && nzchar(date)) {
    pretty <- substr(date, 1L, 10L)
    return(tailwind_label(
      tag,
      title = paste0("Released ", pretty),
      variant = "sky"
    ))
  }

  tailwind_label(tag, title = "Release date unavailable", variant = "sky")
}

format_milestone_summary <- function(milestones) {
  if (is.null(milestones) || !length(milestones)) {
    return(tailwind_label("None", title = "No open milestones", variant = "slate"))
  }

  entries <- vapply(
    milestones,
    format_single_milestone,
    character(1),
    USE.NAMES = FALSE
  )
  entries <- entries[nzchar(entries)]

  if (!length(entries)) {
    return(tailwind_label("None", title = "No open milestones", variant = "slate"))
  }

  paste(entries, collapse = " ")
}

format_single_milestone <- function(milestone) {
  open_count <- sanitize_issue_count(milestone$open_issues)
  closed_count <- sanitize_issue_count(milestone$closed_issues)
  total <- open_count + closed_count

  if (!is.finite(total) || total == 0) {
    return("")
  }

  title <- first_non_empty(milestone$title, "Unnamed milestone")
  completion <- closed_count / total

  grayscale_milestone_label(
    title,
    tooltip = sprintf("%s: %s open of %s", title, open_count, total),
    completion = completion
  )
}

first_non_empty <- function(...) {
  for (candidate in list(...)) {
    if (!is.null(candidate) && nzchar(candidate)) {
      return(candidate)
    }
  }
  NULL
}

`%||%` <- function(lhs, rhs) {
  if (is.null(lhs)) rhs else lhs
}

tailwind_label <- function(text, title, variant = c("sky", "emerald", "slate")) {
  variant <- match.arg(variant)
  if (variant == "sky") {
    return(sprintf(
      '<span class="inline-flex items-center rounded-md px-2 py-1 text-xs font-medium" title="%s" style="background:%s;color:%s;border:1px solid %s;">%s</span>',
      htmltools::htmlEscape(title),
      "#38bdf8",
      "#0b1120",
      "rgba(8,47,73,0.2)",
      htmltools::htmlEscape(text)
    ))
  }

  palette <- list(
    emerald = list(bg = "bg-emerald-100", text = "text-emerald-700"),
    slate = list(bg = "bg-slate-100", text = "text-slate-700")
  )
  colors <- palette[[variant]]

  sprintf(
    '<span class="inline-flex items-center rounded-md %s px-2 py-1 text-xs font-medium %s" title="%s">%s</span>',
    colors$bg,
    colors$text,
    htmltools::htmlEscape(title),
    htmltools::htmlEscape(text)
  )
}

grayscale_milestone_label <- function(text, tooltip, completion) {
  completion <- if (is.finite(completion)) max(0, min(1, completion)) else 0
  fill_color <- "#38bdf8"   # Tailwind sky-400
  remainder_color <- "#e0f2fe"  # Tailwind sky-100
  text_color <- "#0c4a6e"   # Tailwind sky-800
  border <- "rgba(12,74,110,0.25)"
  fill_percent <- round(completion * 100, 1)
  meter_background <- sprintf(
    "linear-gradient(90deg, %1$s 0%%, %1$s %2$.1f%%, %3$s %2$.1f%%, %3$s 100%%)",
    fill_color,
    fill_percent,
    remainder_color
  )

  sprintf(
    '<span class="inline-flex items-center rounded-md px-2 py-1 text-xs font-medium" title="%s" style="background:%s;color:%s;border:1px solid %s;">%s</span>',
    htmltools::htmlEscape(tooltip),
    meter_background,
    text_color,
    border,
    htmltools::htmlEscape(text)
  )
}

sanitize_issue_count <- function(x) {
  if (is.null(x)) {
    return(0)
  }
  if (length(x) == 0) {
    return(0)
  }
  if (is.na(x)) {
    return(0)
  }
  value <- suppressWarnings(as.numeric(x))
  if (is.na(value) || !is.finite(value)) {
    return(0)
  }
  value
}

#' List public gsm packages for reporting
#'
#' Retrieves public repositories from a GitHub organization that start with the
#' `gsm.` prefix and returns fully qualified repository identifiers that can be
#' passed to [summarize_github_repos()].
#'
#' @param org Character scalar. GitHub organization to query. Defaults to
#'   "Gilead-BioStats".
#' @param prefix Character scalar used to match repository names. Defaults to
#'   "gsm.".
#' @param token Optional GitHub personal access token. Defaults to automatic
#'   discovery when `NULL`.
#'
#' @return Character vector of repositories in `owner/repo` format, sorted
#'   alphabetically. Returns an empty vector if no repositories are found.
#' @examples
#' \dontrun{
#' list_public_gsm_packages()
#' }
#' @export
list_public_gsm_packages <- function(org = "Gilead-BioStats", prefix = "gsm.", token = NULL) {
  if (!is.character(org) || length(org) != 1L || !nzchar(org)) {
    rlang::abort("`org` must be a non-empty character scalar.")
  }
  if (!is.character(prefix) || length(prefix) != 1L || !nzchar(prefix)) {
    rlang::abort("`prefix` must be a non-empty character scalar.")
  }

  repos <- safe_gh(
    gh::gh,
    "GET /orgs/{org}/repos",
    org = org,
    type = "public",
    per_page = 100,
    .limit = Inf,
    .token = token
  )

  if (is.null(repos) || !length(repos)) {
    return(character())
  }

  matches <- Filter(
    function(repo) {
      !is.null(repo$name) &&
        startsWith(repo$name, prefix) &&
        !rlang::is_true(repo$private) &&
        !rlang::is_true(repo$archived)
    },
    repos
  )

  if (!length(matches)) {
    return(character())
  }

  sort(vapply(matches, function(repo) paste0(org, "/", repo$name), character(1)))
}
