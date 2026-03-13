# Foodlytics (Shiny for R)

A small Shiny for R version of the Foodlytics dashboard: explore restaurant counts and ratings by city.

**Deployed app:** [Add your Posit Connect Cloud URL here]

## Install packages

In R:

```r
install.packages(c("shiny", "bslib", "ggplot2", "dplyr", "DT", "bsicons", "rsconnect"))
```

## Run the application locally

R looks for `app.R` in the **current working directory**. Follow the instructions below to set the correct working directory.

1. Open `app.R` in RStudio, then go to **Session → Set Working Directory → To Source File Location**.

2. Run in R:

```r
shiny::runApp("app.R")
```

Or from the terminal (first `cd` into the project folder):

```bash
cd /path/to/foodlytics
R -e "shiny::runApp('app.R')"
```

## Deploy to Posit Connect Cloud

Posit Connect Cloud needs a `manifest.json` file in the repo (along the path to `app.R`) so it can install the right R packages and run the app.

**Generate `manifest.json` once (and again if you add packages or change the app):**

1. In R or RStudio, set the working directory to this project folder (e.g. **File → Open Project…** and open the repo, or `setwd("path/to/foodlytics")`).

2. Install the `rsconnect` package if you don’t have it: `install.packages("rsconnect")`.

3. Run:

```r
rsconnect::writeManifest(appDir = ".", appPrimaryDoc = "app.R")
```

4. Commit and push the new `manifest.json` to your GitHub repo. Then in Connect Cloud, connect the repo and deploy. It will find `manifest.json` next to `app.R`.