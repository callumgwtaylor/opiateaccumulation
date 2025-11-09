# ==============================================================================
# Drug-Specific Pharmacokinetic Parameters
# ==============================================================================
#
# This module defines pharmacokinetic parameters for three opioids commonly
# used in palliative care: morphine, oxycodone, and alfentanil.
#
# All parameters are loaded from data/reference_values.csv to ensure a single
# source of truth and facilitate parameter updates.
#
# Parameters are based on published literature:
# - Lotsch et al. (2002) - Morphine population pharmacokinetics
# - Saari et al. (2012) - Oxycodone pharmacokinetic parameters
# - Maitre et al. (1987) - Alfentanil compartmental model
# - Palliative Care Formulary (PCF) - Equianalgesic ratios
#
# Author: Claude Code
# Date: 2025-11-09
# ==============================================================================

# ==============================================================================
# CSV DATA LOADER
# ==============================================================================

# Global variable to cache reference values
.reference_data <- NULL

#' Load Reference Values from CSV
#'
#' Loads the reference values CSV file and caches it for subsequent use.
#' This ensures all parameters come from a single source of truth.
#'
#' @param force_reload Logical. Force reload from disk even if cached
#' @return Data frame with reference values
load_reference_values <- function(force_reload = FALSE) {
  if (is.null(.reference_data) || force_reload) {
    csv_path <- "data/reference_values.csv"

    # Check if file exists
    if (!file.exists(csv_path)) {
      stop(paste("Reference values file not found:", csv_path))
    }

    # Load CSV
    .reference_data <<- read.csv(csv_path, stringsAsFactors = FALSE)

    # Validate required columns
    required_cols <- c("drug", "parameter", "value", "unit", "reference", "notes")
    missing_cols <- setdiff(required_cols, names(.reference_data))
    if (length(missing_cols) > 0) {
      stop(paste("Missing required columns in CSV:", paste(missing_cols, collapse = ", ")))
    }
  }

  return(.reference_data)
}


#' Get Parameter Value from Reference Data
#'
#' Retrieves a specific parameter value for a drug from the reference values CSV.
#'
#' @param drug Character. Drug name ("morphine", "oxycodone", "alfentanil", or "general")
#' @param parameter Character. Parameter name
#' @param default Any. Default value if parameter not found (optional)
#' @return Numeric or character value of the parameter
#' @examples
#' get_param_value("morphine", "half_life_normal")
#' get_param_value("general", "normal_crcl")
get_param_value <- function(drug, parameter, default = NULL) {
  ref_data <- load_reference_values()

  # Filter for the specific drug and parameter
  value <- ref_data$value[ref_data$drug == drug & ref_data$parameter == parameter]

  if (length(value) == 0) {
    if (!is.null(default)) {
      return(default)
    }
    stop(paste0("Parameter '", parameter, "' not found for drug '", drug, "'"))
  }

  if (length(value) > 1) {
    warning(paste0("Multiple values found for ", drug, ":", parameter, ". Using first."))
    value <- value[1]
  }

  # Convert to numeric if possible
  numeric_value <- suppressWarnings(as.numeric(value))
  if (!is.na(numeric_value)) {
    return(numeric_value)
  }

  # Return as character if not numeric
  return(value)
}


#' Load All Parameters for a Drug
#'
#' Loads all parameters for a specified drug into a structured list.
#' This replaces the hardcoded parameter lists.
#'
#' @param drug_name Character. Drug name ("morphine", "oxycodone", "alfentanil")
#' @return List with all drug parameters
load_drug_parameters_from_csv <- function(drug_name) {
  drug_name <- tolower(drug_name)

  # Build parameter list dynamically from CSV
  params <- list(
    # Drug identification
    name = tools::toTitleCase(drug_name),
    drug_class = ifelse(drug_name == "alfentanil",
                       "Opioid analgesic (synthetic)",
                       "Opioid analgesic"),

    # Potency
    potency_ratio = get_param_value(drug_name, "potency_ratio"),

    # Pharmacokinetic parameters - Normal renal function
    half_life_normal = get_param_value(drug_name, "half_life_normal"),
    volume_distribution = get_param_value(drug_name, "volume_distribution"),
    clearance_normal = get_param_value(drug_name, "clearance_normal"),

    # Pharmacokinetic parameters - Renal impairment
    half_life_renal_mild = get_param_value(drug_name, "half_life_renal_mild"),
    half_life_renal_moderate = get_param_value(drug_name, "half_life_renal_moderate"),
    half_life_renal_severe = get_param_value(drug_name, "half_life_renal_severe"),
    clearance_renal_severe = get_param_value(drug_name, "clearance_renal_severe"),

    # Fraction of drug eliminated by kidneys
    fraction_renal_elimination = get_param_value(drug_name, "fraction_renal"),

    # Bioavailability by route
    bioavailability_iv = get_param_value(drug_name, "bioavailability_iv"),
    bioavailability_sc = get_param_value(drug_name, "bioavailability_sc"),
    bioavailability_oral = get_param_value(drug_name, "bioavailability_oral"),

    # Therapeutic ranges
    therapeutic_min = get_param_value(drug_name, "therapeutic_min"),
    therapeutic_max = get_param_value(drug_name, "therapeutic_max"),
    toxic_concentration = get_param_value(drug_name, "toxic_concentration")
  )

  # Add drug-specific metabolite information
  if (drug_name == "morphine") {
    params$has_active_metabolite <- TRUE
    params$metabolite_name <- "Morphine-6-glucuronide (M6G)"
    params$metabolite_potency_ratio <- get_param_value(drug_name, "M6G_potency")
    params$metabolite_half_life_normal <- get_param_value(drug_name, "M6G_half_life_normal")
    params$metabolite_half_life_renal_severe <- get_param_value(drug_name, "M6G_half_life_renal")
    params$metabolite_accumulation_renal <- get_param_value(drug_name, "M6G_accumulation_renal")
    params$notes <- "Avoid in severe renal impairment due to M6G accumulation. Risk of prolonged sedation and respiratory depression."

  } else if (drug_name == "oxycodone") {
    params$has_active_metabolite <- TRUE
    params$metabolite_name <- "Oxymorphone"
    params$metabolite_potency_ratio <- get_param_value(drug_name, "oxymorphone_potency")
    params$metabolite_contribution <- get_param_value(drug_name, "oxymorphone_contribution")
    params$metabolite_half_life_normal <- get_param_value(drug_name, "oxymorphone_half_life_normal")
    params$notes <- "Preferred over morphine in moderate renal impairment. Still requires dose reduction in severe renal failure."

  } else if (drug_name == "alfentanil") {
    params$has_active_metabolite <- FALSE
    params$metabolite_name <- "Inactive metabolites"
    params$notes <- "Preferred in severe renal failure. Short half-life requires frequent dosing or continuous infusion. Minimal accumulation."
  }

  return(params)
}

# ==============================================================================
# DRUG PARAMETER LISTS (Loaded from CSV)
# ==============================================================================

#' Morphine Pharmacokinetic Parameters
#'
#' Morphine is a hydrophilic opioid with significant renal elimination.
#' It has an active metabolite (M6G) that accumulates dramatically in
#' renal failure, making it potentially dangerous in this population.
#'
#' Key characteristics:
#' - Reference opioid (potency ratio = 1)
#' - Moderate half-life (3-4 hours)
#' - Significant accumulation with repeated dosing
#' - Active metabolite M6G is 2x more potent and renally eliminated
#' - Contraindicated in severe renal failure
#'
#' @format List with pharmacokinetic parameters loaded from CSV
#' @export
MORPHINE_PARAMS <- load_drug_parameters_from_csv("morphine")


#' Oxycodone Pharmacokinetic Parameters
#'
#' Oxycodone is a semi-synthetic opioid with mixed hepatic metabolism.
#' It is safer than morphine in renal impairment but still requires
#' dose adjustment.
#'
#' Key characteristics:
#' - Approximately 1.5-2x more potent than morphine
#' - Similar half-life to morphine
#' - Less renal elimination than morphine
#' - Active metabolite (oxymorphone) contributes minimally
#' - Safer option in mild-moderate renal impairment
#'
#' @format List with pharmacokinetic parameters loaded from CSV
#' @export
OXYCODONE_PARAMS <- load_drug_parameters_from_csv("oxycodone")


#' Alfentanil Pharmacokinetic Parameters
#'
#' Alfentanil is a synthetic opioid with very high potency and short
#' half-life. It is primarily hepatically metabolized, making it the
#' safest option in renal failure.
#'
#' Key characteristics:
#' - Approximately 10-20x more potent than morphine (using 15x as average)
#' - Very short half-life (1-2 hours)
#' - Minimal accumulation with repeated dosing
#' - No active metabolites
#' - Hepatic elimination - safe in renal failure
#' - Requires more frequent dosing or continuous infusion
#'
#' @format List with pharmacokinetic parameters loaded from CSV
#' @export
ALFENTANIL_PARAMS <- load_drug_parameters_from_csv("alfentanil")


#' Get Drug Parameters by Name
#'
#' Retrieves the parameter list for a specified drug.
#'
#' @param drug_name Character. Name of drug: "morphine", "oxycodone", or "alfentanil"
#'                  (case-insensitive)
#' @return List with drug parameters
#' @examples
#' morphine <- get_drug_params("morphine")
#' print(morphine$half_life_normal)
get_drug_params <- function(drug_name) {
  # Convert to lowercase for case-insensitive matching
  drug_name <- tolower(drug_name)

  # Return appropriate parameter list
  params <- switch(drug_name,
    "morphine" = MORPHINE_PARAMS,
    "oxycodone" = OXYCODONE_PARAMS,
    "alfentanil" = ALFENTANIL_PARAMS,
    stop(paste("Unknown drug:", drug_name,
               "\nValid options: morphine, oxycodone, alfentanil"))
  )

  return(params)
}


#' Get All Available Drugs
#'
#' Returns a character vector of all available drugs in the system.
#'
#' @return Character vector of drug names
get_available_drugs <- function() {
  return(c("morphine", "oxycodone", "alfentanil"))
}


#' Adjust Drug Parameters for Patient-Specific Factors
#'
#' Modifies drug parameters based on patient characteristics including
#' weight, renal function, and hepatic function.
#'
#' @param drug_params List. Base drug parameters from get_drug_params()
#' @param patient_weight Numeric. Patient weight in kg
#' @param creatinine_clearance Numeric. CrCl in mL/min
#' @param renal_category Character. "normal", "mild", "moderate", "severe"
#' @return List with adjusted drug parameters
adjust_drug_params_for_patient <- function(drug_params, patient_weight,
                                          creatinine_clearance = 100,
                                          renal_category = "normal") {
  # Create a copy to modify
  adjusted_params <- drug_params

  # Adjust volume of distribution for patient weight
  # Convert from L/kg to total L
  adjusted_params$volume_distribution_total <-
    drug_params$volume_distribution * patient_weight

  # Adjust clearance for patient weight
  # Convert from mL/min/kg to L/hr total
  clearance_ml_min <- drug_params$clearance_normal * patient_weight
  conversion_factor <- get_param_value("general", "conversion_ml_min_to_l_hr")
  adjusted_params$clearance_total <- clearance_ml_min * conversion_factor  # Convert to L/hr

  # Adjust for renal function
  renal_category <- tolower(renal_category)

  adjusted_params$half_life_adjusted <- switch(renal_category,
    "normal" = drug_params$half_life_normal,
    "mild" = drug_params$half_life_renal_mild,
    "moderate" = drug_params$half_life_renal_moderate,
    "severe" = drug_params$half_life_renal_severe,
    drug_params$half_life_normal  # Default to normal
  )

  # Store patient-specific information
  adjusted_params$patient_weight <- patient_weight
  adjusted_params$creatinine_clearance <- creatinine_clearance
  adjusted_params$renal_category <- renal_category

  # Calculate adjustment factor for clearance
  if (renal_category == "severe" && !is.null(drug_params$clearance_renal_severe)) {
    clearance_ml_min_adjusted <- drug_params$clearance_renal_severe * patient_weight
    adjusted_params$clearance_total <- clearance_ml_min_adjusted * conversion_factor
  }

  return(adjusted_params)
}


#' Create Patient Parameter List
#'
#' Creates a standardized patient parameter list for use in simulations.
#'
#' @param weight Numeric. Patient weight in kg (default: 70)
#' @param age Numeric. Patient age in years (default: 65)
#' @param creatinine_clearance Numeric. CrCl in mL/min (default: 90)
#' @param renal_function Character. "normal", "mild", "moderate", "severe" (default: "normal")
#' @param hepatic_function Character. "normal", "mild", "moderate", "severe" (default: "normal")
#' @return List with patient parameters
create_patient_params <- function(weight = 70,
                                 age = 65,
                                 creatinine_clearance = 90,
                                 renal_function = "normal",
                                 hepatic_function = "normal") {
  # Validate inputs
  if (!is.numeric(weight) || weight <= 0) {
    stop("weight must be a positive number")
  }
  if (!is.numeric(age) || age <= 0) {
    stop("age must be a positive number")
  }
  if (!is.numeric(creatinine_clearance) || creatinine_clearance < 0) {
    stop("creatinine_clearance must be non-negative")
  }

  # Validate categorical inputs
  valid_renal <- c("normal", "mild", "moderate", "severe", "dialysis")
  valid_hepatic <- c("normal", "mild", "moderate", "severe")

  renal_function <- tolower(renal_function)
  hepatic_function <- tolower(hepatic_function)

  if (!renal_function %in% valid_renal) {
    stop(paste("renal_function must be one of:", paste(valid_renal, collapse = ", ")))
  }
  if (!hepatic_function %in% valid_hepatic) {
    stop(paste("hepatic_function must be one of:", paste(valid_hepatic, collapse = ", ")))
  }

  # Create parameter list
  params <- list(
    weight = weight,
    age = age,
    creatinine_clearance = creatinine_clearance,
    renal_function = renal_function,
    hepatic_function = hepatic_function
  )

  return(params)
}
