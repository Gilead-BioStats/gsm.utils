#' Generate Examples Menu and Index for pkgdown
#'
#' Scans for HTML files in a directory (default is pkgdown/assets/examples) and updates 
#' a standard _pkgdown.yml with a new sub-menu listing the html files.
#'
#' @param examples_dir Character. Path to directory containing example HTML files.
#'   Default is "pkgdown/assets/examples".
#' @param pkgdown_yml Character. Path to _pkgdown.yml file to update with menu.
#'   Default is "_pkgdown.yml".
#'
#' @return Invisibly returns NULL.
#' @export
#' 

AddPkgdownExamples <- function(examples_dir = "pkgdown/assets/examples", 
                                pkgdown_yml = "_pkgdown.yml") {
  
  html_files <- list.files(examples_dir, pattern = "\\.html$", full.names = FALSE)
  # Exclude index.html from the menu
  html_files <- html_files[html_files != "index.html"]
  
  if (length(html_files) > 0) {
    # Update _pkgdown.yml
    if (!is.null(pkgdown_yml) && file.exists(pkgdown_yml)) {
      # Read the YAML as a list
      pkgdown_yaml <- yaml::read_yaml(pkgdown_yml)
      
      # if navbar.components.examples doesn't exist, create it
      if (is.null(pkgdown_yaml$navbar$components$examples)) {
        pkgdown_yaml$navbar$components$examples <- list(
          text = "Examples",
          menu = list()
        )
      }
  
      # Update the examples menu
      pkgdown_yaml$navbar$components$examples$menu <- lapply(html_files, function(html_file) {
        list(
          text = tools::toTitleCase(gsub("_", " ", tools::file_path_sans_ext(html_file))),
          href = file.path("examples", html_file)
        )
      })
      
      # Write the updated YAML back to the file
      yaml::write_yaml(pkgdown_yaml, pkgdown_yml)
      message("Updated ", pkgdown_yml, " with ", length(html_files), " example(s)")
    }
    
  } else {
    message("No HTML files found in ", examples_dir)
    
    # Remove examples from _pkgdown.yml if provided
    if (!is.null(pkgdown_yml) && file.exists(pkgdown_yml)) {
      pkgdown_yaml <- yaml::read_yaml(pkgdown_yml)
      
      # Remove examples component
      pkgdown_yaml$navbar$components$examples <- NULL
      
      # Remove 'examples' from navbar structure if present
      if (!is.null(pkgdown_yaml$navbar$structure$left)) {
        pkgdown_yaml$navbar$structure$left <- setdiff(
          pkgdown_yaml$navbar$structure$left, 
          "examples"
        )
      }
      
      yaml::write_yaml(pkgdown_yaml, pkgdown_yml)
      message("Removed examples menu from ", pkgdown_yml)
    }
  }
  
  invisible(NULL)
}
