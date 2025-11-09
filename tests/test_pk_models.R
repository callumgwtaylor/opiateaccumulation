# ==============================================================================
# Unit Tests for Pharmacokinetic Models
# ==============================================================================
#
# This file contains unit tests for core PK calculation functions.
# Tests verify correct implementation of pharmacokinetic equations and
# validate edge cases.
#
# To run tests: source this file or use testthat::test_file()
#
# Author: Claude Code
# Date: 2025-11-09
# ==============================================================================

# Load required packages
library(testthat)

# Source the PK models
source("../R/pk_models.R")
source("../R/drug_parameters.R")

# ==============================================================================
# Test: calculate_ke
# ==============================================================================

test_that("calculate_ke returns correct elimination rate constant", {
  # Test known values
  # For t½ = 3 hours, ke should be 0.693/3 = 0.231
  expect_equal(calculate_ke(3), 0.693/3, tolerance = 0.001)

  # For t½ = 1.5 hours
  expect_equal(calculate_ke(1.5), 0.693/1.5, tolerance = 0.001)

  # Test error handling
  expect_error(calculate_ke(-1))
  expect_error(calculate_ke(0))
  expect_error(calculate_ke("text"))
})

# ==============================================================================
# Test: calculate_accumulation
# ==============================================================================

test_that("calculate_accumulation returns correct accumulation factor", {
  # Known case: morphine t½=3hr, dosing q4h
  # ke = 0.231, accumulation = 1/(1-exp(-0.231*4)) = 1/(1-0.394) = 1.65
  acc <- calculate_accumulation(half_life = 3, dosing_interval = 4)
  expect_true(acc > 1)
  expect_true(acc < 2)

  # Accumulation should increase with longer half-life
  acc_short <- calculate_accumulation(half_life = 1, dosing_interval = 4)
  acc_long <- calculate_accumulation(half_life = 6, dosing_interval = 4)
  expect_true(acc_long > acc_short)

  # Accumulation should decrease with longer dosing interval
  acc_frequent <- calculate_accumulation(half_life = 3, dosing_interval = 2)
  acc_infrequent <- calculate_accumulation(half_life = 3, dosing_interval = 8)
  expect_true(acc_frequent > acc_infrequent)

  # Test error handling
  expect_error(calculate_accumulation(-1, 4))
  expect_error(calculate_accumulation(3, -1))
})

# ==============================================================================
# Test: calculate_concentration_single
# ==============================================================================

test_that("calculate_concentration_single returns correct concentrations", {
  # Test case: 10 mg dose, Vd = 70L, t½ = 3hr
  # C0 = 10/70 = 0.143 mg/L
  # At t=0, C should equal C0
  c0 <- calculate_concentration_single(
    dose = 10,
    volume_distribution = 70,
    half_life = 3,
    time = 0
  )
  expect_equal(c0, 10/70, tolerance = 0.001)

  # At t = 1 half-life, concentration should be 50% of C0
  c_halflife <- calculate_concentration_single(
    dose = 10,
    volume_distribution = 70,
    half_life = 3,
    time = 3
  )
  expect_equal(c_halflife, c0 * 0.5, tolerance = 0.01)

  # At t = 2 half-lives, concentration should be 25% of C0
  c_2halflife <- calculate_concentration_single(
    dose = 10,
    volume_distribution = 70,
    half_life = 3,
    time = 6
  )
  expect_equal(c_2halflife, c0 * 0.25, tolerance = 0.01)

  # Concentration should decrease over time
  c_early <- calculate_concentration_single(10, 70, 3, 1)
  c_late <- calculate_concentration_single(10, 70, 3, 10)
  expect_true(c_late < c_early)

  # Test vector input
  times <- c(0, 3, 6, 9)
  concentrations <- calculate_concentration_single(10, 70, 3, times)
  expect_length(concentrations, 4)
  expect_true(all(diff(concentrations) < 0))  # Should be decreasing

  # Test error handling
  expect_error(calculate_concentration_single(-10, 70, 3, 0))
  expect_error(calculate_concentration_single(10, -70, 3, 0))
  expect_error(calculate_concentration_single(10, 70, -3, 0))
  expect_error(calculate_concentration_single(10, 70, 3, -1))
})

# ==============================================================================
# Test: calculate_concentration_repeated
# ==============================================================================

test_that("calculate_concentration_repeated shows accumulation", {
  # Simulate repeated dosing
  result <- calculate_concentration_repeated(
    dose = 10,
    volume_distribution = 70,
    half_life = 3,
    dosing_interval = 4,
    simulation_duration = 48,
    time_step = 0.5
  )

  # Check output structure
  expect_true(is.data.frame(result))
  expect_true(all(c("time", "concentration", "dose_number") %in% names(result)))

  # Check that concentrations increase over time initially (accumulation)
  first_peak <- max(result$concentration[result$time <= 4])
  second_peak <- max(result$concentration[result$time > 4 & result$time <= 8])
  expect_true(second_peak > first_peak)

  # Peak after dose 1 should be less than peak after dose 5
  peak_dose1 <- max(result$concentration[result$dose_number == 1])
  peak_dose5 <- max(result$concentration[result$dose_number == 5])
  expect_true(peak_dose5 > peak_dose1)

  # Test error handling
  expect_error(calculate_concentration_repeated(-10, 70, 3, 4, 48))
  expect_error(calculate_concentration_repeated(10, -70, 3, 4, 48))
})

# ==============================================================================
# Test: calculate_time_to_steady_state
# ==============================================================================

test_that("calculate_time_to_steady_state returns reasonable values", {
  # For 97% steady state, should be ~5 half-lives
  # For t½ = 3hr, should be ~15 hours
  time_ss <- calculate_time_to_steady_state(half_life = 3, proportion = 0.97)
  expect_true(time_ss >= 14)
  expect_true(time_ss <= 16)

  # Should scale linearly with half-life
  time_ss_short <- calculate_time_to_steady_state(1.5)
  time_ss_long <- calculate_time_to_steady_state(6)
  expect_equal(time_ss_long / time_ss_short, 4, tolerance = 0.01)

  # Test different proportions
  time_90 <- calculate_time_to_steady_state(3, proportion = 0.90)
  time_99 <- calculate_time_to_steady_state(3, proportion = 0.99)
  expect_true(time_99 > time_90)

  # Test error handling
  expect_error(calculate_time_to_steady_state(-1))
  expect_error(calculate_time_to_steady_state(3, proportion = 1.5))
  expect_error(calculate_time_to_steady_state(3, proportion = -0.1))
})

# ==============================================================================
# Test: calculate_steady_state_levels
# ==============================================================================

test_that("calculate_steady_state_levels returns correct metrics", {
  ss_levels <- calculate_steady_state_levels(
    dose = 10,
    volume_distribution = 70,
    half_life = 3,
    dosing_interval = 4
  )

  # Check output structure
  expect_true(is.list(ss_levels))
  expect_true(all(c("cmax_ss", "cmin_ss", "cavg_ss", "fluctuation",
                   "accumulation_factor") %in% names(ss_levels)))

  # Cmax should be greater than Cmin
  expect_true(ss_levels$cmax_ss > ss_levels$cmin_ss)

  # Cavg should be between Cmin and Cmax
  expect_true(ss_levels$cavg_ss > ss_levels$cmin_ss)
  expect_true(ss_levels$cavg_ss < ss_levels$cmax_ss)

  # Fluctuation should be > 1
  expect_true(ss_levels$fluctuation > 1)

  # Accumulation factor should be > 1 for this regimen
  expect_true(ss_levels$accumulation_factor > 1)

  # Test that longer dosing intervals reduce accumulation
  ss_short_interval <- calculate_steady_state_levels(10, 70, 3, 2)
  ss_long_interval <- calculate_steady_state_levels(10, 70, 3, 12)
  expect_true(ss_short_interval$accumulation_factor >
             ss_long_interval$accumulation_factor)
})

# ==============================================================================
# Test: calculate_loading_dose
# ==============================================================================

test_that("calculate_loading_dose returns correct values", {
  # If accumulation factor is 2, loading dose should be 2x maintenance
  loading <- calculate_loading_dose(
    maintenance_dose = 10,
    half_life = 3,
    dosing_interval = 4
  )

  # Should be greater than maintenance dose
  expect_true(loading > 10)

  # Calculate accumulation factor separately
  acc_factor <- calculate_accumulation(3, 4)
  expect_equal(loading, 10 * acc_factor, tolerance = 0.001)

  # Test error handling
  expect_error(calculate_loading_dose(-10, 3, 4))
  expect_error(calculate_loading_dose(10, -3, 4))
})

# ==============================================================================
# Test: adjust_for_renal_function
# ==============================================================================

test_that("adjust_for_renal_function reduces clearance appropriately", {
  # Test with 50% renal function for drug that's 90% renally eliminated
  adjusted <- adjust_for_renal_function(
    clearance_normal = 60,  # L/hr
    half_life_normal = 3,
    creatinine_clearance = 50,
    normal_creatinine_clearance = 100,
    fraction_renal = 0.9
  )

  # Clearance should be reduced
  expect_true(adjusted$clearance_adjusted < 60)

  # Half-life should be increased
  expect_true(adjusted$half_life_adjusted > 3)

  # With CrCl = 50% of normal, for drug 90% renally eliminated:
  # Renal CL = 54 L/hr (90% of 60)
  # Non-renal CL = 6 L/hr (10% of 60)
  # Adjusted renal CL = 27 L/hr (50% of 54)
  # Total adjusted CL = 33 L/hr (27 + 6)
  expect_equal(adjusted$clearance_adjusted, 33, tolerance = 0.1)

  # Test with drug that's not renally eliminated
  adjusted_hepatic <- adjust_for_renal_function(
    clearance_normal = 60,
    half_life_normal = 3,
    creatinine_clearance = 20,
    normal_creatinine_clearance = 100,
    fraction_renal = 0.05  # Only 5% renal
  )

  # Should be minimally affected
  expect_true(adjusted_hepatic$clearance_adjusted > 55)
})

# ==============================================================================
# Test: convert_to_morphine_equivalent
# ==============================================================================

test_that("convert_to_morphine_equivalent calculates correctly", {
  # Morphine (potency = 1) should return same value
  expect_equal(convert_to_morphine_equivalent(100, 1), 100)

  # Alfentanil (potency = 15) at 10 ng/mL = 150 ng/mL morphine eq
  expect_equal(convert_to_morphine_equivalent(10, 15), 150)

  # Oxycodone (potency = 1.5) at 100 ng/mL = 150 ng/mL morphine eq
  expect_equal(convert_to_morphine_equivalent(100, 1.5), 150)

  # Test vector input
  concentrations <- c(10, 20, 30)
  morphine_eq <- convert_to_morphine_equivalent(concentrations, 2)
  expect_equal(morphine_eq, c(20, 40, 60))

  # Test error handling
  expect_error(convert_to_morphine_equivalent(-10, 1))
  expect_error(convert_to_morphine_equivalent(10, -1))
})

# ==============================================================================
# Test: calculate_auc
# ==============================================================================

test_that("calculate_auc computes area under curve correctly", {
  # Simple test: rectangular profile
  # If concentration is constant at 10 for 5 hours, AUC = 50
  time <- c(0, 5)
  conc <- c(10, 10)
  auc <- calculate_auc(time, conc)
  expect_equal(auc, 50)

  # Triangular profile
  time <- c(0, 1, 2)
  conc <- c(0, 10, 0)
  auc <- calculate_auc(time, conc)
  expect_equal(auc, 10)  # Triangle area = 0.5 * base * height = 0.5 * 2 * 10

  # Test that AUC increases with higher concentrations
  time <- c(0, 1, 2, 3)
  conc_low <- c(5, 4, 3, 2)
  conc_high <- c(10, 8, 6, 4)
  auc_low <- calculate_auc(time, conc_low)
  auc_high <- calculate_auc(time, conc_high)
  expect_true(auc_high > auc_low)

  # Test error handling
  expect_error(calculate_auc(c(0), c(10)))  # Need at least 2 points
  expect_error(calculate_auc(c(0, 1), c(10)))  # Mismatched lengths
})

# ==============================================================================
# Run all tests
# ==============================================================================

cat("\n")
cat("==================================================\n")
cat("Running PK Model Unit Tests\n")
cat("==================================================\n")
test_file("test_pk_models.R")
cat("\n")
cat("All tests completed!\n")
cat("==================================================\n")
