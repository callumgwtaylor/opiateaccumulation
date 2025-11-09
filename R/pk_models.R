# ==============================================================================
# Pharmacokinetic Models for Opioid Comparison
# ==============================================================================
#
# This module implements one-compartment pharmacokinetic models for simulating
# opioid drug concentrations over time with repeated dosing.
#
# Core Concepts:
# - One-compartment model: Drug distributes instantaneously into a single volume
# - First-order elimination: Rate of elimination proportional to concentration
# - Accumulation: Build-up of drug with repeated dosing before reaching steady state
# - Steady state: When rate of drug input equals rate of elimination
#
# Author: Claude Code
# Date: 2025-11-09
# ==============================================================================

#' Calculate Elimination Rate Constant
#'
#' Calculates the elimination rate constant (ke) from half-life using
#' first-order kinetics. The elimination rate constant determines how
#' quickly a drug is removed from the body.
#'
#' @param half_life Numeric. Drug half-life in hours
#' @return Numeric. Elimination rate constant (1/hour)
#' @examples
#' calculate_ke(3)  # Morphine with 3-hour half-life
#' calculate_ke(1.5) # Alfentanil with 1.5-hour half-life
calculate_ke <- function(half_life) {
  # Validate input
  if (!is.numeric(half_life) || half_life <= 0) {
    stop("half_life must be a positive number")
  }

  # Formula: ke = ln(2) / t½ = 0.693 / t½
  ke <- 0.693 / half_life
  return(ke)
}


#' Calculate Accumulation Factor
#'
#' Calculates the accumulation factor for repeated dosing at regular intervals.
#' This factor indicates how much the drug will accumulate compared to a
#' single dose when given repeatedly at steady state.
#'
#' For example:
#' - Accumulation factor of 1.5 means drug levels will be 50% higher at steady state
#' - Accumulation factor of 3.0 means drug levels will be 3x higher at steady state
#'
#' @param half_life Numeric. Drug half-life in hours
#' @param dosing_interval Numeric. Time between doses in hours
#' @return Numeric. Accumulation factor (dimensionless)
#' @examples
#' # Morphine (t½=3h) given every 4 hours
#' calculate_accumulation(half_life = 3, dosing_interval = 4)
calculate_accumulation <- function(half_life, dosing_interval) {
  # Validate inputs
  if (!is.numeric(half_life) || half_life <= 0) {
    stop("half_life must be a positive number")
  }
  if (!is.numeric(dosing_interval) || dosing_interval <= 0) {
    stop("dosing_interval must be a positive number")
  }

  # Calculate elimination rate constant
  ke <- calculate_ke(half_life)

  # Formula: R = 1 / (1 - e^(-ke × τ))
  # where R is accumulation factor and τ is dosing interval
  accumulation <- 1 / (1 - exp(-ke * dosing_interval))

  return(accumulation)
}


#' Calculate Plasma Concentration - Single IV Bolus Dose
#'
#' Calculates plasma concentration at a given time after a single intravenous
#' bolus dose using a one-compartment model with first-order elimination.
#'
#' Formula: C(t) = (Dose / Vd) × e^(-ke × t)
#' where:
#'   C(t) = concentration at time t
#'   Dose = dose administered (mg)
#'   Vd = volume of distribution (L)
#'   ke = elimination rate constant (1/hr)
#'   t = time after dose (hr)
#'
#' @param dose Numeric. Dose administered in mg
#' @param volume_distribution Numeric. Volume of distribution in liters
#' @param half_life Numeric. Drug half-life in hours
#' @param time Numeric vector. Time point(s) in hours after dose
#' @return Numeric vector. Plasma concentration(s) in mg/L at specified time(s)
calculate_concentration_single <- function(dose, volume_distribution,
                                          half_life, time) {
  # Validate inputs
  if (!is.numeric(dose) || dose < 0) {
    stop("dose must be a non-negative number")
  }
  if (!is.numeric(volume_distribution) || volume_distribution <= 0) {
    stop("volume_distribution must be a positive number")
  }
  if (!is.numeric(half_life) || half_life <= 0) {
    stop("half_life must be a positive number")
  }
  if (!is.numeric(time) || any(time < 0)) {
    stop("time must be non-negative")
  }

  # Calculate elimination rate constant
  ke <- calculate_ke(half_life)

  # Calculate initial concentration (C0) immediately after dose
  c0 <- dose / volume_distribution

  # Calculate concentration at time t using exponential decay
  concentration <- c0 * exp(-ke * time)

  return(concentration)
}


#' Calculate Plasma Concentration - Repeated Dosing
#'
#' Simulates plasma concentration over time with repeated dosing at regular
#' intervals. This accounts for drug accumulation as concentrations from
#' previous doses sum with new doses.
#'
#' @param dose Numeric. Dose per administration in mg
#' @param volume_distribution Numeric. Volume of distribution in liters
#' @param half_life Numeric. Drug half-life in hours
#' @param dosing_interval Numeric. Time between doses in hours
#' @param simulation_duration Numeric. Total simulation time in hours
#' @param time_step Numeric. Time resolution for simulation in hours (default 0.1)
#' @return Data frame with columns: time (hours), concentration (mg/L),
#'         dose_number (which dose interval)
calculate_concentration_repeated <- function(dose, volume_distribution,
                                            half_life, dosing_interval,
                                            simulation_duration,
                                            time_step = 0.1) {
  # Validate inputs
  if (!is.numeric(dose) || dose < 0) {
    stop("dose must be a non-negative number")
  }
  if (!is.numeric(volume_distribution) || volume_distribution <= 0) {
    stop("volume_distribution must be a positive number")
  }
  if (!is.numeric(half_life) || half_life <= 0) {
    stop("half_life must be a positive number")
  }
  if (!is.numeric(dosing_interval) || dosing_interval <= 0) {
    stop("dosing_interval must be a positive number")
  }
  if (!is.numeric(simulation_duration) || simulation_duration <= 0) {
    stop("simulation_duration must be a positive number")
  }

  # Calculate elimination rate constant
  ke <- calculate_ke(half_life)

  # Create time vector
  time_points <- seq(0, simulation_duration, by = time_step)
  n_points <- length(time_points)

  # Initialize concentration vector
  concentration <- numeric(n_points)

  # Calculate dosing times
  dose_times <- seq(0, simulation_duration, by = dosing_interval)

  # For each time point, sum contributions from all previous doses
  for (i in seq_along(time_points)) {
    t <- time_points[i]

    # Find all doses that have been given by time t
    doses_given <- dose_times[dose_times <= t]

    # Sum concentration contributions from each dose
    for (dose_time in doses_given) {
      time_since_dose <- t - dose_time
      c0 <- dose / volume_distribution
      concentration[i] <- concentration[i] + c0 * exp(-ke * time_since_dose)
    }
  }

  # Create dose number (which dosing interval are we in?)
  dose_number <- floor(time_points / dosing_interval) + 1

  # Return as data frame
  result <- data.frame(
    time = time_points,
    concentration = concentration,
    dose_number = dose_number
  )

  return(result)
}


#' Calculate Time to Steady State
#'
#' Calculates the approximate time required to reach steady state (typically
#' defined as 97% of steady-state concentration, which occurs at ~5 half-lives).
#'
#' @param half_life Numeric. Drug half-life in hours
#' @param proportion Numeric. Proportion of steady state (default loaded from CSV)
#' @return Numeric. Time to reach specified proportion of steady state in hours
calculate_time_to_steady_state <- function(half_life, proportion = NULL) {
  # Load default from CSV if not provided
  if (is.null(proportion)) {
    proportion <- get_param_value("general", "steady_state_threshold")
  }
  # Validate inputs
  if (!is.numeric(half_life) || half_life <= 0) {
    stop("half_life must be a positive number")
  }
  if (!is.numeric(proportion) || proportion <= 0 || proportion >= 1) {
    stop("proportion must be between 0 and 1")
  }

  # Calculate number of half-lives needed
  # Formula: t = -ln(1 - proportion) / ke = -ln(1 - proportion) × t½ / 0.693
  n_half_lives <- -log(1 - proportion) / 0.693

  # Calculate time
  time_to_ss <- n_half_lives * half_life

  return(time_to_ss)
}


#' Calculate Steady State Peak and Trough Concentrations
#'
#' Calculates the maximum (peak) and minimum (trough) plasma concentrations
#' at steady state for regular repeated dosing.
#'
#' Peak occurs immediately after dose administration.
#' Trough occurs immediately before the next dose.
#'
#' @param dose Numeric. Dose per administration in mg
#' @param volume_distribution Numeric. Volume of distribution in liters
#' @param half_life Numeric. Drug half-life in hours
#' @param dosing_interval Numeric. Time between doses in hours
#' @return List with Cmax_ss (peak) and Cmin_ss (trough) in mg/L, and
#'         fluctuation ratio
calculate_steady_state_levels <- function(dose, volume_distribution,
                                         half_life, dosing_interval) {
  # Validate inputs
  if (!is.numeric(dose) || dose < 0) {
    stop("dose must be a non-negative number")
  }
  if (!is.numeric(volume_distribution) || volume_distribution <= 0) {
    stop("volume_distribution must be a positive number")
  }
  if (!is.numeric(half_life) || half_life <= 0) {
    stop("half_life must be a positive number")
  }
  if (!is.numeric(dosing_interval) || dosing_interval <= 0) {
    stop("dosing_interval must be a positive number")
  }

  # Calculate elimination rate constant
  ke <- calculate_ke(half_life)

  # Calculate initial concentration from single dose
  c0 <- dose / volume_distribution

  # Calculate accumulation factor
  R <- calculate_accumulation(half_life, dosing_interval)

  # Steady-state peak (immediately after dose)
  # Cmax,ss = C0 × R
  cmax_ss <- c0 * R

  # Steady-state trough (immediately before next dose)
  # Cmin,ss = Cmax,ss × e^(-ke × τ)
  cmin_ss <- cmax_ss * exp(-ke * dosing_interval)

  # Calculate fluctuation (swing) between peak and trough
  fluctuation <- cmax_ss / cmin_ss

  # Calculate average steady-state concentration
  # Cavg,ss = (Cmax,ss - Cmin,ss) / (ke × τ)
  cavg_ss <- (cmax_ss - cmin_ss) / (ke * dosing_interval)

  return(list(
    cmax_ss = cmax_ss,
    cmin_ss = cmin_ss,
    cavg_ss = cavg_ss,
    fluctuation = fluctuation,
    accumulation_factor = R
  ))
}


#' Calculate Loading Dose
#'
#' Calculates a loading dose to immediately achieve steady-state concentration.
#' The loading dose is the regular maintenance dose multiplied by the
#' accumulation factor.
#'
#' @param maintenance_dose Numeric. Regular maintenance dose in mg
#' @param half_life Numeric. Drug half-life in hours
#' @param dosing_interval Numeric. Time between maintenance doses in hours
#' @return Numeric. Loading dose in mg
calculate_loading_dose <- function(maintenance_dose, half_life, dosing_interval) {
  # Validate inputs
  if (!is.numeric(maintenance_dose) || maintenance_dose < 0) {
    stop("maintenance_dose must be a non-negative number")
  }
  if (!is.numeric(half_life) || half_life <= 0) {
    stop("half_life must be a positive number")
  }
  if (!is.numeric(dosing_interval) || dosing_interval <= 0) {
    stop("dosing_interval must be a positive number")
  }

  # Calculate accumulation factor
  R <- calculate_accumulation(half_life, dosing_interval)

  # Loading dose = Maintenance dose × Accumulation factor
  loading_dose <- maintenance_dose * R

  return(loading_dose)
}


#' Adjust Pharmacokinetic Parameters for Renal Function
#'
#' Adjusts clearance and half-life based on creatinine clearance for
#' renally eliminated drugs. Uses a linear relationship between renal
#' function and drug clearance.
#'
#' @param clearance_normal Numeric. Normal clearance in L/hr
#' @param half_life_normal Numeric. Normal half-life in hours
#' @param creatinine_clearance Numeric. Patient's CrCl in mL/min
#' @param normal_creatinine_clearance Numeric. Normal CrCl reference (default loaded from CSV)
#' @param fraction_renal Numeric. Fraction of drug eliminated renally (0-1)
#' @return List with adjusted clearance and half_life
adjust_for_renal_function <- function(clearance_normal, half_life_normal,
                                     creatinine_clearance,
                                     normal_creatinine_clearance = NULL,
                                     fraction_renal = 0.9) {
  # Load default from CSV if not provided
  if (is.null(normal_creatinine_clearance)) {
    normal_creatinine_clearance <- get_param_value("general", "normal_crcl")
  }
  # Validate inputs
  if (!is.numeric(clearance_normal) || clearance_normal <= 0) {
    stop("clearance_normal must be a positive number")
  }
  if (!is.numeric(half_life_normal) || half_life_normal <= 0) {
    stop("half_life_normal must be a positive number")
  }
  if (!is.numeric(creatinine_clearance) || creatinine_clearance < 0) {
    stop("creatinine_clearance must be a non-negative number")
  }
  if (!is.numeric(fraction_renal) || fraction_renal < 0 || fraction_renal > 1) {
    stop("fraction_renal must be between 0 and 1")
  }

  # Calculate renal clearance and non-renal clearance
  cl_renal <- clearance_normal * fraction_renal
  cl_non_renal <- clearance_normal * (1 - fraction_renal)

  # Adjust renal clearance based on CrCl ratio
  cl_renal_adjusted <- cl_renal * (creatinine_clearance / normal_creatinine_clearance)

  # Total adjusted clearance
  clearance_adjusted <- cl_renal_adjusted + cl_non_renal

  # Adjust half-life (inversely proportional to clearance)
  # Since t½ = (0.693 × Vd) / Cl
  # If only clearance changes: t½_adjusted / t½_normal = Cl_normal / Cl_adjusted
  half_life_adjusted <- half_life_normal * (clearance_normal / clearance_adjusted)

  return(list(
    clearance_adjusted = clearance_adjusted,
    half_life_adjusted = half_life_adjusted,
    clearance_reduction_percent = (1 - clearance_adjusted / clearance_normal) * 100
  ))
}


#' Convert Concentration to Morphine Equivalents
#'
#' Converts plasma concentration of any opioid to morphine-equivalent
#' concentration based on relative potency ratios.
#'
#' @param concentration Numeric. Plasma concentration in mg/L
#' @param potency_ratio Numeric. Potency relative to morphine (morphine = 1)
#' @return Numeric. Morphine-equivalent concentration in mg/L
convert_to_morphine_equivalent <- function(concentration, potency_ratio) {
  # Validate inputs
  if (!is.numeric(concentration) || any(concentration < 0)) {
    stop("concentration must be non-negative")
  }
  if (!is.numeric(potency_ratio) || potency_ratio <= 0) {
    stop("potency_ratio must be a positive number")
  }

  # Morphine equivalent = concentration × potency ratio
  morphine_eq <- concentration * potency_ratio

  return(morphine_eq)
}


#' Calculate Area Under the Curve (AUC)
#'
#' Calculates the area under the concentration-time curve using the
#' trapezoidal rule. AUC represents total drug exposure.
#'
#' @param time Numeric vector. Time points
#' @param concentration Numeric vector. Concentrations at each time point
#' @return Numeric. AUC in mg*hr/L
calculate_auc <- function(time, concentration) {
  # Validate inputs
  if (!is.numeric(time) || !is.numeric(concentration)) {
    stop("time and concentration must be numeric vectors")
  }
  if (length(time) != length(concentration)) {
    stop("time and concentration must have the same length")
  }
  if (length(time) < 2) {
    stop("Need at least 2 time points to calculate AUC")
  }

  # Calculate AUC using trapezoidal rule
  # AUC = sum of trapezoid areas = sum((C[i] + C[i+1]) / 2 * (t[i+1] - t[i]))
  n <- length(time)
  auc <- 0

  for (i in 1:(n-1)) {
    dt <- time[i+1] - time[i]
    avg_conc <- (concentration[i] + concentration[i+1]) / 2
    auc <- auc + avg_conc * dt
  }

  return(auc)
}
