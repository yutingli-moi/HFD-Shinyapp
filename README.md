# Fertility Statistics Auto-visualization Tool

**Version:** 3.1  
**Date:** 16th April 2025 
**Author:** Yuting Li (yutili@utu.fi)

---

## 1. Project Overview

This is a visualization tool for fertility-related data across countries over a long-term period, built with **R (4.4.3)**, **RStudio (2024.12.1)**, and **Shiny (1.10.0)**.  
It uses data from the Human Fertility Database (HFD) and provides rich interactive features including:

- Fertility variable selection  
- Country filtering  
- Axis range customization  
- Plot style selection  
- Language toggle (English/Finnish)  
- Dark mode toggle  
- Downloadable plots (JPG, PNG, EPS, PDF, PPTX)  
- Hover tooltips and zoom/pan features

---

## 2. Data Update Method

The app uses a web API to fetch and update data directly from the Human Fertility Database.

### 🔹 Web API Update (**Recommended and Only Method**)

Run `Update data from HFD web.R`

- Automatically fetches and updates dataset from HFD via API (developed by @Timothy L. M. Riffe)
- **⚠️ Credentials required**: HFD username & password are currently embedded in the script 
- **Action required**: Restrict access to this script to authorized personnel only

**Update steps:**
1. Run the script: `Update data from HFD web.R`
2. Wait 3–7 minutes for download and processing (depending on network/server speed)
3. Check `update_log.txt` to verify successful update
4. Restart the Shiny app and inspect the plots

---

## 3. Project Structure
├── 01_data/ # Contains updated datasets 
│ └── HFD/ # Human Fertility Database files 
├── app.R # Shiny app source (UI + Server) 
├── Update data from HFD web.R # Script for API data update 
├── update_log.txt # Log file for tracking updates 
└── README.md # You are here 📘


---
##4. Key Functionalities
1. Variable Selection: Choose among fertility-related indicators
2. Country Selection: Filter dataset by selected countries
3. Axis Ranges: Adjust X and Y axes via sliders
4. Themes: Choose ggplot2/ggthemes style (Classic, Gray, etc.)
5. Hover Tooltips: Show additional data on mouse hover
6. Zoom & Pan: Explore plots interactively
7. Download Options: Export plots as JPG, PNG, EPS, or PDF
8. Language Toggle: Switch between English and Finnish
9. Dark Mode: Enable dark mode for the UI and plots

---
📬 For questions or improvements, contact Yuting Li at yutili@utu.fi

