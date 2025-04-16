## Fertility Statistics Auto-visualization Tool

**Version:** 3.1\
**Date:** 16 April 2025\
**Author:** Yuting Li ([yutili\@utu.fi](mailto:yutili@utu.fi))

------------------------------------------------------------------------

## 📋 Table of Contents

1.  [Project Overview](#1-project-overview)  
2.  [Data Update Method](#2-data-update-method)  
3.  [Project Structure](#3-project-structure)  
4.  [Key Functionalities in UI](#4-key-functionalities-in-ui)

------------------------------------------------------------------------

## 1. Project Overview

This is a visualization tool for fertility-related data across countries over a long-term period, built with:

-   **R** 4.4.3  
-   **RStudio** 2024.12.1  
-   **Shiny** 1.10.0

The app uses data from the [**Human Fertility Database (HFD)**](https://www.humanfertility.org/) and provides the following features:

-   Fertility variable selection  
-   Country filtering  
-   Axis range customization  
-   Plot style themes  
-   Language toggle (English/Finnish)  
-   Dark mode toggle  
-   Downloadable plots (JPG, PNG, EPS, PDF, PPTX)  
-   Hover tooltips and zoom/pan interactivity

------------------------------------------------------------------------

## 2. Data Update Method

The app fetches updated data from the HFD via an API.

### 🔹 Web API Update

Run the script: `Update_data_from_HFDweb.R`

-   Automatically downloads and processes new data from HFD  
-   Built using an package "HMDHFDplus" by [\@Timothy](https://github.com/timriffe/TR1)[ L. M. Riffe](https://github.com/timriffe/TR1)\
-   **⚠️ Credentials required**: To run the HFD update script, you need to register with HFD and define your HFD username and password in a `.Renviron` file in the project root directory.   
    You can rename `.Renviron.example` to `.Renviron` and replace with your actual HFD credentials:  

``` text
HFD_username=your_email@example.com  
HFD_password=your_secure_password
```
-   Save the file and **restart RStudio** so the environment variables take effect.
-   **⚠️ Do not share or commit the `.Renviron` file to GitHub. Make sure `.Renviron` is listed in `.gitignore`.**

#### Data update steps:
1.  Create a `.Renviron` file in the root directory of the project. (**restart RStudio**)
2.  Run `Update_data_from_HFDweb.R`  
3.  Wait 3–7 minutes (depending on network/server speed)  
4.  Check `update_log.txt`  
5.  Restart the app and verify updated plots

------------------------------------------------------------------------

## 3. Project Structure

``` text
├── 01_data/                      # Contains updated datasets
│   └── hfd_data.RData            # Human Fertility Database files
├── app.R                         # Shiny app source (UI + Server)
├── Update_data_from_HFDweb.R     # Script for API data update
├── update_log.txt                # Log file for tracking updates
├── .gitignore                    # Make sure ignore .Renviron
├── .Renviron.example             # Save HFD username and password here
└── README.md                     # Readme for project instructions
```

------------------------------------------------------------------------

## 4. Key Functionalities in UI

1.  Variable Selection – Choose among fertility-related indicators
2.  Country Selection – Filter dataset by selected countries
3.  Axis Ranges – Adjust X and Y axes using sliders
4.  Themes – Select ggplot2/ggthemes styles (Classic, Gray, etc.)
5.  Hover Tooltips – View additional info by hovering over points
6.  Zoom & Pan – Explore plots interactively via plotly
7.  Download Options – Export plots as JPG, PNG, EPS, PDF, or PPTX
8.  Language Toggle – Switch between English and Finnish
9.  Dark Mode – Enable a dark UI and dark-themed plots

For questions or suggestions, contact Yuting Li at [yutili\@utu.fi](mailto:yutili@utu.fi)
