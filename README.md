# Foodlytics (Shiny for R)

A small Shiny for R version of the Foodlytics dashboard: explore restaurant counts and ratings by city.

**Deployed app:** [Add your Posit Connect Cloud URL here]

## Install packages

In R:

```r
install.packages(c("shiny", "bslib", "ggplot2", "dplyr", "DT", "bsicons"))
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