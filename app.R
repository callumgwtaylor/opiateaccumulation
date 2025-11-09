# ==============================================================================
# Opioid Pharmacokinetic Comparison Tool - Shiny Application
# ==============================================================================
#
# Interactive tool for comparing pharmacokinetic profiles of morphine,
# oxycodone, and alfentanil in palliative care settings.
#
# This application demonstrates how drug accumulation patterns offset
# differences in potency, particularly in patients with renal impairment.
#
# Author: Claude Code
# Date: 2025-11-09
# ==============================================================================

# Load required packages
library(shiny)
library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(DT)

# Source all R modules
source("R/pk_models.R")
source("R/drug_parameters.R")
source("R/utils.R")
source("R/plotting.R")

# ==============================================================================
# USER INTERFACE
# ==============================================================================

ui <- fluidPage(
  # Application title
  titlePanel(
    div(
      h2("Opioid Pharmacokinetic Comparison Tool", style = "margin-bottom: 5px;"),
      h4("Demonstrating Accumulation vs. Potency in Palliative Care",
         style = "color: #7f8c8d; font-weight: normal; margin-top: 0;")
    )
  ),

  # Sidebar layout
  sidebarLayout(
    # Sidebar panel with inputs
    sidebarPanel(
      width = 3,

      # Drug selection
      h4("Drug Selection", style = "font-weight: bold; color: #2c3e50;"),
      checkboxGroupInput(
        "drugs_selected",
        "Select Drugs to Compare:",
        choices = c("Morphine" = "morphine",
                   "Oxycodone" = "oxycodone",
                   "Alfentanil" = "alfentanil"),
        selected = c("morphine", "alfentanil")
      ),

      hr(),

      # Patient parameters
      h4("Patient Parameters", style = "font-weight: bold; color: #2c3e50;"),
      numericInput("patient_weight", "Weight (kg):", value = 70,
                  min = 30, max = 150, step = 5),
      numericInput("patient_age", "Age (years):", value = 65,
                  min = 18, max = 100, step = 1),

      selectInput("renal_function", "Renal Function:",
                 choices = c("Normal" = "normal",
                           "Mild Impairment" = "mild",
                           "Moderate Impairment" = "moderate",
                           "Severe Impairment" = "severe"),
                 selected = "normal"),

      numericInput("creatinine_clearance", "Creatinine Clearance (mL/min):",
                  value = 90, min = 5, max = 150, step = 5),

      hr(),

      # Dosing parameters
      h4("Dosing Parameters", style = "font-weight: bold; color: #2c3e50;"),

      selectInput("route", "Route of Administration:",
                 choices = c("Intravenous (IV)" = "IV",
                           "Subcutaneous (SC)" = "SC"),
                 selected = "IV"),

      numericInput("dose_morphine", "Morphine Dose (mg):",
                  value = 10, min = 1, max = 100, step = 1),

      numericInput("dose_oxycodone", "Oxycodone Dose (mg):",
                  value = 7, min = 1, max = 100, step = 1),

      numericInput("dose_alfentanil", "Alfentanil Dose (mg):",
                  value = 1, min = 0.1, max = 10, step = 0.1),

      numericInput("dosing_interval", "Dosing Interval (hours):",
                  value = 4, min = 1, max = 24, step = 1),

      numericInput("simulation_duration", "Simulation Duration (hours):",
                  value = 72, min = 12, max = 168, step = 12),

      hr(),

      # Action button
      actionButton("run_simulation", "Run Simulation",
                  class = "btn-primary btn-lg",
                  style = "width: 100%; font-weight: bold;")
    ),

    # Main panel with tabs
    mainPanel(
      width = 9,

      tabsetPanel(
        type = "tabs",
        id = "main_tabs",

        # Tab 1: Concentration Curves
        tabPanel(
          "Concentration Curves",
          br(),
          h4("Individual Drug Concentration Profiles",
             style = "font-weight: bold; text-align: center;"),
          p("This plot shows the actual plasma concentrations over time for each selected drug.",
            style = "text-align: center; color: #7f8c8d;"),
          plotOutput("plot_concentration", height = "500px"),
          br(),
          p("Vertical dashed lines indicate dosing times. Drugs with longer half-lives show greater accumulation.",
            style = "font-style: italic; color: #95a5a6; text-align: center;")
        ),

        # Tab 2: Morphine Equivalents
        tabPanel(
          "Morphine Equivalents",
          br(),
          h4("Morphine-Equivalent Concentration Comparison",
             style = "font-weight: bold; text-align: center;"),
          p("All concentrations normalized to morphine-equivalent potency for fair comparison.",
            style = "text-align: center; color: #7f8c8d;"),
          plotOutput("plot_morphine_eq", height = "500px"),
          br(),
          div(
            style = "background-color: #ecf0f1; padding: 15px; border-radius: 5px;",
            h5("Key Insight:", style = "font-weight: bold; color: #2c3e50;"),
            p("Despite alfentanil's 15x higher potency, morphine's greater accumulation can lead to similar or higher morphine-equivalent levels at steady state.",
              style = "margin: 0;")
          )
        ),

        # Tab 3: Accumulation Analysis
        tabPanel(
          "Accumulation Analysis",
          br(),
          h4("Drug Accumulation Metrics", style = "font-weight: bold; text-align: center;"),
          br(),
          fluidRow(
            column(6, plotOutput("plot_accumulation", height = "400px")),
            column(6, plotOutput("plot_time_to_ss", height = "400px"))
          ),
          br(),
          fluidRow(
            column(12, plotOutput("plot_peak_trough", height = "400px"))
          )
        ),

        # Tab 4: Clinical Summary
        tabPanel(
          "Clinical Summary",
          br(),
          h4("Pharmacokinetic Summary and Recommendations",
             style = "font-weight: bold; text-align: center;"),
          br(),
          uiOutput("clinical_summary_ui")
        ),

        # Tab 5: Parameter Table
        tabPanel(
          "Parameter Table",
          br(),
          h4("Detailed Pharmacokinetic Parameters",
             style = "font-weight: bold; text-align: center;"),
          br(),
          DTOutput("parameter_table"),
          br(),
          h5("Patient Parameters", style = "font-weight: bold;"),
          verbatimTextOutput("patient_info")
        ),

        # Tab 6: Renal Impact
        tabPanel(
          "Renal Impact",
          br(),
          h4("Effect of Renal Function on Drug Accumulation",
             style = "font-weight: bold; text-align: center;"),
          p("Compare how renal impairment affects accumulation for each drug.",
            style = "text-align: center; color: #7f8c8d;"),
          br(),
          selectInput("renal_impact_drug", "Select Drug:",
                     choices = c("Morphine" = "morphine",
                               "Oxycodone" = "oxycodone",
                               "Alfentanil" = "alfentanil"),
                     selected = "morphine"),
          plotOutput("plot_renal_impact", height = "500px"),
          br(),
          div(
            style = "background-color: #fff3cd; padding: 15px; border-radius: 5px; border-left: 4px solid #ffc107;",
            h5("Clinical Note:", style = "font-weight: bold; color: #856404;"),
            uiOutput("renal_impact_note")
          )
        ),

        # Tab 7: About
        tabPanel(
          "About",
          br(),
          h3("About This Tool", style = "font-weight: bold;"),
          p("This interactive pharmacokinetic simulation tool compares three opioids commonly used in palliative care: morphine, oxycodone, and alfentanil."),

          h4("Purpose", style = "font-weight: bold; margin-top: 20px;"),
          p("The tool demonstrates how drug accumulation patterns offset differences in potency, particularly showing how morphine's slower clearance leads to accumulation that can compensate for alfentanil's higher potency."),

          h4("Key Clinical Points", style = "font-weight: bold; margin-top: 20px;"),
          tags$ul(
            tags$li("Alfentanil is ~15x more potent than morphine per mg"),
            tags$li("Morphine has a longer half-life (3-4 hours) vs alfentanil (1.5 hours)"),
            tags$li("With repeated dosing, morphine accumulates significantly while alfentanil reaches steady state quickly"),
            tags$li("In renal failure, morphine and its active metabolite (M6G) accumulate dangerously"),
            tags$li("Alfentanil is preferred in severe renal impairment due to hepatic metabolism")
          ),

          h4("Model Information", style = "font-weight: bold; margin-top: 20px;"),
          p("This tool uses a one-compartment pharmacokinetic model with first-order elimination kinetics. Parameters are based on published literature including:"),
          tags$ul(
            tags$li("Lotsch et al. (2002) - Morphine population pharmacokinetics"),
            tags$li("Saari et al. (2012) - Oxycodone pharmacokinetic parameters"),
            tags$li("Maitre et al. (1987) - Alfentanil compartmental model"),
            tags$li("Palliative Care Formulary - Equianalgesic ratios")
          ),

          h4("Disclaimer", style = "font-weight: bold; margin-top: 20px;"),
          div(
            style = "background-color: #f8d7da; padding: 15px; border-radius: 5px; border-left: 4px solid #dc3545;",
            p("This tool is for educational purposes only. Clinical decisions should be made by qualified healthcare professionals considering individual patient factors, clinical context, and local guidelines.", style = "margin: 0; color: #721c24;")
          ),

          h4("Technical Information", style = "font-weight: bold; margin-top: 20px;"),
          p("Built with R and Shiny. Source code includes comprehensive documentation and follows best practices for transparent, reproducible pharmacokinetic modeling."),

          p("Version 1.0 | Created: 2025-11-09", style = "margin-top: 30px; color: #95a5a6; font-style: italic;")
        )
      )
    )
  )
)

# ==============================================================================
# SERVER LOGIC
# ==============================================================================

server <- function(input, output, session) {

  # Reactive values to store simulation results
  simulation_results <- reactiveValues(
    profiles = NULL,
    summaries = NULL,
    patient = NULL
  )

  # Run simulation when button is clicked
  observeEvent(input$run_simulation, {

    # Validate inputs
    if (length(input$drugs_selected) == 0) {
      showNotification("Please select at least one drug.", type = "error")
      return()
    }

    # Create patient parameters
    patient_params <- create_patient_params(
      weight = input$patient_weight,
      age = input$patient_age,
      creatinine_clearance = input$creatinine_clearance,
      renal_function = input$renal_function
    )

    # Store patient params
    simulation_results$patient <- patient_params

    # Initialize storage
    profiles <- list()
    summaries <- list()

    # Define doses for each drug
    doses <- list(
      morphine = input$dose_morphine,
      oxycodone = input$dose_oxycodone,
      alfentanil = input$dose_alfentanil
    )

    # Run simulation for each selected drug
    for (drug in input$drugs_selected) {
      tryCatch({
        # Simulate concentration profile
        profile <- simulate_drug_profile(
          drug_name = drug,
          dose_mg = doses[[drug]],
          interval_hours = input$dosing_interval,
          duration_hours = input$simulation_duration,
          patient_params = patient_params,
          route = input$route
        )
        profiles[[drug]] <- profile

        # Generate clinical summary
        summary <- generate_clinical_summary(
          drug_name = drug,
          dose_mg = doses[[drug]],
          interval_hours = input$dosing_interval,
          patient_params = patient_params,
          route = input$route
        )
        summaries[[drug]] <- summary

      }, error = function(e) {
        showNotification(paste("Error simulating", drug, ":", e$message),
                        type = "error")
      })
    }

    # Store results
    simulation_results$profiles <- profiles
    simulation_results$summaries <- summaries

    # Show success notification
    showNotification("Simulation completed successfully!",
                    type = "message",
                    duration = 3)
  })

  # Plot: Concentration curves
  output$plot_concentration <- renderPlot({
    req(simulation_results$profiles)

    if (length(simulation_results$profiles) == 0) {
      return(NULL)
    }

    plot_drug_comparison(
      profile_list = simulation_results$profiles,
      title = "Plasma Concentration Over Time",
      show_doses = TRUE
    )
  })

  # Plot: Morphine equivalents
  output$plot_morphine_eq <- renderPlot({
    req(simulation_results$profiles)

    if (length(simulation_results$profiles) == 0) {
      return(NULL)
    }

    plot_morphine_equivalent(
      profile_list = simulation_results$profiles,
      title = "Morphine-Equivalent Concentration Comparison"
    )
  })

  # Plot: Accumulation factors
  output$plot_accumulation <- renderPlot({
    req(simulation_results$summaries)

    if (length(simulation_results$summaries) == 0) {
      return(NULL)
    }

    plot_accumulation_comparison(
      summary_list = simulation_results$summaries,
      title = "Accumulation Factor Comparison"
    )
  })

  # Plot: Time to steady state
  output$plot_time_to_ss <- renderPlot({
    req(simulation_results$summaries)

    if (length(simulation_results$summaries) == 0) {
      return(NULL)
    }

    plot_time_to_steady_state(
      summary_list = simulation_results$summaries,
      title = "Time to Steady State"
    )
  })

  # Plot: Peak and trough
  output$plot_peak_trough <- renderPlot({
    req(simulation_results$summaries)

    if (length(simulation_results$summaries) == 0) {
      return(NULL)
    }

    plot_peak_trough_comparison(
      summary_list = simulation_results$summaries,
      use_morphine_eq = TRUE,
      title = "Steady-State Peak and Trough (Morphine Equivalents)"
    )
  })

  # Clinical summary UI
  output$clinical_summary_ui <- renderUI({
    req(simulation_results$summaries)

    if (length(simulation_results$summaries) == 0) {
      return(p("Run a simulation to see clinical summary.",
               style = "text-align: center; color: #95a5a6; margin-top: 50px;"))
    }

    summary_boxes <- lapply(names(simulation_results$summaries), function(drug) {
      s <- simulation_results$summaries[[drug]]

      # Generate warnings
      warnings <- generate_warnings(
        drug_name = drug,
        patient_params = simulation_results$patient,
        concentration = s$cmax_ss
      )

      # Create box color based on warnings
      box_color <- if (length(warnings) > 0 && grepl("CONTRAINDICATED", warnings[1])) {
        "#f8d7da"
      } else if (length(warnings) > 0) {
        "#fff3cd"
      } else {
        "#d4edda"
      }

      border_color <- if (length(warnings) > 0 && grepl("CONTRAINDICATED", warnings[1])) {
        "#dc3545"
      } else if (length(warnings) > 0) {
        "#ffc107"
      } else {
        "#28a745"
      }

      div(
        style = sprintf("background-color: %s; padding: 20px; margin-bottom: 20px; border-radius: 5px; border-left: 5px solid %s;",
                       box_color, border_color),
        h3(s$drug, style = "margin-top: 0; font-weight: bold;"),

        # Key parameters
        fluidRow(
          column(4,
                h5("Dosing", style = "font-weight: bold;"),
                p(sprintf("Dose: %.1f mg %s", s$dose, s$route)),
                p(sprintf("Interval: %g hours", s$interval)),
                p(sprintf("Daily dose: %.1f mg", s$total_daily_dose))
          ),
          column(4,
                h5("Pharmacokinetics", style = "font-weight: bold;"),
                p(sprintf("Half-life: %.1f hours", s$half_life)),
                p(sprintf("Accumulation: %.2f×", s$accumulation_factor)),
                p(sprintf("Time to SS: %.1f hours", s$time_to_steady_state))
          ),
          column(4,
                h5("Steady State", style = "font-weight: bold;"),
                p(sprintf("Peak: %.1f ng/mL", s$cmax_ss)),
                p(sprintf("Trough: %.1f ng/mL", s$cmin_ss)),
                p(sprintf("ME Peak: %.1f ng/mL", s$cmax_morphine_eq))
          )
        ),

        # Loading dose recommendation
        if (s$accumulation_factor > 1.5) {
          div(
            style = "margin-top: 15px; padding: 10px; background-color: rgba(255,255,255,0.5); border-radius: 3px;",
            h5("Loading Dose Recommendation:", style = "font-weight: bold; margin-top: 0;"),
            p(sprintf("To achieve immediate steady-state levels, consider loading dose: %.1f mg",
                     s$loading_dose))
          )
        },

        # Warnings
        if (length(warnings) > 0) {
          div(
            style = "margin-top: 15px; padding: 10px; background-color: rgba(255,255,255,0.7); border-radius: 3px;",
            h5("Clinical Alerts:", style = "font-weight: bold; margin-top: 0;"),
            lapply(warnings, function(w) p(w, style = "margin: 5px 0;"))
          )
        },

        # Interpretation
        div(
          style = "margin-top: 15px; padding: 10px; background-color: rgba(255,255,255,0.5); border-radius: 3px;",
          h5("Clinical Interpretation:", style = "font-weight: bold; margin-top: 0;"),
          lapply(s$interpretation, function(i) p(i, style = "margin: 5px 0;"))
        )
      )
    })

    do.call(tagList, summary_boxes)
  })

  # Parameter table
  output$parameter_table <- renderDT({
    req(simulation_results$summaries)

    if (length(simulation_results$summaries) == 0) {
      return(NULL)
    }

    table_data <- create_summary_table(simulation_results$summaries)

    datatable(
      table_data,
      options = list(
        dom = 't',
        pageLength = 10,
        ordering = FALSE
      ),
      rownames = FALSE
    ) %>%
      formatRound(columns = c(2:6), digits = 1)
  })

  # Patient info
  output$patient_info <- renderText({
    req(simulation_results$patient)

    p <- simulation_results$patient

    paste0(
      "Weight: ", p$weight, " kg\n",
      "Age: ", p$age, " years\n",
      "Creatinine Clearance: ", p$creatinine_clearance, " mL/min\n",
      "Renal Function: ", tools::toTitleCase(p$renal_function), "\n",
      "Hepatic Function: ", tools::toTitleCase(p$hepatic_function)
    )
  })

  # Renal impact plot
  output$plot_renal_impact <- renderPlot({
    req(input$renal_impact_drug)

    # Get dose for selected drug
    doses <- list(
      morphine = input$dose_morphine,
      oxycodone = input$dose_oxycodone,
      alfentanil = input$dose_alfentanil
    )

    plot_renal_function_impact(
      drug_name = input$renal_impact_drug,
      dose_mg = doses[[input$renal_impact_drug]],
      interval_hours = input$dosing_interval,
      duration_hours = min(input$simulation_duration, 72),  # Limit to 72hr for clarity
      patient_weight = input$patient_weight
    )
  })

  # Renal impact note
  output$renal_impact_note <- renderUI({
    req(input$renal_impact_drug)

    drug_params <- get_drug_params(input$renal_impact_drug)

    note_text <- if (drug_params$name == "Morphine") {
      "Morphine shows dramatic accumulation in renal impairment. The active metabolite M6G accumulates even more, reaching dangerous levels. Morphine is contraindicated in severe renal failure."
    } else if (drug_params$name == "Oxycodone") {
      "Oxycodone accumulates moderately in renal impairment. Dose reduction of 25-50% is recommended in moderate to severe renal impairment."
    } else {
      "Alfentanil is minimally affected by renal function due to predominantly hepatic metabolism. It is the safest option in renal failure and typically requires no dose adjustment."
    }

    p(note_text, style = "margin: 0;")
  })

}

# ==============================================================================
# RUN APPLICATION
# ==============================================================================

shinyApp(ui = ui, server = server)
