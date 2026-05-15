# iOrganoAssay

An R package that bundles the **iOrganoAssay** Shiny application for
mouse intestinal organoid (mIO) microscopy image analysis.

The application contains two tabs:

- **Analysis** — daily-based monitoring of organoid morphology (mean ± SD
  line plots and violin plots) by mouse line, passage, microwell, and day.
- **Validation** — evaluation of segmentation quality using Dice score,
  object accuracy, object segmentation error, and normalized centroid
  error. Supports multiple Validation Sets (Add / Remove).

## Installation

```r
# install.packages("remotes")   # if not already installed
remotes::install_github("swnam153/iOrganoAssay")
```

## Usage

```r
library(iOrganoAssay)
LaunchApp()
```

This opens the iOrganoAssay GUI in your default web browser.
No copy-pasting of scripts is required.

## Dependencies

`shiny`, `dplyr`, `ggplot2`, `readxl`, `stringr`, `tools`, `magick`

These are installed automatically by `remotes::install_github()`.

### Note on `magick`

The `magick` package wraps ImageMagick. On Windows and macOS the
required system library is bundled, so installation is automatic. On
Linux you may need to install `libmagick++-dev` (Debian/Ubuntu) or
`ImageMagick-c++-devel` (Fedora) at the system level first.

## Default folder layout expected by the app

```
C:/iOrganoAssay/
├── 1.Microscopy/      # raw microscopy images (PNG)
├── 2.Segmentation/    # AIVIA segmentation overlays (PNG)
└── 3.Metrics/         # *_metrics.xlsx files
```

You can change these paths inside the app's *Folder setting* panel.
