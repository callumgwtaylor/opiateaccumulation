# Pharmacokinetic Parameter Extraction Template

## Purpose
This document defines the exact parameters needed for the PK model and provides a standardized template for extracting them from primary literature.

---

## Required Parameters for Each Drug

### 1. Basic Drug Information
- **Drug Name**: [Generic name]
- **Drug Class**: [e.g., μ-opioid receptor agonist]
- **Chemical Structure**: [Phenanthrene/Synthetic/Semi-synthetic]

### 2. Potency Parameters
| Parameter | Value | Unit | Reference | Page/Table | Notes |
|-----------|-------|------|-----------|------------|-------|
| Equianalgesic ratio (vs morphine IV) | | mg:mg | | | |
| Equianalgesic ratio (vs morphine oral) | | mg:mg | | | |
| Receptor binding affinity (Ki) | | nM | | | Optional |
| Intrinsic efficacy | | % | | | Optional |

**Source Priority**:
1. Cochrane systematic reviews
2. Meta-analyses of equianalgesic ratios
3. Palliative Care Formulary (PCF) - latest edition
4. EAPC/WHO guidelines
5. Clinical trials with direct comparisons

### 3. Pharmacokinetic Parameters (Normal Renal/Hepatic Function)

#### Absorption
| Parameter | Value | Unit | Reference | Page/Table | Study Design | N | Notes |
|-----------|-------|------|-----------|------------|--------------|---|-------|
| Bioavailability (IV) | 1.0 | fraction | N/A | N/A | By definition | - | |
| Bioavailability (oral) | | fraction | | | | | |
| Bioavailability (SC) | | fraction | | | | | |
| Bioavailability (SL) | | fraction | | | | | If applicable |
| Tmax (oral) | | hours | | | | | Time to peak |
| Absorption rate constant (Ka) | | 1/hr | | | | | For SC modeling |

#### Distribution
| Parameter | Value | SD/Range | Unit | Reference | Page/Table | Study Design | N | Notes |
|-----------|-------|----------|------|-----------|------------|--------------|---|-------|
| Volume of distribution (Vd) | | | L/kg | | | | | |
| Volume of central compartment (Vc) | | | L/kg | | | | | If 2-compartment |
| Volume of peripheral compartment (Vp) | | | L/kg | | | | | If 2-compartment |
| Protein binding | | | % | | | | | |
| Blood:plasma ratio | | | ratio | | | | | |

#### Elimination
| Parameter | Value | SD/Range | Unit | Reference | Page/Table | Study Design | N | Notes |
|-----------|-------|----------|------|-----------|------------|--------------|---|-------|
| Half-life (t½) | | | hours | | | | | |
| Elimination rate constant (ke) | | | 1/hr | | | | | Can calculate from t½ |
| Clearance (CL) | | | L/hr/kg | | | | | |
| Clearance (CL) | | | mL/min/kg | | | | | Alternative units |
| Renal clearance | | | L/hr | | | | | |
| Hepatic clearance | | | L/hr | | | | | |
| Fraction excreted unchanged | | | % | | | | | |

#### Multi-Compartment Parameters (if applicable)
| Parameter | Value | SD/Range | Unit | Reference | Page/Table | Notes |
|-----------|-------|----------|------|-----------|------------|-------|
| α (distribution phase) | | | 1/hr | | | |
| β (elimination phase) | | | 1/hr | | | |
| Distribution half-life | | | hours | | | |
| Elimination half-life | | | hours | | | |
| Intercompartmental clearance (Q) | | | L/hr | | | |

### 4. Pharmacokinetic Parameters in Special Populations

#### Renal Impairment
| CrCl Category | CrCl Range | t½ | CL | Vd | Reference | Page/Table | N | Notes |
|---------------|------------|-----|-----|-----|-----------|------------|---|-------|
| Normal | ≥80 mL/min | | | | | | | |
| Mild | 50-79 mL/min | | | | | | | |
| Moderate | 30-49 mL/min | | | | | | | |
| Severe | 15-29 mL/min | | | | | | | |
| ESRD/Dialysis | <15 mL/min | | | | | | | |

#### Hepatic Impairment
| Child-Pugh | Score | t½ | CL | Vd | Reference | Page/Table | N | Notes |
|------------|-------|-----|-----|-----|-----------|------------|---|-------|
| Normal | - | | | | | | | |
| A (Mild) | 5-6 | | | | | | | |
| B (Moderate) | 7-9 | | | | | | | |
| C (Severe) | 10-15 | | | | | | | |

#### Age Effects
| Age Group | Age Range | t½ | CL | Vd | Reference | Page/Table | N | Notes |
|-----------|-----------|-----|-----|-----|-----------|------------|---|-------|
| Young adult | 18-40 | | | | | | | Reference |
| Middle age | 41-65 | | | | | | | |
| Elderly | 66-80 | | | | | | | |
| Very elderly | >80 | | | | | | | |

### 5. Active Metabolites

For each active metabolite:

| Parameter | Parent Drug | Metabolite Name | Value | Unit | Reference | Notes |
|-----------|-------------|-----------------|-------|------|-----------|-------|
| Metabolite formed | | | Yes/No | - | | |
| Metabolite name | | | | - | | |
| Formation pathway | | | | - | | CYP enzyme |
| Metabolite potency | | | | vs parent | | |
| Metabolite t½ | | | | hours | | |
| Metabolite CL | | | | L/hr/kg | | |
| Metabolite renal elimination | | | | % | | |
| Accumulation in renal failure | | | | fold ↑ | | |
| Clinical significance | | | | High/Med/Low | | |

**Specific Metabolites to Document**:
- **Morphine**: M6G (morphine-6-glucuronide), M3G (morphine-3-glucuronide)
- **Oxycodone**: Oxymorphone, noroxycodone
- **Alfentanil**: None (inactive metabolites)

### 6. Therapeutic Drug Monitoring

| Parameter | Value | Unit | Reference | Page/Table | Clinical Context | Notes |
|-----------|-------|------|-----------|------------|------------------|-------|
| Minimum effective concentration | | ng/mL | | | | |
| Therapeutic range (min) | | ng/mL | | | | |
| Therapeutic range (max) | | ng/mL | | | | |
| Toxic concentration | | ng/mL | | | | |
| Respiratory depression threshold | | ng/mL | | | | |
| Concentration for analgesia | | ng/mL | | | | |

### 7. Population Pharmacokinetics

If population PK study available:

| Parameter | Population Mean | IIV (CV%) | Reference | Model Type | Software | N | Notes |
|-----------|-----------------|-----------|-----------|------------|----------|---|-------|
| CL | | | | | | | |
| Vd | | | | | | | |
| Ka | | | | | | | |

**Covariates to extract**:
- Weight effect on CL
- Weight effect on Vd
- Age effect on CL
- Sex differences
- CrCl effect on CL
- Genetic polymorphisms (CYP2D6, etc.)

---

## Data Quality Criteria

### Study Selection Hierarchy
1. **Tier 1 (Highest Quality)**:
   - Systematic reviews/meta-analyses
   - FDA/EMA regulatory documents
   - Multi-center population PK studies (N>100)

2. **Tier 2**:
   - Single-center PK studies with adequate sample size (N>20)
   - Well-designed clinical trials with PK endpoints
   - Authoritative textbooks (Goodman & Gilman, etc.)

3. **Tier 3**:
   - Case series
   - Older studies (pre-1990) if no better data available
   - Extrapolated data from similar drugs

### Required Study Information
- **Study design**: RCT, observational, PK study, etc.
- **Sample size**: Number of subjects
- **Population**: Age, weight, disease state
- **Analytical method**: HPLC, LC-MS/MS, etc.
- **Detection limit**: Lower limit of quantification (LLOQ)
- **Dosing**: Route, dose range
- **Compartmental model**: 1-compartment, 2-compartment, etc.
- **Software used**: NONMEM, WinNonlin, etc.

---

## Preferred Sources (in order of priority)

### 1. Regulatory Databases
- FDA Drug Labels (DailyMed): https://dailymed.nlm.nih.gov/
- EMA Product Information: https://www.ema.europa.eu/
- FDA Clinical Pharmacology Reviews: https://www.accessdata.fda.gov/

### 2. Clinical Guidelines
- Palliative Care Formulary (PCF) - latest edition
- WHO Pain Ladder Guidelines
- EAPC Guidelines on Opioid Use
- NCCN Adult Cancer Pain Guidelines

### 3. Primary Literature Databases
- PubMed/MEDLINE
- Cochrane Library
- Clinical Pharmacokinetics journal
- British Journal of Clinical Pharmacology
- European Journal of Clinical Pharmacology

### 4. Pharmacology Textbooks
- Goodman & Gilman's Pharmacological Basis of Therapeutics (14th ed, 2024)
- Applied Biopharmaceutics & Pharmacokinetics (Shargel & Yu, 8th ed, 2022)
- Clinical Pharmacokinetics and Pharmacodynamics (Rowland & Tozer, 5th ed, 2020)

### 5. Clinical Decision Support
- UpToDate - Drug Information
- Micromedex
- Lexicomp

### 6. Specific High-Quality PK Studies
- Search terms: "[Drug name] AND pharmacokinetics AND (population OR compartment OR clearance)"
- Filters: Humans, English, Last 15 years (unless landmark older study)

---

## Extraction Checklist

For each parameter extracted:
- [ ] Parameter name and value recorded
- [ ] Units clearly specified
- [ ] Reference citation complete (Author, Year, Journal, Volume, Pages)
- [ ] Page number or table number noted
- [ ] Study population described (N, age, sex, disease state)
- [ ] Method of determination noted (assay, compartmental analysis)
- [ ] Uncertainty/variability included (SD, SE, 95% CI, range)
- [ ] Any assumptions or calculations documented
- [ ] Quality tier assigned (1-3)
- [ ] Date of extraction recorded
- [ ] Extractor initials/name

---

## Output Format

Each parameter should be documented as:

```
Parameter: [Name]
Value: [Number] ± [SD/SE] (range: [min-max])
Units: [Unit]
Reference: Author et al. (Year). Title. Journal Volume(Issue):Pages.
Location: Page X, Table Y / Figure Z
Study: Design=[type], N=[number], Population=[description]
Method: [Analytical method and compartmental model]
Quality: Tier [1/2/3]
Notes: [Any relevant caveats, assumptions, or context]
Extracted: [Date] by [Name]
```

---

## Template Populated By Drug

See separate files:
- `MORPHINE_PARAMETERS.md`
- `OXYCODONE_PARAMETERS.md`
- `ALFENTANIL_PARAMETERS.md`

---

*Version: 1.0*
*Created: 2025-11-09*
*Purpose: Standardize PK parameter extraction for opioid comparison tool*
