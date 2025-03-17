#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#


library(httr)
library(jsonlite)
library(ggplot2)
library(shiny)
library(dplyr)
library(gridExtra)
library(tidyverse)

current_year <- as.numeric(format(Sys.Date(), "%Y"))
prev_year <- current_year-1
prev_year1 <- prev_year-1
prev_year2 <- prev_year1-1
prev_year3 <- prev_year2-1
prev_year4 <- prev_year3-1
prev_year5 <- prev_year4-1

type = 'points'
ar = paste0(type,'.id')
ar

process_points_data <- function(year) {
  p_url <- paste0('https://api-web.nhle.com/v1/skater-stats-leaders/', 
                  as.numeric(year) - 1, 
                  as.numeric(year), 
                  '/2?categories=points&limit=-1')
  
  p_df <- unnest(as.data.frame(fromJSON(p_url)))
  p_df <- p_df |> 
    select(
      points.id,
      default,
      default1,
      points.sweaterNumber,
      points.headshot,
      default2,
      points.teamLogo,
      points.position,
      points.value
    ) |> 
    rename(
      player_id = points.id,
      first_name = default,
      last_name = default1,
      sweater_number = points.sweaterNumber,
      headshot = points.headshot,
      team = default2,
      logo = points.teamLogo,
      position = points.position,
      points = points.value
    ) |> 
    mutate(
      season = year,
      full_name = paste(first_name, last_name)
    )
  
  g_url <- paste0('https://api-web.nhle.com/v1/skater-stats-leaders/', 
                  as.numeric(year) - 1, 
                  as.numeric(year), 
                  '/2?categories=goals&limit=-1')
  g_df <- unnest(as.data.frame(fromJSON(g_url)))
  g_df <- g_df |> 
    select(
      goals.id,
      goals.value
    ) |> 
    rename(
      player_id = goals.id,
      goals = goals.value
    )
  
  p_df <- p_df |>
    left_join(g_df, by = 'player_id') |>
    mutate(
      goals = coalesce(goals, 0),
      assists = points - goals
    )
  return(p_df)
  
}

points_current <- process_points_data(current_year)
points_prev <-  process_points_data(prev_year)
points_prev1 <-  process_points_data(prev_year1)
points_prev2 <-  process_points_data(prev_year2)
points_prev3 <-  process_points_data(prev_year3)

total_points <- bind_rows(
  mutate(points_prev3, season = prev_year3),
  mutate(points_prev2, season = prev_year2),
  mutate(points_prev1, season = prev_year1),
  mutate(points_prev, season = prev_year),
  mutate(points_current, season = current_year)
)


ui <- fluidPage(
  titlePanel("NHL API Player Statistics Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      selectizeInput("player1", "Select Player 1", choices = NULL, options = list(maxItems = 1, create = FALSE, placeholder = 'Select Player 1')),
      uiOutput("player1_headshot"),
      selectizeInput("player2", "Select Player 2", choices = NULL, options = list(maxItems = 1, create = FALSE, placeholder = 'Select Player 2')),
      uiOutput("player2_headshot")
    ),
    
    mainPanel(
      plotOutput("linePlot", height = '700px')
    )
  )
)

server <- function(input, output, session) {
  
  observe({
    updateSelectInput(session, "player1", choices = unique(total_points$full_name))
    updateSelectInput(session, "player2", choices = unique(total_points$full_name))
  })
  
  output$player1_headshot <- renderUI({
    player1_data <- total_points %>%
      filter(full_name == input$player1, season == 2025)
    
    player1_url <- player1_data$headshot
    player1_team <- player1_data$team
    player1_logo <- player1_data$logo
    player1_goals <- player1_data$goals
    player1_assists <- player1_data$assists
    player1_points <- player1_data$points
    
    tagList(
      img(src = player1_url, height = "100px", width = "100px"),
      br(),
      span(player1_team, style = "font-weight: bold;"),
      img(src = player1_logo, height = "30px", width = "30px"),
      br(),
      paste0(current_year, " Key Player Statistics"),
      br(),
      paste("Goals: ", player1_goals),
      br(),
      paste("Assists: ", player1_assists),
      br(),
      paste("Points: ", player1_points),
      br(),
      br(),
    )
  })
  
  output$player2_headshot <- renderUI({
    player2_data <- total_points %>%
      filter(full_name == input$player2, season == 2025)
    
    player2_url <- player2_data$headshot
    player2_team <- player2_data$team
    player2_logo <- player2_data$logo
    player2_goals <- player2_data$goals
    player2_assists <- player2_data$assists
    player2_points <- player2_data$points
    
    tagList(
      img(src = player2_url, height = "100px", width = "100px"),
      br(),
      span(player2_team, style = "font-weight: bold;"),
      img(src = player2_logo, height = "30px", width = "30px"),
      br(),
      paste0(current_year, " Key Player Statistics"),
      br(),
      paste("Goals: ", player2_goals),
      br(),
      paste("Assists: ", player2_assists),
      br(),
      paste("Points: ", player2_points),
      br()
    )
  })
  
  output$linePlot <- renderPlot({
    
    player1_data <- total_points %>% filter(full_name == input$player1)
    player2_data <- total_points %>% filter(full_name == input$player2)
    
    p1_points <- ggplot() +
      geom_line(data = player1_data, aes(x = season, y = points, color = input$player1), size = 1) +
      geom_line(data = player2_data, aes(x = season, y = points, color = input$player2), size = 1) +
      geom_text(data = player1_data, aes(x = season, y = points, label = points), 
                vjust = -0.5, size = 4) + 
      geom_text(data = player2_data, aes(x = season, y = points, label = points), 
                vjust = -0.5, size = 4) +
      labs(title = "Player Points Over Seasons", x = "Season", y = "Points", color = "Player") +
      scale_color_manual(values = c("red", "blue")) +
      theme_minimal() +
      theme(legend.position = "bottom") +
      guides(color = guide_legend(override.aes = list(size = 1)))
    
    p2_goals <- ggplot() +
      geom_line(data = player1_data, aes(x = season, y = goals, color = input$player1), size = 1) +
      geom_line(data = player2_data, aes(x = season, y = goals, color = input$player2), size = 1) +
      geom_text(data = player1_data, aes(x = season, y = goals, label = goals), 
                vjust = -0.5, size = 4) + 
      geom_text(data = player2_data, aes(x = season, y = goals, label = goals), 
                vjust = -0.5, size = 4) +
      labs(title = "Player Goals Over Seasons", x = "Season", y = "Goals", color = "Player") +
      scale_color_manual(values = c("red", "blue")) +
      theme_minimal() +
      theme(legend.position = "bottom") + 
      guides(color = guide_legend(override.aes = list(size = 1)))
    
    p3_assists <- ggplot() +
      geom_line(data = player1_data, aes(x = season, y = assists, color = input$player1), size = 1) +
      geom_line(data = player2_data, aes(x = season, y = assists, color = input$player2), size = 1) +
      geom_text(data = player1_data, aes(x = season, y = assists, label = assists), 
                vjust = -0.5, size = 4) +
      geom_text(data = player2_data, aes(x = season, y = assists, label = assists), 
                vjust = -0.5, size = 4) +
      labs(title = "Player Assists Over Seasons", x = "Season", y = "Assists", color = "Player") +
      scale_color_manual(values = c("red", "blue")) +
      theme_minimal() +
      theme(legend.position = "bottom") + 
      guides(color = guide_legend(override.aes = list(size = 1))) 
    
    grid.arrange(p1_points, p2_goals, p3_assists, ncol = 2, widths = c(1, 1), layout_matrix = rbind(c(1,1),
                                                                                                    c(2,3)))
  })
}

shinyApp(ui = ui, server = server)