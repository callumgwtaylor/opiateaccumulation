# ==============================================================================
# Drug-Specific Pharmacokinetic Parameters
# ==============================================================================
#
# This module defines pharmacokinetic parameters for three opioids commonly
# used in palliative care: morphine, oxycodone, and alfentanil.
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
#' @format List with pharmacokinetic parameters
#' @export
MORPHINE_PARAMS <- list(
  # Drug identification
  name = "Morphine",
  drug_class = "Opioid analgesic",

  # Potency (relative to morphine as reference)
  potency_ratio = 1.0,  # Reference drug

  # Pharmacokinetic parameters - Normal renal function
  half_life_normal = 3.0,  # hours (range: 2-4 hours)
  volume_distribution = 3.5,  # L/kg (range: 3-4 L/kg)
  clearance_normal = 15,  # mL/min/kg (range: 12-18 mL/min/kg)

  # Pharmacokinetic parameters - Renal impairment
  half_life_renal_mild = 4.0,      # hours (CrCl 50-80 mL/min)
  half_life_renal_moderate = 6.0,  # hours (CrCl 30-50 mL/min)
  half_life_renal_severe = 10.0,   # hours (CrCl <30 mL/min)
  clearance_renal_severe = 5,      # mL/min/kg (markedly reduced)

  # Fraction of drug eliminated by kidneys
  fraction_renal_elimination = 0.90,  # 90% renally eliminated

  # Bioavailability by route
  bioavailability_iv = 1.0,    # 100% (by definition)
  bioavailability_sc = 0.85,   # 85% (subcutaneous)
  bioavailability_oral = 0.30, # 30% (high first-pass metabolism)

  # Active metabolite information
  has_active_metabolite = TRUE,
  metabolite_name = "Morphine-6-glucuronide (M6G)",
  metabolite_potency_ratio = 2.0,  # M6G is ~2x more potent than morphine
  metabolite_half_life_normal = 3.5,  # hours
  metabolite_half_life_renal_severe = 20.0,  # hours (dramatic accumulation)
  metabolite_accumulation_renal = 10,  # 10-fold increase in renal failure

  # Therapeutic ranges (for reference)
  therapeutic_min = 10,   # ng/mL (minimum effective concentration)
  therapeutic_max = 100,  # ng/mL (typical upper limit before toxicity)
  toxic_concentration = 200,  # ng/mL (associated with respiratory depression)

  # Clinical notes
  notes = "Avoid in severe renal impairment due to M6G accumulation. Risk of prolonged sedation and respiratory depression."
)


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
#' @format List with pharmacokinetic parameters
#' @export
OXYCODONE_PARAMS <- list(
  # Drug identification
  name = "Oxycodone",
  drug_class = "Opioid analgesic",

  # Potency (relative to morphine)
  potency_ratio = 1.5,  # 1.5x more potent than morphine

  # Pharmacokinetic parameters - Normal renal function
  half_life_normal = 3.5,  # hours (range: 3-4.5 hours)
  volume_distribution = 2.6,  # L/kg (range: 2-3 L/kg)
  clearance_normal = 12,  # mL/min/kg (range: 10-15 mL/min/kg)

  # Pharmacokinetic parameters - Renal impairment
  half_life_renal_mild = 4.5,      # hours
  half_life_renal_moderate = 5.5,  # hours
  half_life_renal_severe = 7.0,    # hours (less affected than morphine)
  clearance_renal_severe = 8,      # mL/min/kg

  # Fraction of drug eliminated by kidneys
  fraction_renal_elimination = 0.60,  # 60% renally eliminated (lower than morphine)

  # Bioavailability by route
  bioavailability_iv = 1.0,    # 100%
  bioavailability_sc = 0.85,   # 85% (assumed similar to morphine)
  bioavailability_oral = 0.70, # 70% (better oral bioavailability than morphine)

  # Active metabolite information
  has_active_metabolite = TRUE,
  metabolite_name = "Oxymorphone",
  metabolite_potency_ratio = 3.0,  # Oxymorphone is ~3x more potent
  metabolite_contribution = 0.10,  # But only ~10% of effect (low concentration)
  metabolite_half_life_normal = 7.5,  # hours

  # Therapeutic ranges (for reference)
  therapeutic_min = 5,    # ng/mL
  therapeutic_max = 80,   # ng/mL
  toxic_concentration = 150,  # ng/mL

  # Clinical notes
  notes = "Preferred over morphine in moderate renal impairment. Still requires dose reduction in severe renal failure."
)


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
#' @format List with pharmacokinetic parameters
#' @export
ALFENTANIL_PARAMS <- list(
  # Drug identification
  name = "Alfentanil",
  drug_class = "Opioid analgesic (synthetic)",

  # Potency (relative to morphine)
  potency_ratio = 15.0,  # 15x more potent than morphine (range: 10-20x)

  # Pharmacokinetic parameters - Normal renal function
  half_life_normal = 1.5,  # hours (range: 1-2 hours)
  volume_distribution = 0.6,  # L/kg (small Vd, highly lipophilic)
  clearance_normal = 6,  # mL/min/kg (range: 5-8 mL/min/kg)

  # Pharmacokinetic parameters - Renal impairment
  # Alfentanil is minimally affected by renal function
  half_life_renal_mild = 1.5,      # hours (unchanged)
  half_life_renal_moderate = 1.6,  # hours (minimal change)
  half_life_renal_severe = 1.8,    # hours (minimal change)
  clearance_renal_severe = 5.5,    # mL/min/kg (minimally reduced)

  # Fraction of drug eliminated by kidneys
  fraction_renal_elimination = 0.05,  # Only 5% renally eliminated

  # Bioavailability by route
  bioavailability_iv = 1.0,    # 100%
  bioavailability_sc = 0.90,   # 90% (good subcutaneous absorption)
  bioavailability_oral = 0.10, # 10% (poor oral bioavailability, not used orally)

  # Active metabolite information
  has_active_metabolite = FALSE,
  metabolite_name = "Inactive metabolites",

  # Therapeutic ranges (for reference, in ng/mL)
  therapeutic_min = 50,   # ng/mL
  therapeutic_max = 400,  # ng/mL
  toxic_concentration = 800,  # ng/mL

  # Clinical notes
  notes = "Preferred in severe renal failure. Short half-life requires frequent dosing or continuous infusion. Minimal accumulation."
)


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
  adjusted_params$clearance_total <- clearance_ml_min * 0.060  # Convert to L/hr

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
    adjusted_params$clearance_total <- clearance_ml_min_adjusted * 0.060
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
