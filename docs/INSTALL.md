# Installation Guide

## System Requirements

### Minimum Requirements
- **R version**: 4.0.0 or higher
- **Operating System**: Windows, macOS, or Linux
- **RAM**: 2 GB minimum, 4 GB recommended
- **Storage**: 100 MB for application and dependencies

### Recommended Setup
- **RStudio**: Latest version (optional but recommended for easier use)
- **Internet connection**: Required for initial package installation

---

## Step-by-Step Installation

### Step 1: Install R

If you don't have R installed:

#### Windows
1. Visit https://cran.r-project.org/bin/windows/base/
2. Download the latest R installer
3. Run the installer with default settings

#### macOS
1. Visit https://cran.r-project.org/bin/macosx/
2. Download the appropriate .pkg file for your macOS version
3. Open and run the installer

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install r-base r-base-dev
```

#### Linux (Fedora/RedHat)
```bash
sudo dnf install R
```

### Step 2: Install RStudio (Optional)

RStudio provides a user-friendly interface for R.

1. Visit https://posit.co/download/rstudio-desktop/
2. Download the installer for your operating system
3. Run the installer

### Step 3: Install Required R Packages

Open R or RStudio and run the following commands:

```r
# Install required packages
install.packages(c(
  "shiny",      # Web application framework
  "ggplot2",    # Data visualization
  "dplyr",      # Data manipulation
  "tidyr",      # Data tidying
  "scales",     # Scaling functions for visualization
  "DT"          # Interactive tables
))
```

This may take several minutes depending on your internet connection.

#### Verify Installation

Check that packages installed correctly:

```r
# Load packages to verify installation
library(shiny)
library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(DT)

# If no errors appear, installation was successful
```

### Step 4: Download the Application

#### Option A: Using Git (Recommended)

If you have git installed:

```bash
git clone https://github.com/callumgwtaylor/opiateaccumulation.git
cd opiateaccumulation
```

#### Option B: Download ZIP

1. Visit the GitHub repository
2. Click the green "Code" button
3. Select "Download ZIP"
4. Extract the ZIP file to your desired location

### Step 5: Run the Application

#### From RStudio

1. Open RStudio
2. Go to File → Open Project (or Open File)
3. Navigate to the `opiateaccumulation` folder
4. Open `app.R`
5. Click the "Run App" button at the top of the editor

#### From R Console

```r
# Set working directory to application folder
setwd("/path/to/opiateaccumulation")

# Run the application
shiny::runApp("app.R")
```

The application will open in your default web browser.

---

## Troubleshooting Installation

### Package Installation Errors

#### Error: Cannot install packages

**Solution**: Ensure you have write permissions to R library directory

```r
# Check library path
.libPaths()

# On Windows, run R/RStudio as Administrator
# On macOS/Linux, use sudo if needed
```

#### Error: Package dependencies not available

**Solution**: Install dependencies manually

```r
# Install dependencies for ggplot2
install.packages("Rcpp")
install.packages("rlang")

# Then retry main package installation
install.packages("ggplot2")
```

#### Error: Compilation errors (Linux)

**Solution**: Install development tools

```bash
# Ubuntu/Debian
sudo apt install build-essential libcurl4-openssl-dev libssl-dev libxml2-dev

# Fedora/RedHat
sudo dnf install gcc gcc-c++ make openssl-devel libcurl-devel libxml2-devel
```

### Application Runtime Errors

#### Error: Cannot find R modules

**Solution**: Ensure working directory is set correctly

```r
# Check current directory
getwd()

# Should show path to opiateaccumulation folder
# If not, set it:
setwd("/correct/path/to/opiateaccumulation")
```

#### Error: Shiny application failed to start

**Solution 1**: Check all source files are present

```r
# Verify files exist
list.files("R")
# Should show: pk_models.R, drug_parameters.R, utils.R, plotting.R

file.exists("app.R")
# Should return: TRUE
```

**Solution 2**: Check for syntax errors

```r
# Test loading individual modules
source("R/pk_models.R")
source("R/drug_parameters.R")
source("R/utils.R")
source("R/plotting.R")

# If any errors appear, check that file for issues
```

#### Error: Plot functions not working

**Solution**: Verify ggplot2 installation

```r
# Reinstall ggplot2
install.packages("ggplot2", dependencies = TRUE)

# Load and test
library(ggplot2)
ggplot(data.frame(x=1:10, y=1:10), aes(x, y)) + geom_point()
```

### Memory Issues

If you encounter memory errors:

```r
# Increase memory limit (Windows)
memory.limit(size = 4000)  # 4 GB

# For large simulations, reduce duration or time step
```

---

## Running Tests

To verify the installation and core functions:

```r
# Install testthat if not already installed
install.packages("testthat")

# Navigate to tests directory
setwd("/path/to/opiateaccumulation/tests")

# Run tests
source("test_pk_models.R")
```

All tests should pass. If any fail, review the error messages.

---

## Updating the Application

### Using Git

```bash
cd opiateaccumulation
git pull origin main
```

### Manual Update

1. Download the latest version
2. Replace old files with new ones
3. Restart R/RStudio
4. Re-run the application

---

## Uninstallation

### Remove Application Files

Simply delete the `opiateaccumulation` folder.

### Remove R Packages (Optional)

```r
# Remove packages if no longer needed
remove.packages(c("shiny", "ggplot2", "dplyr", "tidyr", "scales", "DT"))
```

---

## Platform-Specific Notes

### Windows

- Run RStudio as Administrator if package installation fails
- Windows Defender may scan packages during installation (can be slow)
- Use forward slashes (/) or double backslashes (\\\\) in file paths

### macOS

- On newer macOS versions, you may need to allow R in Security & Privacy settings
- Apple Silicon (M1/M2) users: Ensure you download the ARM64 version of R
- XCode Command Line Tools may be required: `xcode-select --install`

### Linux

- Some packages require system libraries (see compilation errors above)
- Consider using conda/mamba for package management:
  ```bash
  conda install -c conda-forge r-shiny r-ggplot2 r-dplyr r-tidyr r-dt
  ```

---

## Getting Help

### Documentation
- User Guide: `docs/USER_GUIDE.md`
- README: `README.md`

### R Help
```r
# Get help on functions
?shiny::runApp
?ggplot2::ggplot

# Get help on packages
help(package = "shiny")
```

### Online Resources
- R Project: https://www.r-project.org/
- Shiny Documentation: https://shiny.rstudio.com/
- Stack Overflow: Tag your questions with `[r]` and `[shiny]`

---

## Advanced Installation Options

### Using renv for Reproducibility

For a reproducible environment:

```r
# Install renv
install.packages("renv")

# Initialize project (in opiateaccumulation directory)
renv::init()

# Install packages
renv::install(c("shiny", "ggplot2", "dplyr", "tidyr", "scales", "DT"))

# Save state
renv::snapshot()
```

### Docker Installation

For containerized deployment:

```dockerfile
FROM rocker/shiny:latest

# Install dependencies
RUN R -e "install.packages(c('ggplot2', 'dplyr', 'tidyr', 'scales', 'DT'))"

# Copy application files
COPY . /srv/shiny-server/opioid-pk

# Expose port
EXPOSE 3838

# Run application
CMD ["/usr/bin/shiny-server"]
```

---

*Last updated: 2025-11-09*
