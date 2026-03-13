# Foodlytics

A small Shiny for R version of the Foodlytics dashboard. This dashboard visualizes restaurant quality and type across Canada’s main cities. It is aimed at businesses and entrepreneurs planning to open a new restaurant. The app helps users understand the local restaurant landscape so they can make better decisions about where to open and what type of restaurant to offer.

![Foodlytics dashboard](img/Dashboard.png)

**Deployed app:** https://rabin-dsci-532-foodlytics-r.share.connect.posit.cloud/

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