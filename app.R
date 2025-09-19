# app.R - Quiz Landing Page for openwashdata Course

library(shiny)
library(bslib)
library(yaml)

# Load configuration
source("config.R")

# Function to extract quiz metadata from Rmd files
extract_quiz_metadata <- function(quiz_name) {
  rmd_path <- file.path("modules", quiz_name, paste0(quiz_name, ".Rmd"))
  
  if (!file.exists(rmd_path)) {
    return(NULL)
  }
  
  # Read the Rmd file and extract YAML header
  rmd_content <- readLines(rmd_path)
  yaml_start <- which(rmd_content == "---")[1]
  yaml_end <- which(rmd_content == "---")[2]
  
  if (is.na(yaml_start) || is.na(yaml_end) || yaml_start >= yaml_end) {
    return(NULL)
  }
  
  yaml_content <- paste(rmd_content[(yaml_start + 1):(yaml_end - 1)], collapse = "\n")
  yaml_data <- yaml::yaml.load(yaml_content)
  
  # Extract title and description
  title <- yaml_data$title %||% paste("Quiz:", quiz_name)
  description <- yaml_data$description %||% "Interactive quiz module"
  
  return(list(title = title, description = description))
}

# Auto-generate quiz list from quiz names
generate_quiz_list <- function(quiz_names) {
  # Generate quiz list with metadata
  quiz_list <- lapply(quiz_names, function(quiz_name) {
    metadata <- extract_quiz_metadata(quiz_name)
    
    # Generate URL based on quiz name
    quiz_url <- paste0(base_url, quiz_name, "/")
    
    list(
      id = quiz_name,
      title = metadata$title %||% paste("Quiz:", quiz_name),
      description = metadata$description %||% "Interactive quiz module",
      url = quiz_url,
      available = TRUE
    )
  })
  
  return(quiz_list)
}

# Generate quiz list automatically from config
quizzes <- generate_quiz_list(quiz_names)

# UI
ui <- page_navbar(
  title = "ds4owd-002 quiz",
  theme = bs_theme(bootswatch = "cosmo"),
  
  nav_panel(
    "Home",
    div(
      class = "container mt-5",
      div(
        class = "text-center mb-5",
        h1("data science for openwashdata - quiz"),
        p(class = "lead", "Interactive tutorials to test your knowledge."),
        p(class = "lead text-warning fw-bold", "For successful completion of the course, you need to complete the quizzes for each module."),
      ),
      
      div(
        class = "row justify-content-center",
        div(
          class = "col-md-8",
          lapply(seq_along(quizzes), function(i) {
            quiz <- quizzes[[i]]
            div(
              class = "card mb-4",
              div(
                class = "card-header d-flex justify-content-between align-items-center",
                h4(class = "mb-0", quiz$title),
                if (!quiz$available) {
                  span(class = "badge bg-secondary", "Coming Soon")
                }
              ),
              div(
                class = "card-body",
                p(quiz$description),
                if (quiz$available) {
                  tags$a(
                    href = quiz$url,
                    target = "_blank",
                    class = "btn btn-primary btn-lg",
                    "Start Quiz"
                  )
                } else {
                  span(class = "text-muted", "This quiz is not yet available")
                }
              )
            )
          })
        )
      )
    )
  ),
  
  nav_panel(
    "About",
    div(
      class = "container mt-5",
      div(
        class = "row justify-content-center",
        div(
          class = "col-md-8",
          h2("About These Quizzes"),
          p("These interactive quizzes are designed to help you learn and practice concepts from the ds4owd course. They are required to be completed for each module of the course."),
          
          h3("Features"),
          tags$ul(
            tags$li("Interactive R code exercises"),
            tags$li("Immediate feedback on your answers"),
            tags$li("Hints and solutions available"),
            tags$li("Progress tracking within each quiz"),
            tags$li("Automatic grading")
          ),
          
          h3("How to Use"),
          tags$ol(
            tags$li("Select a quiz module from the home page"),
            tags$li("Click 'Start Quiz' to open the interactive tutorial"),
            tags$li("Work through the questions at your own pace"),
            tags$li("Run code in the interactive exercises"),
            tags$li("Use hints if you get stuck"),
            tags$li("Check your solutions for immediate feedback"),
            tags$li("Ensure to submit the Quiz with your GitHub username")
          ),
          
          h3("Technical Requirements"),
          p("These quizzes run entirely in your web browser. No R installation is required on your computer - everything runs on our servers."),
          
          h3("Progress Tracking"),
          p("Your progress is automatically saved within each quiz session. However, progress may be lost if you close the browser or if the session times out.")
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  # Simple server - no reactive elements needed for this landing page
}

# Create Shiny app
shinyApp(ui = ui, server = server)