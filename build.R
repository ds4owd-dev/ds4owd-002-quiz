# Load configuration
source("config.R")

# HELPER

deploy_quiz <- function(module_name) {
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

  # Deploy directly from module directory
  rsconnect::deployDoc(
    doc = rmd_file,
    appName = module_name,
    forceUpdate = TRUE,
    logLevel = "verbose"
  )
  rsconnect::showLogs()

  # Clean up: delete copied common files after deployment
  for (file in copied_files) {
    if (file.exists(file)) {
      file.remove(file)
    }
  }
}


# QUIZ DEPLOYMENT

rsconnect::deployApp(
  appName = main_app_name,
  forceUpdate = TRUE
)

for (quiz in quiz_names) {
  deploy_quiz(quiz)
}

# To add new quizzes, edit config.R
