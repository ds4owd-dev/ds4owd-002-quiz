# openwashdata Course Quizzes

This directory contains interactive learnr quizzes for the openwashdata course and a landing page to access them.

**Live Demo**: https://u4x6xe-lars-sch0bitz.shinyapps.io/ds4owd-002-quiz/

## Structure

- `app.R` - Quiz landing page that automatically displays all configured quizzes
- `build.R` - Deployment script with helper functions for automated deployment
- `config.R` - Shared configuration file defining all available quizzes
- `modules/` - Directory containing individual quiz directories
  - `md-01-quiz/` - Module 1 quiz directory with all required files
  - `md-02-quiz/` - Module 2 quiz directory with all required files
  - Each quiz directory contains:
    - `md-XX-quiz.Rmd` - Main quiz file (learnr tutorial)
    - `_github_username.Rmd` - Reusable component for GitHub username input
    - `_participation.Rmd` - Reusable component for participation tracking
    - `_submission.Rmd` - Reusable component for quiz submission
    - `github_usernames.csv` - Student GitHub username database
    - `data/` - Quiz-specific data files (if needed)

## Required Packages

Make sure these packages are installed:

All required packages are defined in `DESCRIPTION` and automatically installed during deployment. For local development:

```r
# Install from DESCRIPTION file
devtools::install_github("ds4owd-dev/quiz")
```

## ShinyApps.io Authentication

Before deploying, you need to authenticate with shinyapps.io:

1. **Get your account credentials** from https://www.shinyapps.io/admin/#/tokens
2. **Set up authentication** in R:

```r
rsconnect::setAccountInfo(
  name = 'your-account-name',
  token = 'YOUR-TOKEN-HERE',
  secret = 'YOUR-SECRET-HERE'
)
```

Replace `your-account-name`, `YOUR-TOKEN-HERE`, and `YOUR-SECRET-HERE` with your actual credentials.

## Google Form Integration

The quizzes now include automatic submission to Google Forms for tracking student progress:

### Features
- **GitHub username collection**: Students enter their GitHub username at the start
- **Learnrhash generation**: Quiz responses are encoded using learnrhash
- **Automatic submission**: Results are submitted to Google Form via POST request
- **Modular components**: Reusable username and submission components

### Configuring Google Form Integration

To connect quizzes to your own Google Form, update the configuration in `modules/_submission.Rmd`.

#### 0. Google Form Structure

Your Google Form should have exactly 3 questions:
1. **Tutorial/Module ID** (text field)
2. **GitHub username** (text field)
3. **Learnrhash** (long text field for quiz results)

#### 1. Find Entry IDs

To get the entry IDs for your form fields:

1. **Open your Google Form** (the live form, not edit mode)
2. **Open browser inspector** (F12 or right-click → Inspect)
3. **Search for "entry"** in the HTML (Ctrl+F)
4. **Copy the entry IDs** - they appear as `entry.1234567890`

The entry IDs will be in the order your questions are set up in the form.

#### 2. Update form_url and Entry IDs

Update the variables at the top of `modules/_submission.Rmd`:

```r
# Google Form setup
form_url <- "https://docs.google.com/forms/d/e/YOUR-FORM-ID/formResponse"

# Entry ID mappings
tutorial_id_entry_id <- "entry.YOUR-MODULE-ID"         # For module name
github_username_entry_id <- "entry.YOUR-USERNAME-ID"   # For GitHub username
learnrhash_entry_id <- "entry.YOUR-LEARNRHASH-ID"      # For quiz results
```

#### Example Current Setup
- **Form URL**: https://docs.google.com/forms/d/e/1FAIpQLScnw9R8wMU5SfFqNVXGeEkiIygLTB_Dc6jWBmbwEeHuekBDzg/formResponse
- **Entry IDs**: 
  - `entry.1169139257` - Module name (1st question)
  - `entry.61564704` - GitHub username (2nd question)
  - `entry.1315905314` - Learnrhash (3rd question)

## Deployment Process

### Automated Deployment (CI/CD)

Quizzes are automatically deployed to shinyapps.io via GitHub Actions when changes are pushed to the `main` or `dev` branches.

#### Setting Up Automated Deployment

1. **Get shinyapps.io credentials**:
   - Go to [shinyapps.io](https://www.shinyapps.io/) → Account → Tokens
   - Click "Add Token" to generate new credentials
   - Copy the `name`, `token`, and `secret` values

2. **Configure GitHub Secrets**:
   - Go to your GitHub repository → Settings → Secrets and variables → Actions
   - Add these repository secrets:
     - `SHINYAPPS_ACCOUNT`: Your shinyapps.io account name
     - `SHINYAPPS_TOKEN`: The token from shinyapps.io  
     - `SHINYAPPS_SECRET`: The secret from shinyapps.io

3. **Add new quizzes to automated deployment**:
   - Edit `config.R` and add your new quiz:
   ```r
   quiz_names <- c(
     "md-01-quiz",
     "md-02-quiz"  # Add new quiz here
   )
   ```

#### How the CI/CD Workflow Works

The GitHub Action (`.github/workflows/deploy-quiz.yml`):
- **Triggers**: On pushes to `main`/`dev` branches or manual workflow dispatch
- **Environment**: Sets up R 4.3.2 with required packages from DESCRIPTION
- **Authentication**: Uses repository secrets to authenticate with shinyapps.io
- **Deployment**: Executes `build.R` to deploy all applications defined there
- **Logging**: Uploads deployment logs if any failures occur

### Manual Deployment

For manual deployment, simply run the build script which handles everything automatically:

```r
# Deploy all quizzes and landing page
source("build.R")
```

The deployment system features:
- **Direct module deployment**: Deploys directly from module directories (no temp files)
- **Self-contained modules**: Each quiz directory contains all required files
- **Streamlined process**: One script deploys everything configured in `config.R`

## Adding New Quizzes

The system uses a modular directory structure - adding a new quiz requires creating a complete directory:

### 1. Create the Quiz Directory

Create a new directory `modules/md-XX-quiz/` and add all required files:

```bash
mkdir modules/md-03-quiz
cp modules/md-01-quiz/_*.Rmd modules/md-01-quiz/github_usernames.csv modules/md-03-quiz/
```

### 2. Create the Quiz File

Create `modules/md-XX-quiz/md-XX-quiz.Rmd` with the standardized YAML header:

```yaml
---
title: "Module 3: Your Title"
output: learnr::tutorial
runtime: shiny_prerendered
description: "Your quiz description"
tutorial:
  id: "md-03-quiz"
---
```

Add your quiz content following the existing pattern, including:
- GitHub username collection: `{r github-username, child='_github_username.Rmd'}`
- Quiz submission: `{r submission-section, child='_submission.Rmd'}`

### 3. Update Configuration

Edit `config.R` to include your new quiz:

```r
quiz_names <- c(
  "md-01-quiz",
  "md-02-quiz",
  "md-03-quiz"  # Add new quiz here
)
```

### 4. Deploy

Run the build script to deploy everything:

```r
source("build.R")
```

This will:
- Automatically deploy the new quiz
- Update the landing page to show the new quiz

## Local Testing

### Test Individual Quizzes

```r
# Test a quiz locally
setwd("modules")
rmarkdown::run("md-01-quiz.Rmd")
```

### Test Landing Page

```r
# Test the landing page locally
shiny::runApp()
```

## Student Access

Students access the system through:
1. **Landing page**: Main hub showing all available quizzes
2. **Individual quizzes**: Full learnr tutorials with interactive exercises, hints, and automatic grading

Each quiz runs independently and provides the complete learnr experience including progress tracking within that session.