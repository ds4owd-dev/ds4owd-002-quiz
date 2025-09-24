# Load configuration
source("config.R")

# HELPER FUNCTIONS

run_quiz <- function(module_name) {
  module_dir <- file.path("modules", module_name)
  rmd_file <- file.path(module_dir, paste0(module_name, ".Rmd"))

  if (!file.exists(rmd_file)) {
    stop("Quiz file not found: ", rmd_file)
  }

  # Copy all common files to module directory
  common_files <- list.files(
    "modules/common",
    full.names = TRUE,
    recursive = TRUE
  )
  copied_files <- character(0)
  for (file in common_files) {
    if (file.info(file)$isdir == FALSE) {
      dest_file <- file.path(module_dir, basename(file))
      file.copy(file, dest_file, overwrite = TRUE)
      copied_files <- c(copied_files, dest_file)
    }
  }

  # Set working directory to module directory for running
  current_dir <- getwd()
  on.exit({
    setwd(current_dir)
    # Clean up: delete copied common files after running
    for (file in copied_files) {
      if (file.exists(file)) {
        file.remove(file)
      }
    }
  })
  setwd(module_dir)

  # Run the quiz interactively
  cat("Running", module_name, "interactively...\n")
  rmarkdown::run(paste0(module_name, ".Rmd"))
}

# QUIZ RUNNING

cat("Available quizzes to run:\n")
for (i in seq_along(quiz_names)) {
  cat(i, ":", quiz_names[i], "\n")
}

cat("\nTo run a specific quiz, use:\n")
cat("run_quiz('quiz-name')\n")
cat("\nExample: run_quiz('md-01-quiz')\n")