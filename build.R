# Load configuration
source("config.R")

# HELPER

deploy_quiz <- function(module_name) {
  # Create temporary deployment directory
  temp_dir <- paste0("temp_", module_name)
  dir.create(temp_dir, showWarnings = FALSE)
  
  # Copy only the files this quiz needs
  quiz_files <- c(
    paste0("modules/", module_name, ".Rmd"),
    "modules/_github_username.Rmd",
    "modules/_participation.Rmd", 
    "modules/_submission.Rmd",
    "modules/github_usernames.csv"
  )
  
  # Copy files to temp directory
  file.copy(quiz_files, temp_dir, overwrite = TRUE)
  
  # Deploy from temp directory
  rsconnect::deployDoc(
    doc = file.path(temp_dir, paste0(module_name, ".Rmd")),
    appName = module_name,
    forceUpdate = TRUE,
    logLevel = "verbose"
  )
  
  # Clean up temp directory
  unlink(temp_dir, recursive = TRUE)
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
