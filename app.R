library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)
library(DT)

# Load data
data_path <- "data/raw/cleaned_full_data.csv"
if (!file.exists(data_path)) data_path <- "cleaned_full_data.csv"
df <- read.csv(data_path)
df$city <- gsub("Branpton", "Brampton", df$city)
cities <- sort(unique(df$city))
price_ranges <- sort(unique(df$price_range[!is.na(df$price_range)]))

ui <- fluidPage(
  theme = bs_theme(bootswatch = "flatly"),
  titlePanel("Foodlytics"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput(
        "price_range",
        "Price Range",
        choices = price_ranges,
        selected = price_ranges
      ),
      selectizeInput(
        "city",
        "Location (cities)",
        choices = cities,
        selected = cities,
        multiple = TRUE,
        options = list(plugins = list("remove_button"))
      ),
      actionButton("reset_filters", "Reset filters")
    ),
    mainPanel(
      fluidRow(
        column(6, value_box(
          title = "Total Restaurants",
          value = textOutput("n_restaurants"),
          showcase = bsicons::bs_icon("shop")
        )),
        column(6, value_box(
          title = "Average Rating",
          value = textOutput("avg_rating"),
          showcase = bsicons::bs_icon("star-fill")
        ))
      ),
      plotOutput("bar_cuisine", height = "400px"),
      dataTableOutput("tbl")
    )
  )
)

server <- function(input, output, session) {
  # Reactive calc: filtered dataframe
  filtered <- reactive({
    data <- df
    if (length(input$city) > 0)    data <- data %>% filter(city %in% input$city)
    if (length(input$price_range) > 0) data <- data %>% filter(price_range %in% input$price_range)
    data
  })

  # Reset filters button
  observeEvent(input$reset_filters, {
    updateCheckboxGroupInput(session, "price_range", selected = price_ranges)
    updateSelectizeInput(session, "city", selected = cities)
  })

  output$n_restaurants <- renderText({
    nrow(filtered())
  })

  output$avg_rating <- renderText({
    d <- filtered()
    if (nrow(d) == 0) return("—")
    sprintf("%.1f", mean(d$star, na.rm = TRUE))
  })

  output$bar_cuisine <- renderPlot({
    d <- filtered()
    if (nrow(d) == 0) {
      plot(NULL, xlim = c(0, 1), ylim = c(0, 1), axes = FALSE, xlab = "", ylab = "")
      text(0.5, 0.5, "No restaurants match the selected filters.", cex = 1.2)
      return(invisible(NULL))
    }
    agg <- d |>
      count(category_1, name = "count") |>
      slice_max(count, n = 20, with_ties = FALSE) |> 
      mutate(category_1 = factor(category_1, levels = category_1[order(count)]))
    ggplot(agg, aes(x = count, y = category_1, fill = count)) +
      geom_col() +
      scale_fill_viridis_c(option = "plasma", guide = "none") +
      labs(x = "Number of restaurants", y = "Cuisine / type") +
      theme_minimal()
  })

  output$tbl <- renderDataTable({
    d <- filtered()
    d |> 
      select(restaurant, star, num_reviews, city, price_range, category_1, category_2) |>
      rename(Restaurant = restaurant, Stars = star, `# of Reviews` = num_reviews)
  }, options = list(pageLength = 10))
}

shinyApp(ui, server)