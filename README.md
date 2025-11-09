# Opioid Pharmacokinetic Comparison Tool

## Project Overview

This project creates an interactive pharmacokinetic (PK) simulation tool to compare three opioids (morphine, oxycodone, and alfentanil) in palliative care settings. The primary goal is to demonstrate how drug accumulation patterns offset differences in potency, particularly showing how morphine's slower clearance leads to accumulation that compensates for alfentanil's higher potency.

## Quick Start

### Installation

```r
# Install required packages
install.packages(c("shiny", "ggplot2", "dplyr", "tidyr", "scales", "DT"))
```

### Running the Application

```r
# Clone or download this repository
# Set working directory to the project folder
setwd("/path/to/opiateaccumulation")

# Run the Shiny app
shiny::runApp("app.R")
```

The application will open in your web browser.

### Documentation

- **[Installation Guide](docs/INSTALL.md)** - Detailed installation instructions
- **[User Guide](docs/USER_GUIDE.md)** - Comprehensive usage instructions and clinical scenarios
- **[Reference Data](data/reference_values.csv)** - Literature-based PK parameters

## Features Implemented

✅ **Core Pharmacokinetic Models**
- One-compartment model with first-order elimination
- Repeated dosing with accumulation calculations
- Renal function adjustments
- Loading dose calculations
- Steady-state predictions

✅ **Drug Parameters**
- Morphine (reference opioid, renally eliminated)
- Oxycodone (mixed elimination)
- Alfentanil (hepatically eliminated)
- Configurable patient-specific adjustments

✅ **Interactive Shiny Application**
- Drug selection and comparison
- Patient parameter inputs (weight, age, renal function)
- Dosing regimen configuration
- Multiple visualization tabs

✅ **Visualizations**
- Concentration-time curves
- Morphine-equivalent comparisons
- Accumulation factor analysis
- Peak and trough levels
- Renal function impact
- Clinical summaries with warnings

✅ **Additional Features**
- Subcutaneous route modeling
- Clinical interpretation and warnings
- Comprehensive parameter tables
- Unit tests for core calculations
- Detailed documentation

## Clinical Context

In palliative care, opioid selection involves balancing:
- **Potency**: Alfentanil is ~20x more potent than morphine
- **Clearance**: Alfentanil has a half-life of ~1.5 hours vs morphine's 3-4 hours
- **Accumulation**: With repeated dosing, morphine builds up significantly while alfentanil reaches steady state quickly
- **Renal function**: Morphine and its active metabolite (M6G) accumulate dangerously in renal failure

This tool will visualize how these factors interact over time.

## Core Requirements

### 1. Pharmacokinetic Model Implementation

Create a flexible PK model that can handle:
- **One-compartment model** (minimum viable)
- **Optional multi-compartment models** for more accuracy
- **First-order elimination kinetics**
- **Repeated dosing schedules** (e.g., q4h, q6h, q8h)
- **Loading dose calculations**
- **Time to peak concentration**
- **Steady-state predictions**

### 2. Drug Parameters (Make Configurable)

Each drug needs these parameters as variables:

```r
# Example structure for morphine
morphine_params <- list(
  name = "Morphine",
  potency_ratio = 1,  # Reference drug
  half_life_normal = 3,  # hours
  half_life_renal = 8,   # hours in severe renal impairment
  volume_distribution = 3.5,  # L/kg
  clearance_normal = 1.2,  # L/hr/kg
  clearance_renal = 0.3,   # L/hr/kg in severe renal impairment
  bioavailability_iv = 1,
  bioavailability_sc = 0.85,
  metabolite_active = TRUE,
  metabolite_name = "M6G",
  metabolite_potency = 2,  # Relative to morphine
  metabolite_accumulation_renal = 10  # Fold increase in renal failure
)

# Similar structures for oxycodone and alfentanil
```

### 3. Patient Parameters (User Adjustable)

```r
patient_params <- list(
  weight = 70,  # kg
  age = 65,     # years
  renal_function = "normal",  # Options: "normal", "mild", "moderate", "severe", "dialysis"
  creatinine_clearance = 90,  # mL/min
  hepatic_function = "normal"  # Options: "normal", "mild", "moderate", "severe"
)
```

### 4. Dosing Regimens

```r
dosing_params <- list(
  route = "IV",  # Options: "IV", "SC"
  dose_mg = 10,  # Dose in mg
  interval_hours = 4,  # Dosing interval
  loading_dose = FALSE,  # Whether to calculate and give loading dose
  simulation_duration = 72,  # Hours to simulate
  breakthrough_doses = list()  # Optional: times and amounts of PRN doses
)
```

### 5. Key Calculations

Implement functions for:

```r
# Accumulation factor
calculate_accumulation <- function(half_life, dosing_interval) {
  ke <- 0.693 / half_life
  accumulation <- 1 / (1 - exp(-ke * dosing_interval))
  return(accumulation)
}

# Plasma concentration over time
calculate_concentration <- function(dose, volume, clearance, time) {
  # Implement one-compartment or multi-compartment model
}

# Morphine-equivalent dose/concentration
convert_to_morphine_equivalent <- function(concentration, drug_potency) {
  return(concentration * drug_potency)
}

# Adjust parameters for renal function
adjust_for_renal <- function(base_clearance, creatinine_clearance) {
  # Implement adjustment algorithm
}
```

### 6. Visualization Requirements

Create ggplot2 visualizations showing:

1. **Individual drug concentration curves**
   - X-axis: Time (hours)
   - Y-axis: Plasma concentration (ng/mL)
   - Show each drug as separate line

2. **Morphine-equivalent comparison**
   - Convert all concentrations to morphine-equivalent
   - Highlight crossover points where accumulation changes relative effectiveness

3. **Accumulation comparison**
   - Bar chart showing accumulation factors for each drug
   - Compare normal vs renal impairment

4. **Peak and trough table**
   - Show steady-state peaks and troughs
   - Time to steady state
   - Total daily morphine-equivalent exposure

### 7. Shiny App Structure

```r
# UI should include:
- Sidebar with parameter inputs:
  - Drug selection (single or multiple for comparison)
  - Patient parameters (weight, renal function)
  - Dosing parameters (dose, interval, duration)
  - Route selection (IV vs SC if implemented)
  
- Main panel with tabs:
  - "Concentration Curves" - Time series plots
  - "Morphine Equivalents" - Normalized comparison
  - "Accumulation Analysis" - Steady state metrics
  - "Clinical Summary" - Key takeaways and warnings
  - "Parameter Table" - Show all current settings
```

### 8. Additional Features (If Time Permits)

- **Subcutaneous absorption modeling**: Add absorption rate constant for SC route
- **Multiple dosing scenarios**: Compare different dosing strategies side-by-side
- **Export functionality**: Save plots and data as PDF/CSV
- **Preset scenarios**: Quick buttons for common clinical scenarios
- **Warning alerts**: Flag when concentrations exceed typical therapeutic ranges
- **Context-sensitive half-time**: For infusion scenarios

## Project Structure

```
opioid-pk-comparison/
├── R/
│   ├── pk_models.R          # Core PK calculations
│   ├── drug_parameters.R    # Drug-specific parameters
│   ├── utils.R              # Helper functions
│   └── plotting.R           # ggplot2 visualization functions
├── app.R                    # Shiny application
├── data/
│   └── reference_values.csv # Literature-based PK parameters
├── tests/                   # Unit tests for calculations
├── docs/                    # Additional documentation
└── README.md
```

## Key Scientific Points to Demonstrate

1. **Initial phase (0-12 hours)**: Alfentanil's high potency provides superior analgesia per dose
2. **Accumulation phase (12-48 hours)**: Morphine concentrations build while alfentanil plateaus
3. **Steady state (>48 hours)**: Morphine's accumulation may provide more consistent coverage despite lower potency
4. **Renal failure scenario**: Dramatic shift in accumulation patterns, morphine becomes dangerous
5. **Clinical implications**: Why rotation between opioids requires careful calculation

## References to Incorporate

- Lotsch et al. (2002) - Morphine population PK
- Saari et al. (2012) - Oxycodone PK parameters  
- Maitre et al. (1987) - Alfentanil compartmental model
- Include conversion ratios from palliative care guidelines (e.g., PCF, EAPC guidelines)

## Development Priority

1. **Phase 1**: Get basic one-compartment model working for all three drugs
2. **Phase 2**: Add renal function adjustments
3. **Phase 3**: Create basic Shiny interface
4. **Phase 4**: Enhance visualizations
5. **Phase 5**: Add advanced features (SC route, metabolites, etc.)

## Success Criteria

The tool successfully demonstrates that:
- Alfentanil's 20x potency advantage diminishes over time due to minimal accumulation
- Morphine's 3-5x accumulation factor compensates for lower potency
- Renal impairment dramatically changes the safety profile, favoring alfentanil
- Clinical decisions need to account for both potency AND pharmacokinetics
