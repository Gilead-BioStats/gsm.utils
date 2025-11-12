# add_pkgdown_examples gives the expected message

    Code
      test_result <- add_pkgdown_examples(test_path("fixtures", "pkgdown_examples"),
      test_path("fixtures", "_pkgdown.yml"))
    Message
      YAML written
      Updated 'fixtures/_pkgdown.yml' with 2 examples.

# add_pkgdown_examples adds section if it doesn't exist

    Code
      test_result <- add_pkgdown_examples(test_path("fixtures", "pkgdown_examples"),
      test_path("fixtures", "_pkgdown_no_examples.yml"))
    Message
      YAML written
      Updated 'fixtures/_pkgdown_no_examples.yml' with 2 examples.

# add_pkgdown_examples removes examples section if no examples

    Code
      test_result <- add_pkgdown_examples(empty_dir, test_path("fixtures",
        "_pkgdown.yml"))
    Message
      No HTML files found in <tempdir>
      YAML written
      Removed examples menu from 'fixtures/_pkgdown.yml'.

