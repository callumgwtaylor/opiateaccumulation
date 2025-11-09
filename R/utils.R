# ==============================================================================
# Utility Functions for Opioid PK Comparison
# ==============================================================================
#
# This module contains helper functions for formatting output, generating
# clinical summaries, and other utility operations.
#
# Author: Claude Code
# Date: 2025-11-09
# ==============================================================================

# Required libraries (to be loaded by app.R)
# library(dplyr)
# library(tidyr)

#' Simulate Drug Concentration Profile
#'
#' High-level wrapper function that simulates complete drug concentration
#' profile for a given drug, patient, and dosing regimen.
#'
#' @param drug_name Character. Name of drug ("morphine", "oxycodone", "alfentanil")
#' @param dose_mg Numeric. Dose in milligrams
#' @param interval_hours Numeric. Dosing interval in hours
#' @param duration_hours Numeric. Simulation duration in hours
#' @param patient_params List. Patient parameters from create_patient_params()
#' @param route Character. Route of administration ("IV" or "SC")
#' @return Data frame with time, concentration, and morphine-equivalent columns
simulate_drug_profile <- function(drug_name, dose_mg, interval_hours,
                                 duration_hours, patient_params,
                                 route = "IV") {
  # Load drug parameters
  drug_params <- get_drug_params(drug_name)

  # Adjust for patient characteristics
  adjusted_params <- adjust_drug_params_for_patient(
    drug_params,
    patient_weight = patient_params$weight,
    creatinine_clearance = patient_params$creatinine_clearance,
    renal_category = patient_params$renal_function
  )

  # Adjust dose for bioavailability if subcutaneous
  effective_dose <- dose_mg
  if (toupper(route) == "SC") {
    effective_dose <- dose_mg * drug_params$bioavailability_sc
  }

  # Calculate concentration profile
  profile <- calculate_concentration_repeated(
    dose = effective_dose,
    volume_distribution = adjusted_params$volume_distribution_total,
    half_life = adjusted_params$half_life_adjusted,
    dosing_interval = interval_hours,
    simulation_duration = duration_hours,
    time_step = 0.1
  )

  # Add drug name and morphine equivalents
  profile$drug <- drug_params$name
  profile$concentration_mg_L <- profile$concentration
  profile$concentration_ng_mL <- profile$concentration * 1000  # Convert mg/L to ng/mL

  # Calculate morphine-equivalent concentration
  profile$morphine_equivalent_ng_mL <- convert_to_morphine_equivalent(
    profile$concentration_ng_mL,
    drug_params$potency_ratio
  )

  return(profile)
}


#' Generate Clinical Summary
#'
#' Creates a comprehensive clinical summary of the pharmacokinetic simulation
#' including steady-state levels, accumulation, and clinical recommendations.
#'
#' @param drug_name Character. Name of drug
#' @param dose_mg Numeric. Dose in milligrams
#' @param interval_hours Numeric. Dosing interval in hours
#' @param patient_params List. Patient parameters
#' @param route Character. Route of administration
#' @return List with clinical summary information
generate_clinical_summary <- function(drug_name, dose_mg, interval_hours,
                                     patient_params, route = "IV") {
  # Load and adjust drug parameters
  drug_params <- get_drug_params(drug_name)
  adjusted_params <- adjust_drug_params_for_patient(
    drug_params,
    patient_weight = patient_params$weight,
    creatinine_clearance = patient_params$creatinine_clearance,
    renal_category = patient_params$renal_function
  )

  # Adjust dose for bioavailability
  effective_dose <- dose_mg
  if (toupper(route) == "SC") {
    effective_dose <- dose_mg * drug_params$bioavailability_sc
  }

  # Calculate steady-state levels
  ss_levels <- calculate_steady_state_levels(
    dose = effective_dose,
    volume_distribution = adjusted_params$volume_distribution_total,
    half_life = adjusted_params$half_life_adjusted,
    dosing_interval = interval_hours
  )

  # Calculate time to steady state
  time_to_ss <- calculate_time_to_steady_state(adjusted_params$half_life_adjusted)

  # Calculate loading dose if needed
  loading_dose <- calculate_loading_dose(
    maintenance_dose = dose_mg,
    half_life = adjusted_params$half_life_adjusted,
    dosing_interval = interval_hours
  )

  # Convert to ng/mL for display
  ss_levels$cmax_ss_ng_mL <- ss_levels$cmax_ss * 1000
  ss_levels$cmin_ss_ng_mL <- ss_levels$cmin_ss * 1000
  ss_levels$cavg_ss_ng_mL <- ss_levels$cavg_ss * 1000

  # Calculate morphine equivalents
  ss_levels$cmax_morphine_eq <- ss_levels$cmax_ss_ng_mL * drug_params$potency_ratio
  ss_levels$cmin_morphine_eq <- ss_levels$cmin_ss_ng_mL * drug_params$potency_ratio

  # Calculate total daily dose
  doses_per_day <- 24 / interval_hours
  total_daily_dose <- dose_mg * doses_per_day

  # Generate clinical interpretation
  interpretation <- generate_interpretation(
    drug_name = drug_params$name,
    accumulation_factor = ss_levels$accumulation_factor,
    renal_function = patient_params$renal_function,
    has_active_metabolite = drug_params$has_active_metabolite
  )

  # Compile summary
  summary <- list(
    drug = drug_params$name,
    dose = dose_mg,
    route = route,
    interval = interval_hours,
    effective_dose = effective_dose,

    # Pharmacokinetic parameters
    half_life = adjusted_params$half_life_adjusted,
    volume_distribution = adjusted_params$volume_distribution_total,
    accumulation_factor = ss_levels$accumulation_factor,

    # Steady-state levels
    cmax_ss = ss_levels$cmax_ss_ng_mL,
    cmin_ss = ss_levels$cmin_ss_ng_mL,
    cavg_ss = ss_levels$cavg_ss_ng_mL,
    fluctuation = ss_levels$fluctuation,

    # Morphine equivalents
    cmax_morphine_eq = ss_levels$cmax_morphine_eq,
    cmin_morphine_eq = ss_levels$cmin_morphine_eq,

    # Timing
    time_to_steady_state = time_to_ss,
    doses_to_steady_state = time_to_ss / interval_hours,

    # Dosing recommendations
    loading_dose = loading_dose,
    total_daily_dose = total_daily_dose,

    # Clinical interpretation
    interpretation = interpretation
  )

  return(summary)
}


#' Generate Clinical Interpretation
#'
#' Creates text-based clinical interpretation and recommendations.
#'
#' @param drug_name Character. Drug name
#' @param accumulation_factor Numeric. Accumulation factor
#' @param renal_function Character. Renal function category
#' @param has_active_metabolite Logical. Whether drug has active metabolites
#' @return Character vector with interpretation points
generate_interpretation <- function(drug_name, accumulation_factor,
                                   renal_function, has_active_metabolite) {
  interpretation <- c()

  # Accumulation interpretation
  if (accumulation_factor < 1.5) {
    interpretation <- c(interpretation,
      sprintf("Minimal accumulation (factor: %.2f). Drug reaches steady state quickly with minimal build-up.",
              accumulation_factor))
  } else if (accumulation_factor < 2.5) {
    interpretation <- c(interpretation,
      sprintf("Moderate accumulation (factor: %.2f). Expect steady state in 3-5 doses.",
              accumulation_factor))
  } else {
    interpretation <- c(interpretation,
      sprintf("Significant accumulation (factor: %.2f). Concentrations will increase substantially with repeated dosing.",
              accumulation_factor))
  }

  # Renal function considerations
  if (renal_function %in% c("moderate", "severe", "dialysis")) {
    if (drug_name == "Morphine" && has_active_metabolite) {
      interpretation <- c(interpretation,
        "⚠️ WARNING: Morphine and M6G accumulation in renal impairment. High risk of prolonged sedation and respiratory depression. Consider alternative opioid.")
    } else if (drug_name == "Oxycodone") {
      interpretation <- c(interpretation,
        "⚠️ CAUTION: Dose reduction recommended in renal impairment. Monitor closely for adverse effects.")
    } else if (drug_name == "Alfentanil") {
      interpretation <- c(interpretation,
        "✓ SAFE: Alfentanil is minimally affected by renal impairment. Preferred option in this setting.")
    }
  }

  # Drug-specific notes
  if (drug_name == "Alfentanil") {
    interpretation <- c(interpretation,
      "NOTE: Short half-life requires frequent dosing or continuous infusion for sustained effect.")
  }

  return(interpretation)
}


#' Format Concentration for Display
#'
#' Formats concentration values for human-readable display.
#'
#' @param concentration Numeric. Concentration value
#' @param unit Character. Unit ("ng/mL" or "mg/L")
#' @param digits Integer. Number of decimal places
#' @return Character. Formatted concentration string
format_concentration <- function(concentration, unit = "ng/mL", digits = 1) {
  sprintf(paste0("%.", digits, "f %s"), concentration, unit)
}


#' Format Time for Display
#'
#' Formats time values for human-readable display.
#'
#' @param hours Numeric. Time in hours
#' @return Character. Formatted time string
format_time <- function(hours) {
  if (hours < 1) {
    sprintf("%.0f minutes", hours * 60)
  } else if (hours < 24) {
    sprintf("%.1f hours", hours)
  } else {
    days <- floor(hours / 24)
    remaining_hours <- hours %% 24
    if (remaining_hours == 0) {
      sprintf("%d days", days)
    } else {
      sprintf("%d days, %.1f hours", days, remaining_hours)
    }
  }
}


#' Calculate Equianalgesic Dose
#'
#' Calculates equivalent dose when switching between opioids.
#'
#' @param current_drug Character. Current drug name
#' @param current_dose Numeric. Current dose in mg
#' @param target_drug Character. Target drug name
#' @return List with target dose and conversion ratio
calculate_equianalgesic_dose <- function(current_drug, current_dose, target_drug) {
  # Get potency ratios
  current_params <- get_drug_params(current_drug)
  target_params <- get_drug_params(target_drug)

  # Calculate conversion
  # Convert current drug to morphine equivalents, then to target drug
  morphine_eq <- current_dose * current_params$potency_ratio
  target_dose <- morphine_eq / target_params$potency_ratio

  # Calculate direct conversion ratio
  conversion_ratio <- target_dose / current_dose

  result <- list(
    from_drug = current_params$name,
    from_dose = current_dose,
    to_drug = target_params$name,
    to_dose = target_dose,
    conversion_ratio = conversion_ratio,
    morphine_equivalent = morphine_eq,
    note = sprintf("%.1f mg %s ≈ %.1f mg %s (via %.1f mg morphine equivalent)",
                   current_dose, current_params$name,
                   target_dose, target_params$name,
                   morphine_eq)
  )

  return(result)
}


#' Create Comparison Table
#'
#' Creates a comparison table for multiple drug simulations.
#'
#' @param simulation_list List. List of simulation summaries
#' @return Data frame with comparison metrics
create_comparison_table <- function(simulation_list) {
  # Extract key metrics from each simulation
  comparison <- data.frame(
    Drug = character(),
    Dose_mg = numeric(),
    Interval_hr = numeric(),
    HalfLife_hr = numeric(),
    Accumulation = numeric(),
    Cmax_ng_mL = numeric(),
    Cmin_ng_mL = numeric(),
    Cmax_MorphineEq = numeric(),
    TimeToSS_hr = numeric(),
    stringsAsFactors = FALSE
  )

  for (sim in simulation_list) {
    row <- data.frame(
      Drug = sim$drug,
      Dose_mg = sim$dose,
      Interval_hr = sim$interval,
      HalfLife_hr = round(sim$half_life, 1),
      Accumulation = round(sim$accumulation_factor, 2),
      Cmax_ng_mL = round(sim$cmax_ss, 1),
      Cmin_ng_mL = round(sim$cmin_ss, 1),
      Cmax_MorphineEq = round(sim$cmax_morphine_eq, 1),
      TimeToSS_hr = round(sim$time_to_steady_state, 1),
      stringsAsFactors = FALSE
    )
    comparison <- rbind(comparison, row)
  }

  return(comparison)
}


#' Estimate Creatinine Clearance (Cockcroft-Gault)
#'
#' Estimates creatinine clearance using the Cockcroft-Gault equation.
#'
#' @param age Numeric. Age in years
#' @param weight Numeric. Weight in kg
#' @param serum_creatinine Numeric. Serum creatinine in mg/dL
#' @param sex Character. "male" or "female"
#' @return Numeric. Estimated CrCl in mL/min
estimate_creatinine_clearance <- function(age, weight, serum_creatinine,
                                         sex = "male") {
  # Validate inputs
  if (!is.numeric(age) || age <= 0) {
    stop("age must be a positive number")
  }
  if (!is.numeric(weight) || weight <= 0) {
    stop("weight must be a positive number")
  }
  if (!is.numeric(serum_creatinine) || serum_creatinine <= 0) {
    stop("serum_creatinine must be a positive number")
  }

  sex <- tolower(sex)
  if (!sex %in% c("male", "female")) {
    stop("sex must be 'male' or 'female'")
  }

  # Cockcroft-Gault equation
  # CrCl = ((140 - age) × weight) / (72 × SCr) × 0.85 (if female)
  crcl <- ((140 - age) * weight) / (72 * serum_creatinine)

  if (sex == "female") {
    crcl <- crcl * 0.85
  }

  return(crcl)
}


#' Categorize Renal Function
#'
#' Categorizes renal function based on creatinine clearance.
#'
#' @param creatinine_clearance Numeric. CrCl in mL/min
#' @return Character. Renal function category
categorize_renal_function <- function(creatinine_clearance) {
  if (!is.numeric(creatinine_clearance) || creatinine_clearance < 0) {
    stop("creatinine_clearance must be a non-negative number")
  }

  category <- if (creatinine_clearance >= 80) {
    "normal"
  } else if (creatinine_clearance >= 50) {
    "mild"
  } else if (creatinine_clearance >= 30) {
    "moderate"
  } else if (creatinine_clearance >= 10) {
    "severe"
  } else {
    "dialysis"
  }

  return(category)
}


#' Generate Warning Messages
#'
#' Generates appropriate warning messages based on drug choice and
#' patient characteristics.
#'
#' @param drug_name Character. Drug name
#' @param patient_params List. Patient parameters
#' @param concentration Numeric. Peak concentration
#' @return Character vector. Warning messages (empty if no warnings)
generate_warnings <- function(drug_name, patient_params, concentration = NULL) {
  warnings <- c()

  drug_params <- get_drug_params(drug_name)

  # Check renal function warnings
  if (patient_params$renal_function %in% c("severe", "dialysis")) {
    if (drug_name == "morphine") {
      warnings <- c(warnings,
        "🔴 CONTRAINDICATED: Morphine should be avoided in severe renal impairment due to M6G accumulation.")
    } else if (drug_name == "oxycodone") {
      warnings <- c(warnings,
        "🟡 USE WITH CAUTION: Oxycodone requires significant dose reduction in severe renal impairment.")
    }
  } else if (patient_params$renal_function == "moderate") {
    if (drug_name == "morphine") {
      warnings <- c(warnings,
        "🟡 CAUTION: Consider dose reduction and extended intervals for morphine in moderate renal impairment.")
    }
  }

  # Check concentration warnings if provided
  if (!is.null(concentration) && !is.null(drug_params$toxic_concentration)) {
    if (concentration > drug_params$toxic_concentration) {
      warnings <- c(warnings,
        sprintf("🔴 TOXIC LEVEL: Concentration (%.1f ng/mL) exceeds toxic threshold (%.1f ng/mL).",
                concentration, drug_params$toxic_concentration))
    } else if (concentration > drug_params$therapeutic_max) {
      warnings <- c(warnings,
        sprintf("🟡 HIGH LEVEL: Concentration (%.1f ng/mL) above therapeutic range.",
                concentration))
    } else if (concentration < drug_params$therapeutic_min) {
      warnings <- c(warnings,
        sprintf("🟡 LOW LEVEL: Concentration (%.1f ng/mL) below therapeutic range.",
                concentration))
    }
  }

  return(warnings)
}
