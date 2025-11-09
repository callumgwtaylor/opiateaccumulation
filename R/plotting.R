# ==============================================================================
# Plotting Functions for Opioid PK Visualization
# ==============================================================================
#
# This module contains ggplot2-based visualization functions for pharmacokinetic
# simulations. All plots follow publication-quality standards with clear labels,
# appropriate scales, and professional theming.
#
# Required packages: ggplot2, dplyr, scales
#
# Author: Claude Code
# Date: 2025-11-09
# ==============================================================================

# Required libraries (to be loaded by app.R)
# library(ggplot2)
# library(dplyr)
# library(scales)

#' Plot Concentration-Time Curve for Single Drug
#'
#' Creates a concentration-time plot showing drug accumulation with repeated
#' dosing. Marks dosing times and steady-state achievement.
#'
#' @param concentration_data Data frame. Output from simulate_drug_profile()
#' @param title Character. Plot title (optional)
#' @param show_doses Logical. Whether to mark dose times with vertical lines
#' @param show_steady_state Logical. Whether to mark steady-state time
#' @param steady_state_time Numeric. Time to steady state in hours
#' @return ggplot object
plot_concentration_curve <- function(concentration_data,
                                    title = NULL,
                                    show_doses = TRUE,
                                    show_steady_state = TRUE,
                                    steady_state_time = NULL) {
  # Create base plot
  p <- ggplot(concentration_data, aes(x = time, y = concentration_ng_mL)) +
    geom_line(color = "#2C3E50", size = 1.2) +
    labs(
      title = title,
      x = "Time (hours)",
      y = "Plasma Concentration (ng/mL)"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(size = 10),
      panel.grid.minor = element_line(linetype = "dotted", color = "gray90"),
      panel.grid.major = element_line(color = "gray85")
    )

  # Add dosing time markers
  if (show_doses && "dose_number" %in% names(concentration_data)) {
    # Find dose times (when dose_number changes)
    dose_times <- concentration_data %>%
      group_by(dose_number) %>%
      summarize(dose_time = min(time)) %>%
      pull(dose_time)

    # Add vertical lines at dose times
    p <- p + geom_vline(xintercept = dose_times,
                       linetype = "dashed",
                       color = "gray60",
                       alpha = 0.5)
  }

  # Add steady-state marker
  if (show_steady_state && !is.null(steady_state_time)) {
    p <- p +
      geom_vline(xintercept = steady_state_time,
                linetype = "solid",
                color = "#E74C3C",
                size = 0.8) +
      annotate("text",
              x = steady_state_time,
              y = max(concentration_data$concentration_ng_mL) * 0.9,
              label = "Steady State",
              angle = 90,
              vjust = -0.5,
              color = "#E74C3C",
              fontface = "bold")
  }

  return(p)
}


#' Plot Multiple Drug Comparison
#'
#' Creates a multi-line plot comparing concentration profiles of different drugs.
#'
#' @param profile_list List. Named list of concentration data frames
#' @param title Character. Plot title
#' @param show_doses Logical. Whether to mark dose times
#' @return ggplot object
plot_drug_comparison <- function(profile_list,
                                title = "Opioid Concentration Comparison",
                                show_doses = TRUE) {
  # Combine all profiles into single data frame
  combined_data <- bind_rows(profile_list, .id = "drug_id")

  # Define color palette for drugs
  drug_colors <- c(
    "Morphine" = "#3498DB",    # Blue
    "Oxycodone" = "#2ECC71",   # Green
    "Alfentanil" = "#E74C3C"   # Red
  )

  # Create plot
  p <- ggplot(combined_data, aes(x = time, y = concentration_ng_mL,
                                 color = drug, group = drug)) +
    geom_line(size = 1.2) +
    scale_color_manual(values = drug_colors) +
    labs(
      title = title,
      x = "Time (hours)",
      y = "Plasma Concentration (ng/mL)",
      color = "Drug"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(size = 10),
      legend.position = "right",
      legend.title = element_text(face = "bold"),
      legend.text = element_text(size = 10),
      panel.grid.minor = element_line(linetype = "dotted", color = "gray90"),
      panel.grid.major = element_line(color = "gray85")
    )

  # Add dosing markers for first drug only (to avoid clutter)
  if (show_doses) {
    first_drug_data <- profile_list[[1]]
    if ("dose_number" %in% names(first_drug_data)) {
      dose_times <- first_drug_data %>%
        group_by(dose_number) %>%
        summarize(dose_time = min(time)) %>%
        pull(dose_time)

      p <- p + geom_vline(xintercept = dose_times,
                         linetype = "dashed",
                         color = "gray60",
                         alpha = 0.3)
    }
  }

  return(p)
}


#' Plot Morphine-Equivalent Comparison
#'
#' Plots all drugs on a morphine-equivalent scale to show relative effectiveness
#' accounting for both concentration and potency.
#'
#' @param profile_list List. Named list of concentration data frames
#' @param title Character. Plot title
#' @return ggplot object
plot_morphine_equivalent <- function(profile_list,
                                    title = "Morphine-Equivalent Comparison") {
  # Combine all profiles
  combined_data <- bind_rows(profile_list, .id = "drug_id")

  # Drug colors
  drug_colors <- c(
    "Morphine" = "#3498DB",
    "Oxycodone" = "#2ECC71",
    "Alfentanil" = "#E74C3C"
  )

  # Create plot
  p <- ggplot(combined_data, aes(x = time, y = morphine_equivalent_ng_mL,
                                 color = drug, group = drug)) +
    geom_line(size = 1.2) +
    scale_color_manual(values = drug_colors) +
    labs(
      title = title,
      x = "Time (hours)",
      y = "Morphine-Equivalent Concentration (ng/mL)",
      color = "Drug",
      subtitle = "All concentrations normalized to morphine-equivalent potency"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray40"),
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(size = 10),
      legend.position = "right",
      legend.title = element_text(face = "bold"),
      panel.grid.minor = element_line(linetype = "dotted", color = "gray90"),
      panel.grid.major = element_line(color = "gray85")
    )

  return(p)
}


#' Plot Accumulation Factor Comparison
#'
#' Creates a bar chart comparing accumulation factors for different drugs.
#'
#' @param summary_list List. Named list of clinical summaries
#' @param title Character. Plot title
#' @return ggplot object
plot_accumulation_comparison <- function(summary_list,
                                        title = "Drug Accumulation Comparison") {
  # Extract accumulation factors
  accumulation_data <- data.frame(
    drug = character(),
    accumulation = numeric(),
    stringsAsFactors = FALSE
  )

  for (name in names(summary_list)) {
    accumulation_data <- rbind(
      accumulation_data,
      data.frame(
        drug = summary_list[[name]]$drug,
        accumulation = summary_list[[name]]$accumulation_factor,
        stringsAsFactors = FALSE
      )
    )
  }

  # Drug colors
  drug_colors <- c(
    "Morphine" = "#3498DB",
    "Oxycodone" = "#2ECC71",
    "Alfentanil" = "#E74C3C"
  )

  # Create bar plot
  p <- ggplot(accumulation_data, aes(x = drug, y = accumulation, fill = drug)) +
    geom_bar(stat = "identity", width = 0.6) +
    geom_text(aes(label = sprintf("%.2f", accumulation)),
             vjust = -0.5,
             size = 5,
             fontface = "bold") +
    scale_fill_manual(values = drug_colors) +
    labs(
      title = title,
      x = "Drug",
      y = "Accumulation Factor",
      subtitle = "Ratio of steady-state to single-dose concentration"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray40"),
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(size = 10),
      legend.position = "none",
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank()
    ) +
    ylim(0, max(accumulation_data$accumulation) * 1.15)

  return(p)
}


#' Plot Peak and Trough Comparison
#'
#' Creates a grouped bar chart showing steady-state peak and trough levels.
#'
#' @param summary_list List. Named list of clinical summaries
#' @param use_morphine_eq Logical. Use morphine-equivalent concentrations
#' @param title Character. Plot title
#' @return ggplot object
plot_peak_trough_comparison <- function(summary_list,
                                       use_morphine_eq = TRUE,
                                       title = "Steady-State Peak and Trough Levels") {
  # Extract peak and trough data
  peak_trough_data <- data.frame(
    drug = character(),
    type = character(),
    concentration = numeric(),
    stringsAsFactors = FALSE
  )

  for (name in names(summary_list)) {
    drug_name <- summary_list[[name]]$drug

    if (use_morphine_eq) {
      peak_val <- summary_list[[name]]$cmax_morphine_eq
      trough_val <- summary_list[[name]]$cmin_morphine_eq
    } else {
      peak_val <- summary_list[[name]]$cmax_ss
      trough_val <- summary_list[[name]]$cmin_ss
    }

    peak_trough_data <- rbind(
      peak_trough_data,
      data.frame(
        drug = drug_name,
        type = "Peak (Cmax)",
        concentration = peak_val,
        stringsAsFactors = FALSE
      ),
      data.frame(
        drug = drug_name,
        type = "Trough (Cmin)",
        concentration = trough_val,
        stringsAsFactors = FALSE
      )
    )
  }

  # Create grouped bar plot
  p <- ggplot(peak_trough_data, aes(x = drug, y = concentration, fill = type)) +
    geom_bar(stat = "identity", position = position_dodge(width = 0.8), width = 0.7) +
    geom_text(aes(label = sprintf("%.1f", concentration)),
             position = position_dodge(width = 0.8),
             vjust = -0.5,
             size = 3.5) +
    scale_fill_manual(values = c("Peak (Cmax)" = "#E67E22",
                                 "Trough (Cmin)" = "#95A5A6")) +
    labs(
      title = title,
      x = "Drug",
      y = if (use_morphine_eq) "Morphine-Equivalent Concentration (ng/mL)" else "Concentration (ng/mL)",
      fill = "Measurement"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(size = 10),
      legend.position = "right",
      legend.title = element_text(face = "bold"),
      panel.grid.major.x = element_blank()
    ) +
    ylim(0, max(peak_trough_data$concentration) * 1.15)

  return(p)
}


#' Plot Time to Steady State Comparison
#'
#' Creates a bar chart showing time to reach steady state for each drug.
#'
#' @param summary_list List. Named list of clinical summaries
#' @param title Character. Plot title
#' @return ggplot object
plot_time_to_steady_state <- function(summary_list,
                                      title = "Time to Steady State") {
  # Extract time to steady state data
  ss_time_data <- data.frame(
    drug = character(),
    time_to_ss = numeric(),
    stringsAsFactors = FALSE
  )

  for (name in names(summary_list)) {
    ss_time_data <- rbind(
      ss_time_data,
      data.frame(
        drug = summary_list[[name]]$drug,
        time_to_ss = summary_list[[name]]$time_to_steady_state,
        stringsAsFactors = FALSE
      )
    )
  }

  # Drug colors
  drug_colors <- c(
    "Morphine" = "#3498DB",
    "Oxycodone" = "#2ECC71",
    "Alfentanil" = "#E74C3C"
  )

  # Create bar plot
  p <- ggplot(ss_time_data, aes(x = drug, y = time_to_ss, fill = drug)) +
    geom_bar(stat = "identity", width = 0.6) +
    geom_text(aes(label = sprintf("%.1f hr", time_to_ss)),
             vjust = -0.5,
             size = 4.5,
             fontface = "bold") +
    scale_fill_manual(values = drug_colors) +
    labs(
      title = title,
      x = "Drug",
      y = "Time to Steady State (hours)",
      subtitle = "Time to reach 97% of steady-state concentration"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray40"),
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(size = 10),
      legend.position = "none",
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank()
    ) +
    ylim(0, max(ss_time_data$time_to_ss) * 1.15)

  return(p)
}


#' Plot Renal Function Impact
#'
#' Shows how renal function affects drug accumulation for a single drug.
#'
#' @param drug_name Character. Drug name
#' @param dose_mg Numeric. Dose in mg
#' @param interval_hours Numeric. Dosing interval
#' @param duration_hours Numeric. Simulation duration
#' @param patient_weight Numeric. Patient weight in kg
#' @param title Character. Plot title
#' @return ggplot object
plot_renal_function_impact <- function(drug_name, dose_mg, interval_hours,
                                      duration_hours, patient_weight,
                                      title = NULL) {
  if (is.null(title)) {
    title <- sprintf("%s: Impact of Renal Function", drug_name)
  }

  # Simulate for different renal function levels
  renal_categories <- c("normal", "mild", "moderate", "severe")
  # Load CrCl values from CSV
  renal_crcl <- c(
    get_param_value("general", "normal_crcl"),
    get_param_value("general", "mild_crcl"),
    get_param_value("general", "moderate_crcl"),
    get_param_value("general", "severe_crcl")
  )

  all_profiles <- list()

  for (i in seq_along(renal_categories)) {
    patient <- create_patient_params(
      weight = patient_weight,
      creatinine_clearance = renal_crcl[i],
      renal_function = renal_categories[i]
    )

    profile <- simulate_drug_profile(
      drug_name = drug_name,
      dose_mg = dose_mg,
      interval_hours = interval_hours,
      duration_hours = duration_hours,
      patient_params = patient
    )

    profile$renal_function <- paste0(tools::toTitleCase(renal_categories[i]),
                                     " (CrCl=", renal_crcl[i], ")")

    all_profiles[[i]] <- profile
  }

  # Combine data
  combined_data <- bind_rows(all_profiles)

  # Create plot
  p <- ggplot(combined_data, aes(x = time, y = concentration_ng_mL,
                                 color = renal_function,
                                 group = renal_function)) +
    geom_line(size = 1.2) +
    scale_color_viridis_d(option = "plasma", end = 0.9) +
    labs(
      title = title,
      x = "Time (hours)",
      y = "Plasma Concentration (ng/mL)",
      color = "Renal Function",
      subtitle = sprintf("Dose: %.1f mg every %g hours", dose_mg, interval_hours)
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray40"),
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(size = 10),
      legend.position = "right",
      legend.title = element_text(face = "bold"),
      panel.grid.minor = element_line(linetype = "dotted", color = "gray90")
    )

  return(p)
}


#' Create Summary Table Plot
#'
#' Creates a formatted table visualization of key pharmacokinetic parameters.
#'
#' @param summary_list List. Named list of clinical summaries
#' @return Grid table object
create_summary_table <- function(summary_list) {
  # Extract data for table
  table_data <- data.frame(
    Drug = character(),
    `Half-life (hr)` = numeric(),
    `Accumulation` = numeric(),
    `Cmax (ng/mL)` = numeric(),
    `Cmin (ng/mL)` = numeric(),
    `Time to SS (hr)` = numeric(),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )

  for (name in names(summary_list)) {
    s <- summary_list[[name]]
    table_data <- rbind(
      table_data,
      data.frame(
        Drug = s$drug,
        `Half-life (hr)` = round(s$half_life, 1),
        `Accumulation` = round(s$accumulation_factor, 2),
        `Cmax (ng/mL)` = round(s$cmax_morphine_eq, 1),
        `Cmin (ng/mL)` = round(s$cmin_morphine_eq, 1),
        `Time to SS (hr)` = round(s$time_to_steady_state, 1),
        check.names = FALSE,
        stringsAsFactors = FALSE
      )
    )
  }

  return(table_data)
}
