#Edit version: 12.09.2024####
#install packages if you have not
#install.packages("ggplot2","shiny","tidyr","dplyr","bslib", "ggthemes","shinyWidgets","ggdark", "export")


library(ggplot2)
library(shiny)
library(tidyr)
library(dplyr)
library(bslib)
library(ggthemes)
library(plotly)
library(shinyWidgets) 
library(ggdark)
library(export)

rm(list = ls())
load("01_data/hfd_data.RData")      #
save.image()

#01 build a language dictionary ####
lang_dict <- list(
  en = list(
    title = "Fertility statistics by countries 1891-2023, Auto-visualization Tool",
    select_variable = "1. Select variable",
    select_countries = "2. Select countries to highlight",
    x_axis_range = "3. X-axis range:",
    y_axis_range = "4. Y-axis range:",
    plot_theme = "5. Plot theme:",
    select_file = "6. Select file",
    download = "Download Plot",
    data_sources = "Data sources: Human Fertility Database. Available at www.humanfertility.org (data updated on April 16th, 2025)",
    note = "Note: The default image size is 800x600 pixels with 300 dpi."
    
  ),
  fi = list(
    title = "Hedelmällisyystilastot maittain 1891-2023, Automaattinen visualisointityökalu",
    select_variable = "1. Valitse muuttuja",
    select_countries = "2. Valitse korostettavat maat",
    x_axis_range = "3. X-akselin väli:",
    y_axis_range = "4. Y-akselin väli:",
    plot_theme = "5. Kaavion teema:",
    select_file = "6. Valitse tiedosto",
    download = "Lataa kaavio",
    data_sources = "Tietolähteet: Human Fertility Database. Saatavilla osoitteessa www.humanfertility.org (tiedot päivitetty Huhtikuussa 16. 2025)",
    note = "Huom: Oletuskuvan koko on 800x600 pikseliä, resoluutio 300 dpi."
    
  )
)


# 04 UI design ####
ui <- fluidPage(
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  
  card(
    fluidRow(
      # Title and data sources
      column(10, 
             tags$div(class = "jumbotron text-center", style = "margin-top: 10px;",
                      tags$h4(textOutput("app_title")),
                      tags$h6(style = "font-size: 12px; color: grey;", textOutput("data_sources")),
                      tags$div(style = "font-size: 12px; color: grey; margin-top: 5px;",
                             "UI/UX Design by",
                             tags$a(href = "https://sites.google.com/view/yuting-li", "@Yuting Li", target = "_blank" ))
      )),
      # Language switch and dark mode switch - right aligned
      column(2, style = "text-align: right; margin-top: 5px;",
             tags$div(
               style = "display: flex; flex-direction: column; align-items: flex-end;",  # Align to the right
               switchInput(
                 inputId = "language_switch",
                 label = tagList(icon("globe")), 
                 onLabel = "Eng",
                 offLabel = "Fin",
                 value = TRUE  # Default to English
               ),
               input_dark_mode(id = "mode")
             )
      )
    )
  ),
  
  fluidRow(
    column(3,
           card(height=635,
             title = "",
             radioButtons("var_type", tags$div(style ="font-weight: bold;", textOutput("select_variable")), 
                          choices = c("Total Fertility Rate (TFR) " = "TFR", 
                                      "Tempo-adjusted TFR" = "adjTFR", 
                                      "Mean age at first birth" = "MAB1", 
                                      "Births to women 35+ (%)" = "birth35plus",
                                      "Completed cohort fertility" = "CCF",
                                      "Childlessness (%)" = "childlessness",
                                      "One child (%)" = "parity1",
                                      "Two children (%)" = "parity2",
                                      "≥Three children (%)" = "parity3+",
                                      "Cohort parity distribution" = "parity"),  
                          selected = "TFR"),
             conditionalPanel(
               condition = "input.var_type == 'parity'",
               checkboxGroupInput("parity_type", textOutput("select_parity_plot"), 
                                  choices = list("Childless" = "childlessness", 
                                                 "One child" = "parity1", 
                                                 "Two children" = "parity2", 
                                                 "≥Three children" = "parity3+"),
                                  selected = "childlessness")),
             selectInput("countries", tags$div(style ="font-weight: bold;",textOutput("select_countries")), 
                         choices = unique(TFR_data$code), 
                         multiple = TRUE,
                         selected = "FIN"),
             sliderInput("x_range",
                         label = tags$div(style ="font-weight: bold;",textOutput("x_axis_range")),
                         min = 1935, max = 2023, value = c(1960, 2023), step = 1),
             sliderInput("y_range", 
                         label = tags$div(style ="font-weight: bold;",textOutput("y_axis_range")), 
                         min = 0, max = 100, value = c(0, 4.5), step = 0.5),
             selectInput("theme_choice", tags$div(style ="font-weight: bold;",textOutput("plot_theme")),
                         choices = c("Classic" = "theme_classic",
                                     "Gray" = "theme_gray",
                                     "Linedraw" = "theme_linedraw",
                                     "Light" = "theme_light",
                                     "Economist" = "theme_economist",
                                     "Stata" = "theme_stata")),
             selectInput("file_type", tags$div(style ="font-weight: bold;",textOutput("select_file")), 
                         choices = c("png" = "png", 
                                     "jpg" = "jpg", 
                                     "pdf" = "pdf", 
                                     "eps" = "eps",
                                     "pptx" = "pptx")),
             tags$div(style = "font-size: 12px;", textOutput("note")),
             downloadButton("download_plot", textOutput("download"))
           )
    ),
    column(9,
           card(
             title = "Plot",
             plotlyOutput("line_plot", height = "600px")
           )
    )
  )
)

# 05 server reactive design####
server <- function(input, output, session) {
  
  observe({
    lang <- if (input$language_switch) "en" else "fi"
    
    output$app_title <- renderText({ lang_dict[[lang]]$title })
    output$data_sources <- renderText({ lang_dict[[lang]]$data_sources })
    output$select_variable <- renderText({ lang_dict[[lang]]$select_variable })
    output$select_countries <- renderText({ lang_dict[[lang]]$select_countries })
    output$x_axis_range <- renderText({ lang_dict[[lang]]$x_axis_range })
    output$y_axis_range <- renderText({ lang_dict[[lang]]$y_axis_range })
    output$select_file <- renderText({ lang_dict[[lang]]$select_file })
    output$plot_theme <- renderText({ lang_dict[[lang]]$plot_theme })
    output$download <- renderText({ lang_dict[[lang]]$download})
    output$note <- renderText({ lang_dict[[lang]]$note })
    
    var_type <- input$var_type
    
    if (var_type == "TFR") { 
      x_min <- min(TFR_data$Year, na.rm = TRUE)
      x_max <- max(TFR_data$Year, na.rm = TRUE)
      updateSliderInput(session, "y_range", min = 0, max = 5, value = c(0, 4.5), step = 0.1)
      updateSliderInput(session, "x_range", min = x_min, max = x_max, value = c(x_min, x_max), step = 1)
    } else if (var_type == "adjTFR") {
      x_min <- min(adjTFR_data$Year, na.rm = TRUE)
      x_max <- max(adjTFR_data$Year, na.rm = TRUE)
      updateSliderInput(session, "y_range", min = 0, max = 5, value = c(0, 4.5), step = 0.1)
      updateSliderInput(session, "x_range", min = x_min, max = x_max, value = c(x_min, x_max), step = 1)
      updateSelectInput(session, "countries", 
                        choices = unique(adjTFR_data$code), 
                        selected = "FIN")
    } else if (var_type == "MAB1") {
      x_min <- min(MAB1_data$Year, na.rm = TRUE)
      x_max <- max(MAB1_data$Year, na.rm = TRUE)
      updateSliderInput(session, "y_range", min = 20, max = 35, value = c(20, 35), step = 0.5)
      updateSliderInput(session, "x_range", min = x_min, max = x_max, value = c(x_min, x_max), step = 1)
      updateSelectInput(session, "countries", 
                        choices = unique(MAB1_data$code), 
                        selected = "FIN")
    } else if (var_type == "CCF") {
      x_min <- min(CCF_data$Cohort, na.rm = TRUE)
      x_max <- max(CCF_data$Cohort, na.rm = TRUE)
      updateSliderInput(session, "y_range", min = 0, max = 5, value = c(0, 4.5), step = 0.1)
      updateSliderInput(session, "x_range", min = x_min, max = x_max, value = c(x_min, x_max), step = 1)
      updateSelectInput(session, "countries", 
                        choices = unique(CCF_data$code), 
                        selected = "FIN")
    } else if (var_type == "childlessness") {
      x_min <- min(PARITY_data$Cohort, na.rm = TRUE)
      x_max <- max(PARITY_data$Cohort, na.rm = TRUE)
      updateSliderInput(session, "y_range", min = 0, max = 100, value = c(0, 100), step = 1)
      updateSliderInput(session, "x_range", min =  x_min, max = x_max, value = c(x_min, x_max), step = 1)
      updateSelectInput(session, "countries", 
                        choices = unique(PARITY_data$code), 
                        selected = "FIN")
    } else if (var_type %in% c("parity1","parity2","parity3+")) {
      x_min <- min(PARITY_data$Cohort, na.rm = TRUE)
      x_max <- max(PARITY_data$Cohort, na.rm = TRUE)
      updateSliderInput(session, "y_range", min = 0, max = 100, value = c(0, 50), step = 1)
      updateSliderInput(session, "x_range", min = x_min, max = x_max, value = c(x_min, x_max), step = 1)
      updateSelectInput(session, "countries", 
                        choices = unique(PARITY_data$code), 
                        selected = "FIN")
    } else if (var_type == "parity") {
      x_min <- min(PARITY_data_long$Cohort, na.rm = TRUE)
      x_max <- max(PARITY_data_long$Cohort, na.rm = TRUE)
      updateSliderInput(session, "y_range", min = 0, max = 100, value = c(0, 100), step = 1)
      updateSliderInput(session, "x_range", min = x_min, max = x_max, value = c(x_min, x_max), step = 1)
      updateSelectInput(session, "countries", 
                        choices = unique(PARITY_data_long$code), 
                        selected = "FIN")
    } else if (var_type == "birth35plus") {
      x_min <- min(asfr_data$Year, na.rm = TRUE)
      x_max <- max(asfr_data$Year, na.rm = TRUE)
      updateSliderInput(session, "y_range", min = 0, max = 100, value = c(0, 50), step = 1)
      updateSliderInput(session, "x_range", min = x_min, max = x_max, value = c(x_min, x_max), step = 1)
      updateSelectInput(session, "countries", 
                        choices = unique(asfr_data$code), 
                        selected = "FIN")
    }
  })
  
  plotData <- reactive({
    selected_countries <- input$countries
    var_type <- input$var_type
    selected_parity_types <- NULL
    
    # Select the appropriate data based on the selected botton by users
    if (var_type == "TFR") {
      data <- TFR_data
      value_col <- "TFR"
      x_col <- "Year"
    } else if (var_type == "adjTFR"){
      data <- adjTFR_data
      value_col <- "adjTFR"
      x_col <- "Year"
    } else if (var_type == "MAB1") {
      data <- MAB1_data
      value_col <- "MAB1"
      x_col <- "Year"
    } else if (var_type == "CCF") {
      data <- CCF_data
      value_col <- "CCF"
      x_col <- "Cohort"
    } else if (var_type == "childlessness") {
      data <- PARITY_data
      value_col <- "childlessness"
      x_col <- "Cohort"
    } else if (var_type == "parity1") {
      data <- PARITY_data
      value_col <- "parity1"
      x_col <- "Cohort"
    } else if (var_type == "parity2") {
      data <- PARITY_data
      value_col <- "parity2"
      x_col <- "Cohort"
    } else if (var_type == "parity3+") {
      data <- PARITY_data
      value_col <- "parity3+"
      x_col <- "Cohort"
    } else if (var_type == "parity") {
      data <- PARITY_data_long
      value_col <- "percentage"
      x_col <- "Cohort"
      selected_parity_types <- input$parity_type
      data <- data %>% filter(parity_type %in% selected_parity_types)
    } else if (var_type == "birth35plus") {
      data <- asfr_data
      value_col <- "proportion_35_above"
      x_col <- "Year"
    }
    
    selected_data <- subset(data, code %in% selected_countries & 
                              data[[x_col]] >= input$x_range[1] & 
                              data[[x_col]] <= input$x_range[2])
    non_selected_countries <- setdiff(unique(data$code), selected_countries)
    non_selected_data <- subset(data, code %in% non_selected_countries & 
                                  data[[x_col]] >= input$x_range[1] & 
                                  data[[x_col]] <= input$x_range[2])
    
    list(selected_data = selected_data, non_selected_data = non_selected_data, value_col = value_col, x_col = x_col)
  })
  
  # Fixed colors for countries. these are colorblind-friendly colors generated by https://medialab.github.io/iwanthue/
  country_colors <- c(
  "FIN"= "red", "DNK"= "yellow", "NOR"= "green",  "ISL"="blue",  "SWE"= "purple",
  "AUT"= "#bac56e","BLR"= "#ff9318", "BEL"="#017ca9","BGR"= "#503e6d", "CAN"= "#3a6e00",
  "CHL"= "#92007e","HRV"= "#71d290", "CZE"="#ff8f76","EST"= "#005abe", "FRATNP"="#fd9cf8",
  "DEUTNP"="#efb18a", "HUN"="#ff87aa","IRL"="#4a4f00","ITA"= "#e4b900", "JPN"= "#a5a9ff",
  "LTU"="#693c12", "NLD"="#b116c3", "POL"= "#ed0054", "PRT"="#1c5126", "KOR"= "#5f279b",
  "RUS"="#d077ff", "SVK"="#f3b344", "SVN"="#297d00", "ESP"="#6acaec", "CHE"="#025ba5",
  "TWN"="#ff5061", "UKR"="#58464f", "GBR_NP"="#005f56", "USA"="#a80044",  "GRC"= "#4081ff",
  "ISR"="#afca31",  "LVA"="#01c572","LUX"="#be0029")
 
  #draw the graph by using ggplot2, customize as you want
  output$line_plot <- renderPlotly({
    data <- plotData()
    selected_data <- data$selected_data
    non_selected_data <- data$non_selected_data
    value_col <- data$value_col
    x_col <- data$x_col
    var_type <- input$var_type
    chosen_theme <- if (input$mode == "dark") {
      dark_theme_bw
    } else {
      match.fun(input$theme_choice)  
    }
    
    if (var_type == "parity") {
      axis_titles <- if (input$language_switch) {
        list(x = "Birth cohort", y = "Share of women (%)")
      } else {
        list(x = "Syntymäkohortti", y = "Osuus naisista (%)")
      }
      gg <- ggplot(selected_data, aes(!!sym(x_col), !!sym(value_col), fill = !!sym("parity_type"))) +
        geom_bar(stat = "identity", position = "stack") +
        scale_fill_manual(values = c("#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3"))+
        facet_wrap(~ code, scales = "free_y") +
        labs(x = axis_titles$x, y = axis_titles$y, fill = "") +
        chosen_theme() +
        theme(axis.title = element_text(size = 18),
              axis.text = element_text(size = 14),
              legend.text = element_text(size = 14),
              legend.title = element_blank(),
              strip.text = element_text(size = 12)) +
        xlim(input$x_range) 
      
    } else {
      if (input$language_switch) {
        axis_titles <- list(
          x = ifelse(input$var_type %in% c("CCF", "childlessness","parity1","parity2","parity3+"), "Birth cohort", "Year"),
          y = switch(input$var_type,
                     "TFR" = " Total Fertility Rate (TFR)",
                     "adjTFR" = " Tempo-adjusted TFR",
                     "MAB1" = "Mean age at first birth",
                     "CCF" = "Completed cohort fertility",
                     "parity1" = "One child (%)",
                     "parity2" = "Two children (%)",
                     "parity3+" = "≥Three children (%)",
                     "birth35plus" = " Births to women aged 35+ (%)",
                     "Childlessness (%)")
        )
      } else {
        axis_titles <- list(
          x = ifelse(input$var_type %in% c("CCF", "childlessness","parity1","parity2","parity3+"), "Syntymäkohortti", "Vuosi"),
          y = switch(input$var_type,
                     "TFR" = "Kokonaishedelmällisyysluku (TFR)",
                     "adjTFR" = " Tempo-adjustoitu TFR",
                     "MAB1" = "Ikä ensimmäisen lapsen syntyessä",
                     "CCF" = "Lasten lukumäärä",
                     "parity1" = "Yksi lapsi (%)",
                     "parity2" = "Kaksi lasta (%)",
                     "parity3+" = "Vähintään kolme lasta (%)",
                     "birth35plus" = "Osuus syntyneistä 35+ äideille (%)",
                     "Lapsettomuus (%)")
        )
      }
      gg <- ggplot() +       
        geom_line(data = non_selected_data, 
                  aes(!!sym(x_col), !!sym(value_col), group = !!sym("code")), 
                  color = "grey", 
                  linewidth = 0.25,
                  na.rm = TRUE) +
        geom_line(data = selected_data, 
                  aes(!!sym(x_col), !!sym(value_col), 
                      color = !!sym("code")), 
                  linewidth = 1,
                  na.rm = TRUE) +
        scale_color_manual(values = country_colors) +
        chosen_theme() +
        theme(axis.title = element_text(size = 18),
              axis.text = element_text(size = 14),
              legend.text = element_text(size = 14)) +
        labs(x = axis_titles$x, y = axis_titles$y)+
        ylim(input$y_range) +
        xlim(input$x_range) +
        guides(color = guide_legend(title = NULL), linetype = guide_legend(title = NULL)) 
    }
    ggplotly(gg, width = 800,
             height = 600) 
    
  }) 
  
  # Prepare for selected graph output
  output$download_plot <- downloadHandler(
    filename = function() {
      paste("plot", Sys.time(), ".", input$file_type, sep = "")
    },
    content = function(file) {
      data <- plotData()
      var_type <- input$var_type
      selected_data <- data$selected_data
      non_selected_data <- data$non_selected_data
      value_col <- data$value_col
      x_col <- data$x_col
      chosen_theme <- if (input$mode == "dark") {
        dark_theme_bw
      } else {
        match.fun(input$theme_choice)  
      }
      
      if (var_type == "parity") {
        axis_titles <- if (input$language_switch) {
          list(x = "Cohort year of birth", y = "Percentage (%)")
        } else {
          list(x = "Syntymäkohortti", y = "Osuus naisista (%)")
        }
        gg <- ggplot(selected_data, aes(!!sym(x_col), !!sym(value_col), fill = !!sym("parity_type"))) +
          geom_bar(stat = "identity", position = "stack") +
          scale_fill_manual(values = c("#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3")) +
          facet_wrap(~ code, scales = "free_y") +
          labs(x = axis_titles$x, y = axis_titles$y, fill = "") +
          chosen_theme() +
          theme(axis.title = element_text(size = 18),
                axis.text = element_text(size = 14),
                legend.text = element_text(size = 14),
                legend.title = element_blank(),
                strip.text = element_text(size = 12)) +
          xlim(input$x_range) 
        
      } else {
        if (input$language_switch) {
          axis_titles <- list(
            x = ifelse(input$var_type %in% c("CCF", "childlessness","parity1","parity2","parity3+"), "Birth cohort", "Year"),
            y = switch(input$var_type,
                       "TFR" = " Total Fertility Rate (TFR)",
                       "adjTFR" = " Tempo-adjusted TFR",
                       "MAB1" = "Mean age at first birth",
                       "CCF" = "Completed cohort fertility",
                       "parity1" = "One child (%)",
                       "parity2" = "Two children (%)",
                       "parity3+" = "≥Three children (%)",
                       "birth35plus" = " Births to women aged 35+ (%)",
                       "Childlessness (%)")
          )
        } else {
          axis_titles <- list(
            x = ifelse(input$var_type %in% c("CCF", "childlessness","parity1","parity2","parity3+"), "Syntymäkohortti", "Vuosi"),
            y = switch(input$var_type,
                       "TFR" = "Kokonaishedelmällisyysluku (TFR)",
                       "adjTFR" = "Tempo-adjustoitu TFR",
                       "MAB1" = "Ikä ensimmäisen lapsen syntyessä",
                       "CCF" = "Lasten lukumäärä",
                       "parity1" = "Yksi lapsi (%)",
                       "parity2" = "Kaksi lasta (%)",
                       "parity3+" = "Vähintään kolme lasta (%)",
                       "birth35plus" = "Osuus syntyneistä 35+ äideille (%)",
                       "Lapsettomuus (%)")
          )
        }
        gg <- ggplot() +       
          geom_line(data = non_selected_data, 
                    aes(!!sym(x_col), !!sym(value_col), group = !!sym("code")), 
                    color = "grey", 
                    linewidth = 0.25,
                    na.rm = TRUE) +
          geom_line(data = selected_data, 
                    aes(!!sym(x_col), !!sym(value_col), 
                        color = !!sym("code")), 
                    linewidth = 1,
                    na.rm = TRUE) +
          scale_color_manual(values = country_colors) +
          chosen_theme() +
          theme(axis.title = element_text(size = 18),
                axis.text = element_text(size = 14),
                legend.text = element_text(size = 14)) +
          labs(x = axis_titles$x, y = axis_titles$y)+
          ylim(input$y_range) +
          xlim(input$x_range) +
          guides(color = guide_legend(title = NULL), linetype = guide_legend(title = NULL)) 
      }
      
      # Save the plot in your chosen format with a size suitable for publication, set the graph format (defalt:8inch*6inch with 300 dpi)
      if (input$file_type == "png") {
        png(file, width = 8, height = 6, units = "in", res = 300)  
        print(gg)
        dev.off()
      } else if (input$file_type == "jpg") {
        jpeg(file, width = 8, height = 6, units = "in", res = 300)
        print(gg)
        dev.off()
      } else if (input$file_type == "pdf") {
        pdf(file, width = 8, height = 6)
        print(gg)
        dev.off()
      } else if (input$file_type == "eps") {
        postscript(file, width = 8, height = 6, horizontal = FALSE, paper = "special", colormodel = "rgb")
        print(gg)
        dev.off() 
      } else if (input$file_type == "pptx") {
        graph2ppt(gg,file=file, width= 8, height= 6)
      }
    }
  )
}

# 06 Run the application####
shinyApp(ui = ui, server = server)
