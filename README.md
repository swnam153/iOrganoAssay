# iOrganoAssay

An R package that bundles the **iOrganoAssay** Shiny application for
mouse intestinal organoid (mIO) microscopy image analysis.

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

`shiny`, `dplyr`, `ggplot2`, `readxl`, `stringr`, `tools`

These are installed automatically by `remotes::install_github()`.

## Default folder layout expected by the app

```
C:/iOrganoAssay/
├── 1.Microscopy/      # raw microscopy images (PNG)
├── 2.Segmentation/    # AIVIA segmentation overlays (PNG)
└── 3.Metrics/         # *_metrics.xlsx files
```

You can change these paths inside the app's *Folder setting* panel.
