# ==============================================================================
# LIBRARIES
# ==============================================================================
library(shiny)
library(tidyverse)
library(janitor)
library(sf)
library(rnaturalearth)

# ==============================================================================
# 1. DATA PRE-PROCESSING
# ==============================================================================

# File paths - Update these to your local paths for the final run
path_stations <- "add ur  path here  "
path_satellite <- "add ur path here "

# Load Satellite Data (1998 TO 2022)
sat_data <- read_csv(path_satellite)

# Load Station Data (Cleaned for current comparisons)
raw_data <- read_csv(path_stations) %>% clean_names()
clean_pm25_all <- raw_data %>%
  filter(pollutant_id == "PM2.5") %>%
  mutate(pollutant_avg = as.numeric(pollutant_avg)) %>%
  filter(!is.na(pollutant_avg))

# GIS Shapefile Download (Using ne_download to bypass library errors)
india_borders <- ne_download(scale = 50, type = "states", category = "cultural", returnclass = "sf") %>% 
  filter(admin == "India")

maha_shape <- india_borders %>% filter(name == "Maharashtra")

# ==============================================================================
# 2. USER INTERFACE (UI)
# ==============================================================================

ui <- navbarPage(
  title = "India & Maharashtra Air Quality Explorer",
  
  # TAB 1: National Time-Series Map
  tabPanel("National GIS Map",
           sidebarLayout(
             sidebarPanel(
               h3("National Overview"),
               helpText("The line graph shows the 25-year upward trend for all of India."),
               sliderInput("year_india", "Select Year:", min = 1998, max = 2022, value = 2022, sep = ""),
               hr(),
               plotOutput("indiaLinePlot", height = "250px") # NEW: National Linear Growth
             ),
             mainPanel(plotOutput("indiaMap", height = "650px"))
           )
  ),
  
  # TAB 2: MAHARASHTRA INTERACTIVE DEEP-DIVE
  tabPanel("Maharashtra Analysis",
           sidebarLayout(
             sidebarPanel(
               h3("Maharashtra Focus"),
               helpText("The line graph highlights the aggressive growth in state pollution."),
               sliderInput("year_maha", "Select Year:", min = 1998, max = 2022, value = 2022, sep = "", animate = TRUE),
               hr(),
               plotOutput("mahaLinePlot", height = "250px"), # NEW: Maha Linear Growth
               hr(),
               p("Red dashed line = Safety Standard (40 µg/m³).")
             ),
             mainPanel(
               fluidRow(column(12, plotOutput("mahaMap", height = "400px"))),
               hr(),
               fluidRow(
                 column(6, plotOutput("mahaBarPlot", height = "300px")),
                 column(6, plotOutput("mahaBoxPlot", height = "300px"))
               ),
               hr(),
               fluidRow(
                 column(6, plotOutput("mahaCityPlot", height = "350px")),
                 column(6, plotOutput("mahaDensityPlot", height = "350px"))
               )
             )
           )
  ),
  
  # TAB 3: National Regional Comparisons
  tabPanel("National Statistics",
           sidebarLayout(
             sidebarPanel(
               h3("State Comparison"),
               selectInput("state_select", "Compare Other State:", 
                           choices = sort(unique(clean_pm25_all$state)), 
                           selected = "Maharashtra"),
               helpText("Detailed comparison using real-time station data.")
             ),
             mainPanel(
               fluidRow(column(6, plotOutput("natBarPlot")), column(6, plotOutput("natBoxPlot"))),
               hr(),
               fluidRow(column(6, plotOutput("natCityPlot")), column(6, plotOutput("natDensityPlot")))
             )
           )
  )
)

# ==============================================================================
# 3. SERVER LOGIC
# ==============================================================================

server <- function(input, output) {
  
  # --- REACTIVE DATA FOR MAHARASHTRA (BY YEAR) ---
  maha_year_data <- reactive({
    req(input$year_maha)
    selected_col <- paste0("Y", input$year_maha)
    sat_data %>%
      filter(midlong >= 72 & midlong <= 81, midlat >= 15 & midlat <= 22.5) %>%
      select(midlong, midlat, val = all_of(selected_col)) %>%
      filter(val > 0)
  })
  
  # --- NATIONAL LINE GRAPH (LINEAR GROWTH) ---
  output$indiaLinePlot <- renderPlot({
    india_trends <- sat_data %>%
      summarise(across(starts_with("Y"), \(x) mean(x, na.rm = TRUE))) %>%
      pivot_longer(everything(), names_to = "Year", values_to = "Avg_PM25") %>%
      mutate(Year = as.numeric(gsub("Y", "", Year)))
    
    ggplot(india_trends, aes(x = Year, y = Avg_PM25)) +
      geom_line(color = "grey50", size = 1.2) +
      geom_point(data = filter(india_trends, Year == input$year_india), color = "red", size = 4) +
      theme_minimal() + labs(title = "National Growth Trend", y = "PM2.5")
  })
  
  # --- MAHARASHTRA LINE GRAPH (LINEAR GROWTH) ---
  output$mahaLinePlot <- renderPlot({
    maha_trends <- sat_data %>%
      filter(midlong >= 72 & midlong <= 81, midlat >= 15 & midlat <= 22.5) %>%
      summarise(across(starts_with("Y"), \(x) mean(x, na.rm = TRUE))) %>%
      pivot_longer(everything(), names_to = "Year", values_to = "Avg_PM25") %>%
      mutate(Year = as.numeric(gsub("Y", "", Year)))
    
    ggplot(maha_trends, aes(x = Year, y = Avg_PM25)) +
      geom_line(color = "orange", size = 1.2) +
      geom_point(data = filter(maha_trends, Year == input$year_maha), color = "black", size = 4) +
      geom_hline(yintercept = 40, linetype = "dashed", color = "red") +
      theme_minimal() + labs(title = "Maha Growth Trend", y = "PM2.5")
  })
  
  # --- MAPS ---
  output$indiaMap <- renderPlot({
    sel_year <- paste0("Y", input$year_india)
    df <- sat_data %>% select(midlong, midlat, val = all_of(sel_year)) %>% filter(val > 0)
    ggplot() +
      geom_tile(data = df, aes(x = midlong, y = midlat, fill = val)) +
      geom_sf(data = india_borders, fill = NA, color = "black", size = 0.2, inherit.aes = FALSE) +
      scale_fill_gradientn(colors = c("#009966", "#ffde33", "#ff9933", "#cc0033", "#660099", "#7e0023"), 
                           name = "PM2.5", limits = c(0, 150)) +
      coord_sf(xlim = c(68, 98), ylim = c(7, 38)) + theme_minimal() +
      labs(title = paste("National Pollution Map:", input$year_india))
  })
  
  output$mahaMap <- renderPlot({
    ggplot() +
      geom_tile(data = maha_year_data(), aes(x = midlong, y = midlat, fill = val)) +
      geom_sf(data = maha_shape, fill = NA, color = "black", size = 1, inherit.aes = FALSE) +
      scale_fill_gradientn(colors = c("#009966", "#ffde33", "#ff9933", "#cc0033", "#660099", "#7e0023"), 
                           name = "PM2.5", limits = c(0, 120)) +
      theme_void() + labs(title = paste("Maharashtra Cluster Analysis:", input$year_maha))
  })
  
  # --- MAHARASHTRA DASHBOARD PLOTS ---
  output$mahaBarPlot <- renderPlot({
    sel_col <- paste0("Y", input$year_maha)
    m_avg <- mean(maha_year_data()$val, na.rm = TRUE)
    n_avg <- mean(sat_data[[sel_col]], na.rm = TRUE)
    df <- data.frame(category = c("India", "Maharashtra"), avg_value = c(n_avg, m_avg))
    ggplot(df, aes(x = category, y = avg_value, fill = category)) +
      geom_col(width = 0.5) + geom_text(aes(label = round(avg_value, 1)), vjust = -0.5) +
      geom_hline(yintercept = 40, linetype = "dashed", color = "red") +
      scale_fill_manual(values = c("grey70", "orange")) + theme_minimal() + labs(title = "State vs Nation Avg")
  })
  
  output$mahaBoxPlot <- renderPlot({
    ggplot(maha_year_data(), aes(x = "Maharashtra", y = val)) +
      geom_boxplot(fill = "orange", alpha = 0.7) + geom_jitter(width = 0.1, alpha = 0.2) +
      theme_classic() + labs(title = "Statistical Spread", y = "PM2.5")
  })
  
  output$mahaCityPlot <- renderPlot({
    top_clusters <- maha_year_data() %>% arrange(desc(val)) %>% head(20) %>% mutate(ID = row_number())
    ggplot(top_clusters, aes(x = reorder(ID, val), y = val)) + 
      geom_col(fill = "steelblue") + coord_flip() + theme_light() + labs(title = "Hotspot Ranking", x = "Cluster ID")
  })
  
  output$mahaDensityPlot <- renderPlot({
    ggplot(maha_year_data(), aes(x = val)) +
      geom_density(fill = "orange", alpha = 0.5) + geom_vline(xintercept = 40, linetype = "dashed", color = "red") +
      theme_minimal() + labs(title = "Concentration Density")
  })
  
  # --- TAB 3: NATIONAL STATS ---
  selected_state_data <- reactive({ clean_pm25_all %>% filter(state == input$state_select) })
  output$natBarPlot <- renderPlot({
    s_avg <- mean(selected_state_data()$pollutant_avg, na.rm = TRUE)
    india_avg_val <- mean(clean_pm25_all$pollutant_avg, na.rm = TRUE)
    df <- data.frame(category = c("India", input$state_select), avg_value = c(india_avg_val, s_avg))
    ggplot(df, aes(x = category, y = avg_value, fill = category)) + geom_col(width = 0.5) + 
      scale_fill_manual(values = c("grey70", "orange")) + theme_minimal() + labs(title = "Regional vs National")
  })
  
  output$natBoxPlot <- renderPlot({
    ggplot(clean_pm25_all, aes(x = (state == input$state_select), y = pollutant_avg, fill = (state == input$state_select))) + 
      geom_boxplot() + scale_fill_manual(values = c("grey70", "orange"), labels = c("India", input$state_select)) +
      theme_classic() + labs(title = "National Boxplot Comparison")
  })
  
  output$natCityPlot <- renderPlot({
    c_df <- selected_state_data() %>% group_by(city) %>% summarise(c_avg = mean(pollutant_avg)) %>% arrange(desc(c_avg))
    ggplot(c_df, aes(x = reorder(city, c_avg), y = c_avg)) + geom_col(fill = "steelblue") + 
      coord_flip() + theme_light() + labs(title = "City Rankings")
  })
  
  output$natDensityPlot <- renderPlot({
    ggplot(clean_pm25_all, aes(x = pollutant_avg, fill = (state == input$state_select))) + 
      geom_density(alpha = 0.5) + scale_fill_manual(values = c("skyblue", "orange"), labels = c("India", input$state_select)) +
      theme_minimal() + labs(title = "National Density Comparison")
  })
}

# --- RUN APP ---

shinyApp(ui, server)
