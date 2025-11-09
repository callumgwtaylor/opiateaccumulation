# Opioid Pharmacokinetic Comparison Tool - User Guide

## Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Quick Start](#quick-start)
4. [Understanding the Interface](#understanding-the-interface)
5. [Interpreting Results](#interpreting-results)
6. [Clinical Scenarios](#clinical-scenarios)
7. [Troubleshooting](#troubleshooting)

---

## Introduction

This interactive tool simulates and compares the pharmacokinetics of three opioids commonly used in palliative care:
- **Morphine**: The reference opioid, renally eliminated
- **Oxycodone**: Semi-synthetic, mixed elimination
- **Alfentanil**: Synthetic, hepatically eliminated

### Key Learning Objectives

1. Understand how drug accumulation offsets potency differences
2. Appreciate the impact of renal function on drug choice
3. Visualize time to steady state for different opioids
4. Calculate morphine-equivalent doses for comparison

---

## Installation

### Prerequisites

This application requires R (version ≥ 4.0.0) and the following packages:

```r
# Install required packages
install.packages(c(
  "shiny",
  "ggplot2",
  "dplyr",
  "tidyr",
  "scales",
  "DT"
))
```

### Running the Application

1. Clone or download the repository
2. Open R or RStudio
3. Set your working directory to the project folder:
   ```r
   setwd("/path/to/opiateaccumulation")
   ```
4. Run the application:
   ```r
   shiny::runApp("app.R")
   ```

The application will open in your default web browser.

---

## Quick Start

### Basic Workflow

1. **Select Drugs**: Choose one or more drugs to compare (left sidebar)
2. **Enter Patient Parameters**: Weight, age, renal function
3. **Set Dosing Regimen**: Dose amount, interval, duration
4. **Run Simulation**: Click "Run Simulation" button
5. **Review Results**: Explore the different tabs

### Example: Comparing Morphine vs Alfentanil

**Scenario**: 70 kg patient with normal renal function

1. Select both "Morphine" and "Alfentanil"
2. Patient parameters:
   - Weight: 70 kg
   - Age: 65 years
   - Renal function: Normal
   - CrCl: 90 mL/min
3. Dosing:
   - Route: IV
   - Morphine dose: 10 mg
   - Alfentanil dose: 1 mg (approximately equianalgesic)
   - Interval: 4 hours
   - Duration: 72 hours
4. Click "Run Simulation"
5. Navigate to "Morphine Equivalents" tab to see accumulation effects

---

## Understanding the Interface

### Sidebar Controls

#### Drug Selection
- Check one or more boxes to compare drugs
- You can compare all three simultaneously

#### Patient Parameters
- **Weight**: Affects volume of distribution and clearance
- **Age**: Informational (future versions may adjust parameters)
- **Renal Function**: Categorical assessment
  - Normal: CrCl ≥ 80 mL/min
  - Mild: CrCl 50-80 mL/min
  - Moderate: CrCl 30-50 mL/min
  - Severe: CrCl < 30 mL/min
- **Creatinine Clearance**: Numerical value for precise adjustment

#### Dosing Parameters
- **Route**: IV (intravenous) or SC (subcutaneous)
- **Doses**: Set individually for each drug
  - Use equianalgesic doses for fair comparison
  - Example ratios: Morphine 10 mg ≈ Oxycodone 6.7 mg ≈ Alfentanil 0.67 mg
- **Interval**: Time between doses (hours)
- **Duration**: Total simulation time (hours)

### Main Panel Tabs

#### 1. Concentration Curves
Shows actual plasma concentrations for each drug over time.

**Key Features**:
- Different colored lines for each drug
- Vertical dashed lines mark dosing times
- Y-axis: Concentration in ng/mL
- X-axis: Time in hours

**What to Look For**:
- Rate of accumulation (how quickly concentrations increase with repeated doses)
- Steady-state achievement (when peaks and troughs stabilize)
- Fluctuation between peaks and troughs

#### 2. Morphine Equivalents
All concentrations normalized to morphine-equivalent potency.

**Purpose**: This is the most important comparison because it accounts for both:
- Actual plasma concentration
- Drug potency

**Key Insight**: Despite alfentanil's 15× higher potency, morphine's greater accumulation can result in similar or higher morphine-equivalent levels at steady state.

#### 3. Accumulation Analysis
Three visualizations showing:

1. **Accumulation Factor Bar Chart**
   - How much the drug accumulates compared to a single dose
   - Morphine typically shows 2-3× accumulation
   - Alfentanil shows minimal accumulation (1.2-1.5×)

2. **Time to Steady State**
   - How long until drug levels stabilize
   - Approximately 5 half-lives
   - Morphine: ~15 hours
   - Alfentanil: ~7 hours

3. **Peak and Trough Comparison**
   - Maximum (Cmax) and minimum (Cmin) concentrations at steady state
   - Shown in morphine equivalents for fair comparison
   - Higher fluctuation indicates greater variation between doses

#### 4. Clinical Summary
Detailed information for each simulated drug including:

- **Dosing Information**: Dose, route, interval, daily total
- **Pharmacokinetic Parameters**: Half-life, accumulation factor, time to steady state
- **Steady-State Levels**: Peak, trough, and morphine equivalents
- **Loading Dose Recommendation**: If accumulation is significant
- **Clinical Alerts**: Warnings about renal impairment or toxic levels
- **Clinical Interpretation**: Narrative explanation of results

**Color Coding**:
- 🟢 Green: Safe, no warnings
- 🟡 Yellow: Caution, monitoring recommended
- 🔴 Red: Contraindicated or dangerous

#### 5. Parameter Table
Tabular summary of all drugs with key metrics in an easy-to-compare format.

#### 6. Renal Impact
Interactive visualization showing how different levels of renal function affect drug accumulation.

**How to Use**:
1. Select a drug from dropdown
2. View four curves representing normal, mild, moderate, and severe renal impairment
3. Read clinical note below plot

**Key Observations**:
- Morphine shows dramatic accumulation in renal failure
- Alfentanil is minimally affected
- Oxycodone shows intermediate response

#### 7. About
Background information, references, and disclaimer.

---

## Interpreting Results

### Understanding Accumulation

**Accumulation Factor** = Steady-state concentration ÷ Single-dose concentration

| Factor | Interpretation |
|--------|----------------|
| 1.0 - 1.5 | Minimal accumulation |
| 1.5 - 2.5 | Moderate accumulation |
| > 2.5 | Significant accumulation |

### Morphine-Equivalent Concentration

This normalizes all drugs to morphine potency:

**Morphine-equivalent = Actual concentration × Potency ratio**

Example:
- Alfentanil: 10 ng/mL × 15 = 150 ng/mL morphine-equivalent
- Oxycodone: 100 ng/mL × 1.5 = 150 ng/mL morphine-equivalent
- Morphine: 150 ng/mL × 1 = 150 ng/mL morphine-equivalent

All three provide equivalent analgesia despite different concentrations.

### Clinical Decision Points

#### When to Use Each Opioid

**Morphine**:
- ✅ Normal renal function
- ✅ Established standard of care
- ✅ Cost-effective
- ❌ Avoid in renal impairment (CrCl < 30)
- ❌ Risk of M6G accumulation

**Oxycodone**:
- ✅ Mild to moderate renal impairment
- ✅ Good oral bioavailability
- ⚠️ Dose reduction needed in severe renal impairment
- ⚠️ More expensive than morphine

**Alfentanil**:
- ✅ Severe renal impairment or dialysis
- ✅ Hepatic metabolism - safe in renal failure
- ✅ Rapid onset and offset
- ❌ Short half-life requires frequent dosing or infusion
- ❌ Typically more expensive

---

## Clinical Scenarios

### Scenario 1: Normal Renal Function

**Patient**: 70 kg, 65 years, CrCl 90 mL/min

**Question**: Which opioid provides the most stable levels?

**Steps**:
1. Select all three drugs
2. Use equianalgesic doses:
   - Morphine 10 mg
   - Oxycodone 6.7 mg
   - Alfentanil 0.67 mg
3. Interval: 4 hours, Duration: 72 hours
4. Run simulation

**Expected Findings**:
- Morphine shows greatest accumulation (factor ~2.5)
- All reach similar morphine-equivalent levels at steady state
- Morphine provides most stable coverage due to accumulation

### Scenario 2: Severe Renal Impairment

**Patient**: 65 kg, 75 years, CrCl 20 mL/min

**Question**: Which opioid is safest?

**Steps**:
1. Select Morphine and Alfentanil
2. Set renal function to "Severe"
3. CrCl: 20 mL/min
4. Standard doses, 4-hour interval
5. Run simulation

**Expected Findings**:
- Morphine shows dramatic accumulation
- ⚠️ Clinical alerts warning about M6G accumulation
- Alfentanil minimally affected
- Alfentanil is clearly safer choice

### Scenario 3: Optimizing Dosing Interval

**Patient**: 70 kg, normal renal function

**Question**: How does dosing interval affect accumulation?

**Steps**:
1. Select Morphine
2. Run three separate simulations:
   - Interval: 2 hours
   - Interval: 4 hours
   - Interval: 8 hours
3. Compare accumulation factors in Clinical Summary

**Expected Findings**:
- More frequent dosing → greater accumulation
- Less frequent dosing → more fluctuation between doses
- Need to balance steady levels vs dosing convenience

### Scenario 4: Loading Dose Strategy

**Patient**: 70 kg, normal renal function, severe pain

**Question**: How to rapidly achieve steady-state levels?

**Steps**:
1. Select Morphine
2. Standard 10 mg q4h regimen
3. Run simulation
4. Check Clinical Summary for loading dose recommendation

**Expected Finding**:
- Loading dose = Maintenance dose × Accumulation factor
- For morphine q4h: ~16-20 mg loading dose
- Achieves steady-state immediately without waiting 12-15 hours

---

## Troubleshooting

### Common Issues

#### Simulation Doesn't Run
- **Check**: At least one drug must be selected
- **Check**: All required fields have valid numbers
- **Fix**: Review sidebar inputs, ensure no negative values

#### Unrealistic Concentrations
- **Check**: Doses are appropriate (mg, not mcg for alfentanil)
- **Check**: Weight is in kg
- **Fix**: Alfentanil doses should be much smaller (0.5-2 mg range)

#### Application Won't Start
- **Check**: All required packages installed
- **Check**: Working directory is correct
- **Fix**: Run `install.packages()` for missing packages

#### Plots Not Displaying
- **Check**: Simulation has been run (click "Run Simulation")
- **Fix**: Try switching tabs or re-running simulation

### Getting Help

For issues not covered here:
1. Check the README.md file
2. Review error messages in R console
3. Verify package versions are up to date

---

## Advanced Features

### Subcutaneous Route
- Accounts for reduced bioavailability
- Morphine SC: 85% bioavailability
- Slightly lower peak concentrations vs IV

### Customizing Parameters
Advanced users can modify drug parameters in `R/drug_parameters.R`:
- Half-life values
- Potency ratios
- Clearance rates
- Volume of distribution

**Note**: Always refer to published literature when modifying parameters.

---

## References

1. Lotsch J, et al. (2002). Pharmacokinetic modeling of morphine
2. Saari TI, et al. (2012). Oxycodone pharmacokinetics and metabolism
3. Maitre PO, et al. (1987). Alfentanil pharmacokinetics in elderly patients
4. Palliative Care Formulary (PCF) - Equianalgesic ratios
5. European Association for Palliative Care (EAPC) guidelines

---

## Disclaimer

This tool is for **educational purposes only**. Clinical decisions should be made by qualified healthcare professionals considering:
- Individual patient factors
- Clinical context and comorbidities
- Local guidelines and protocols
- Drug interactions and contraindications
- Monitoring requirements

This is a simplified pharmacokinetic model and may not capture all clinical complexities.

---

*Version 1.0 | Last updated: 2025-11-09*
