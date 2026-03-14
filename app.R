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

# Filter choices from data
cities <- sort(unique(df$city[!is.na(df$city)]))
price_ranges <- sort(unique(df$price_range[!is.na(df$price_range)]))
cuisines <- sort(unique(df$category_1[!is.na(df$category_1)]))
dish_types <- sort(unique(df$category_2[!is.na(df$category_2)]))

# UI
ui <- page_fillable(
  theme = bs_theme(bootswatch = "flatly"),
  title = "Foodlytics",
  layout_sidebar(
    sidebar = sidebar(
      tags$label("Price Range", style = "font-weight: bold;"),
      div(
        style = "height: 120px; overflow-y: auto;",
        checkboxGroupInput(
          inputId = "price_range",
          label = "",
          choices = price_ranges,
          selected = price_ranges
        )
      ),
      tags$label("Cuisine / Restaurant Type", style = "font-weight: bold;"),
      div(
        style = "height: 200px; overflow-y: auto;",
        checkboxGroupInput(
          inputId = "cuisine",
          label = "",
          choices = cuisines,
          selected = cuisines
        )
      ),
      tags$label("Location", style = "font-weight: bold;"),
      div(
        style = "height: 200px; overflow-y: auto;",
        checkboxGroupInput(
          inputId = "city",
          label = "",
          choices = cities,
          selected = cities
        )
      ),
      tags$label("Dish / Food Type", style = "font-weight: bold;"),
      div(
        style = "height: 200px; overflow-y: auto;",
        checkboxGroupInput(
          inputId = "category_2",
          label = "",
          choices = dish_types,
          selected = dish_types
        )
      ),
      actionButton("reset_filters", "Reset filter"),
      open = "desktop"
    ),
    layout_columns(
      value_box(
        title = "Total Restaurants",
        value = textOutput("n_restaurants"),
        showcase = bsicons::bs_icon("shop")
      ),
      value_box(
        title = "Average Rating",
        value = textOutput("avg_rating"),
        showcase = bsicons::bs_icon("star-fill")
      ),
      fill = FALSE
    ),
    layout_columns(
      card(
        card_header("Restaurant count by cuisine"),
        plotOutput("bar_cuisine", height = "400px"),
        full_screen = TRUE
      ),
      fill = FALSE
    ),
    layout_columns(
      card(
        card_header("Restaurants"),
        dataTableOutput("tbl"),
        full_screen = TRUE
      ),
      fill = FALSE
    )
  )
)

# Server
server <- function(input, output, session) {
  filtered_data <- reactive({
    data <- df
    if (length(input$price_range) > 0)  data <- data %>% filter(price_range %in% input$price_range)
    if (length(input$cuisine) > 0)       data <- data %>% filter(category_1 %in% input$cuisine)
    if (length(input$city) > 0)          data <- data %>% filter(city %in% input$city)
    if (length(input$category_2) > 0)    data <- data %>% filter(category_2 %in% input$category_2)
    data
  })

  observeEvent(input$reset_filters, {
    updateCheckboxGroupInput(session, "price_range", selected = price_ranges)
    updateCheckboxGroupInput(session, "cuisine", selected = cuisines)
    updateCheckboxGroupInput(session, "city", selected = cities)
    updateCheckboxGroupInput(session, "category_2", selected = dish_types)
  })

  output$n_restaurants <- renderText({
    nrow(filtered_data())
  })

  output$avg_rating <- renderText({
    d <- filtered_data()
    if (nrow(d) == 0) return("—")
    sprintf("%.1f", mean(d$star, na.rm = TRUE))
  })

  output$bar_cuisine <- renderPlot({
    d <- filtered_data()
    if (nrow(d) == 0) {
      plot(NULL, xlim = c(0, 1), ylim = c(0, 1), axes = FALSE, xlab = "", ylab = "")
      text(0.5, 0.5, "No restaurants match the selected filters.", cex = 1.2)
      return(invisible(NULL))
    }
    agg <- d %>%
      count(category_1, name = "count") %>%
      slice_max(count, n = 20, with_ties = FALSE) %>%
      mutate(category_1 = factor(category_1, levels = category_1[order(count)]))
    ggplot(agg, aes(x = count, y = category_1, fill = count)) +
      geom_col() +
      scale_fill_gradient(low = "#c6dbef", high = "#084594", guide = "none") +
      labs(
        x = "Number of restaurants",
        y = "Cuisine / type"
      ) +
      theme_minimal() +
      theme(
        panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "white"),
        panel.grid = element_blank()
      )
  })

  output$tbl <- renderDataTable({
    d <- filtered_data()
    d %>%
      select(restaurant, star, num_reviews, city, price_range, category_1, category_2) %>%
      rename(Restaurant = restaurant, Stars = star, `# of Reviews` = num_reviews)
  }, options = list(pageLength = 10))
}

shinyApp(ui, server)
