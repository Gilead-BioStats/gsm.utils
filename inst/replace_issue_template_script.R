## use github API to edit the folder, make a commit, push to a new branch, and create a PR
library(gh)
library(jsonlite)
library(dplyr)
library(glue)

# Authenticate with GitHub (must have a PAT with repo scope in GITHUB_PAT env var)
# Sys.setenv(GITHUB_PAT = "your_token_here")

owner <- "Gilead-BioStats"
repo  <- "gsm.core"
branch <- "update-issue-templates"
base_branch <- "dev"

# Step 1: Get the default branch reference (sha of latest commit)
ref <- gh("GET /repos/{owner}/{repo}/git/ref/heads/{branch}",
          owner = owner, repo = repo, branch = base_branch)

base_sha <- ref$object$sha

# Step 2: Create a new branch pointing to same commit
gh("POST /repos/{owner}/{repo}/git/refs",
   owner = owner, repo = repo,
   ref = paste0("refs/heads/", branch),
   sha = base_sha)

files <- tryCatch(
  gh("GET /repos/{owner}/{repo}/contents/{path}?ref={branch}",
     owner = owner, repo = repo, path = ".github/ISSUE_TEMPLATE", branch = base_branch),
  error = function(e) list()
)

# --- Step 4: Delete each existing file ---
if (length(files) > 0) {
  for (f in files) {
    gh("DELETE /repos/{owner}/{repo}/contents/{path}",
       owner = owner, repo = repo,
       path = f$path,
       message = paste0("Remove old issue template: ", f$name),
       sha = f$sha,
       branch = branch)
  }
}

# get list of issue templates in gsm.utils
vIssueTemplates <- list.files(system.file("gha_templates/ISSUE_TEMPLATE/", package = "gsm.utils"), full.names = TRUE)

# prepare new file content one by one (must be base64 encoded)
for(issue_template in vIssueTemplates) {
    new_file_path <- paste0(".github/ISSUE_TEMPLATE/", basename(issue_template))
    new_content <- readLines(issue_template) %>% paste(collapse = "\n")

    content_b64 <- jsonlite::base64_enc(charToRaw(new_content))

    # create or update the file in the branch one by one
    gh("PUT /repos/{owner}/{repo}/contents/{path}",
        owner = owner, repo = repo, path = new_file_path,
        message = glue::glue("Update {issue_template} issue template"),
        content = content_b64,
        branch = branch)
    rm(new_file_path)
    rm(new_content)
}

# create a pull request
gh("POST /repos/{owner}/{repo}/pulls",
   owner = owner, repo = repo,
   title = "Update .github issue templates using github API",
   head = branch,
   base = base_branch,
   body = "This PR updates the `.github/ISSUE_TEMPLATE` directory to match those in `gsm.utils`.")
