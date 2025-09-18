# Load configuration
source("config.R")

# HELPER

deploy_quiz <- function(module_name) {
  module_path <- paste0(file.path("modules", module_name), ".Rmd")

  quiz_files <- c(
    module_path,
    "modules/_github_username.Rmd",
    "modules/_participation.Rmd",
    "modules/_submission.Rmd",
    "modules/github_usernames.csv"
  )

  rsconnect::deployDoc(
    doc = module_path,
    appName = module_name,
    appFiles = quiz_files,
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
