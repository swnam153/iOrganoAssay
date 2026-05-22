# iOrganoAssay

**iOrganoAssay (images of Organoid Assay)** is an R package that bundles an interactive Shiny application for connecting microscopy images of mouse intestinal organoids (mIOs) with downstream assay data. The package enables systematic daily monitoring of organoid morphology and quantitative evaluation of image segmentation quality.

- Dataset (Zenodo): https://doi.org/10.5281/zenodo.18627306
- Code (GitHub): https://github.com/swnam153/iOrganoAssay
- License (code): MIT | License (data): CC0

<img width="912" height="769" alt="image" src="https://github.com/user-attachments/assets/f0c05701-58df-4e1e-8f72-0f81a77782c4" />



## Overview

The iOrganoAssay dataset consists of 234 large-area brightfield microscopy images of mouse intestinal organoids (mIO) cultured in Matrigel dome regions (~3 mm), acquired using an automated stage-equipped widefield microscope. Upon dextran sulfate sodium (DSS) treatment, daily morphological changes were captured, segmented, and quantified. Morphometric metrics — area (μm²), perimeter (μm), and circularity — are extracted per organoid and organized for downstream visualization and statistical analysis.
The iOrganoAssay App (R/Shiny) provides two operational tabs:

- **Analysis** — daily-based monitoring of organoid morphology (mean ± SD
  line plots and violin plots) by mouse line, passage (p), microwell (W), day (d), and treatment (t).
- **Validation** — evaluation of segmentation quality using Dice score, accuracy (Acc), segmentation error (SegErr), and centroid error (CenErr).

## Dataset Structure

Download the dataset from Zenodo: https://doi.org/10.5281/zenodo.18627306

```
iOrganoAssay/
├── 0.Metafile.xlsx          # Central metadata file (required by the App)
├── 1.Microscopy/            # 234 PNG files — raw brightfield microscopy images
├── 2.Segmentation/          # 234 PNG files — AIVIA segmentation overlay images
├── 3.Metrics/               # 234 Excel files — per-organoid morphometric data
│                            #   (area, perimeter, circularity per organoid)
├── 4.Microscopy_TIFF/       # 234 TIFF files — high-resolution originals (~8 GB total)
├── 5.Segmentation_JPEG/     # 234 JPEG files — high-resolution segmentation images
└── 6.Validation/            # 2 validation folders (14 JPEG images each)
                             #   used for Dice, Acc, SegErr, and CenErr evaluation
```

Note: The App requires folders 1, 2, and 3 (plus the metafile). Folders 4 and 5 are high-resolution archives for reuse. Folder 6 is used in the Validation tab.


## Installation

```r
# install.packages("remotes")   # if not already installed
remotes::install_github("swnam153/iOrganoAssay")

remotes::install_github("swnam153/iOrganoAssay", force = TRUE)

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


Contact
Sung-Wook Nam, Ph.D.
Department of Molecular Medicine, School of Medicine
Kyungpook National University, Daegu 41405, Republic of Korea
✉ nams@knu.ac.kr

