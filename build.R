# Load configuration
source("config.R")

# HELPER

deploy_quiz <- function(module_name) {
  # Deploy directly from module directory - no temp directories!
  module_dir <- file.path("modules", module_name)
  rmd_file <- file.path(module_dir, paste0(module_name, ".Rmd"))
  
  if (!file.exists(rmd_file)) {
    stop("Quiz file not found: ", rmd_file)
  }
  
  # Deploy directly from module directory
  rsconnect::deployDoc(
    doc = rmd_file,
    appName = module_name,
    forceUpdate = TRUE,
    logLevel = "verbose"
  )
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
