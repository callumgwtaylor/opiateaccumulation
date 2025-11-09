# Required Source Documents for PK Parameter Extraction

## Priority Sources Needed

### MORPHINE

**Tier 1 - Regulatory/Authoritative**
1. **FDA Drug Label - Morphine Sulfate Injection**
   - URL: https://www.accessdata.fda.gov/drugsatfda_docs/label/2021/202515s025lbl.pdf DONE
   - Need: Full Clinical Pharmacology section (Section 12)
   - Parameters: PK parameters, special populations, metabolites

2. **Goodman & Gilman's Pharmacological Basis of Therapeutics (14th ed, 2024)**
   - Chapter on Opioid Analgesics
   - Need: Morphine pharmacokinetics section
   - Parameters: All basic PK parameters, renal impairment data

**Tier 2 - Primary Literature**
3. **Lotsch J, et al. (2002) - Morphine population pharmacokinetics** DONE
   - Full citation needed
   - Look for: "morphine" "Lotsch" "2002" in PubMed
   - Parameters: Population PK parameters, clearance, Vd, covariates

4. **Study on M6G and M3G metabolites in renal failure** DONE
   - Search: "morphine-6-glucuronide" "renal failure" "accumulation"
   - Need recent systematic review or meta-analysis
   - Parameters: M6G half-life in renal failure, accumulation factors

5. **Palliative Care Formulary (PCF) - Latest edition (8th, 2024?)** DONE
   - Morphine monograph
   - Parameters: Equianalgesic ratios, practical dosing

---

### OXYCODONE

**Tier 1 - Regulatory/Authoritative**
1. **FDA Drug Label - Oxycodone**
   - Search: "oxycodone" site:accessdata.fda.gov
   - Need: Clinical Pharmacology section
   - Parameters: All PK parameters, renal impairment

2. **Goodman & Gilman's (14th ed, 2024)**
   - Oxycodone section
   - Parameters: Basic PK, comparison to morphine

**Tier 2 - Primary Literature**
3. **Saari TI, et al. (2012) - Oxycodone pharmacokinetics**
   - Full citation: "oxycodone" "Saari" "2012"
   - Parameters: Clearance, Vd, half-life, renal effects

4. **Oxycodone equianalgesic ratio study**
   - Meta-analysis or systematic review
   - Search: "oxycodone morphine equianalgesic ratio"
   - Parameters: Morphine:oxycodone conversion ratio

5. **Palliative Care Formulary (PCF)**
   - Oxycodone monograph
   - Parameters: Dosing, conversions

---

### ALFENTANIL

**Tier 1 - Regulatory/Authoritative**
1. **FDA Drug Label - Alfentanil (Alfenta)**
   - URL: Search accessdata.fda.gov for alfentanil
   - Need: Clinical Pharmacology section
   - Parameters: PK parameters, context-sensitive half-time

2. **Goodman & Gilman's (14th ed, 2024)**
   - Alfentanil section
   - Parameters: PK, potency vs morphine

**Tier 2 - Primary Literature**
3. **Maitre PO, et al. (1987) - Alfentanil pharmacokinetics**
   - Classic study on alfentanil PK
   - Search: "Maitre" "alfentanil" "1987"
   - Parameters: Compartmental model, clearance, Vd

4. **Alfentanil in renal failure study**
   - Search: "alfentanil" "renal impairment" OR "renal failure"
   - Parameters: PK changes (or lack thereof) in renal disease

5. **Alfentanil potency study**
   - Search: "alfentanil morphine potency" OR "alfentanil morphine equivalent"
   - Parameters: Potency ratio (should be 10-20x morphine)

---

### CROSS-DRUG COMPARISONS

1. **Systematic review/meta-analysis of opioid pharmacokinetics**
   - Search: "opioid pharmacokinetics" "systematic review" OR "meta-analysis"
   - Recent (2018-2024)
   - Parameters: Comparative PK across drugs

2. **Opioid equianalgesic dosing guideline**
   - EAPC guidelines
   - WHO guidelines
   - NCCN guidelines
   - Parameters: Conversion ratios between all three drugs

3. **Opioids in renal failure review**
   - Search: "opioid" "chronic kidney disease" OR "renal failure" "review"
   - Recent (2020-2024)
   - Parameters: Comparative safety, dose adjustments

---

## Alternative: Textbook Sections

If full papers unavailable, these textbook excerpts would be very helpful:

1. **Applied Biopharmaceutics & Pharmacokinetics (Shargel & Yu, 8th ed, 2022)**
   - Any case studies or examples using opioids
   - Appendix with PK parameters

2. **Clinical Pharmacokinetics and Pharmacodynamics (Rowland & Tozer, 5th ed, 2020)**
   - Morphine examples (if any)
   - General opioid PK principles

---

## How to Provide Documents

**Option 1: Push to repo**
```bash
# Create a folder for source documents
mkdir -p sources/papers
mkdir -p sources/labels
mkdir -p sources/textbooks

# Add PDFs
git add sources/
```

**Option 2: Upload to GitHub Issues**
- Create issue: "PK Parameter Source Documents"
- Attach PDFs as comments
- I can reference them from there

**Option 3: Put in a Dropbox/Drive link**
- Share link in a file like `sources/LINKS.md`

---

## What I Need From Each Document

For each document you provide, I will extract:
- [ ] Exact parameter values with units
- [ ] Page numbers or table numbers
- [ ] Sample size (N) if study
- [ ] Population characteristics
- [ ] Any notes about methodology or limitations
- [ ] Full citation in standard format

---

## Priority Order

If you can only get some sources, prioritize in this order:

### Highest Priority (Must Have)
1. Morphine FDA label
2. Oxycodone FDA label
3. Alfentanil FDA label
4. Palliative Care Formulary (latest edition)

### High Priority (Very Helpful)
5. Lotsch 2002 (morphine population PK)
6. Saari 2012 (oxycodone PK)
7. Maitre 1987 (alfentanil PK)

### Medium Priority (Good to Have)
8. Any systematic review on opioid equianalgesic ratios
9. Review article on opioids in renal failure
10. Goodman & Gilman opioid chapter

### Lower Priority (Nice to Have)
11. Individual studies on metabolites
12. Specific population PK studies
13. Textbook excerpts

---

## Current Status

- [ ] Morphine sources obtained
- [ ] Oxycodone sources obtained
- [ ] Alfentanil sources obtained
- [ ] Cross-drug comparison sources obtained
- [ ] Ready to extract parameters

---

*Once you provide these, I'll systematically extract all parameters using the template in `PARAMETER_TEMPLATE.md` and update the code with properly cited values.*
