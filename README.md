# Longitudinal Air Quality Analysis of India & Maharashtra (1998–2022)

### **Project Overview**
This R Shiny web application investigates the 25-year degradation of air quality in India, with a deep-dive focus on the state of Maharashtra. The project bridges the gap between personal observation and empirical scientific evidence, establishing a strong narrative thread to validate the "Grey Sky" phenomenon.

### **Personal Motivation & Narrative**
The spark for this project came from a cross-cultural observation after moving to Ireland. Witnessing the constant clarity of blue skies led to a reflection on the persistent "grey haze" and declining visibility back home in Maharashtra. This study investigates whether those visual observations match underlying scientific PM2.5 data, mapping the shift from a 1998 "Blue Sky Baseline" to a hazardous structural reality in 2022.

### **Key Technical Implementations**
* **Data Triangulation:** Combines **NASA SEDAC Satellite-Derived Grid Data** (for 25 years of historical temporal depth) with **OGD Platform India Station Data** (for current ground-truth precision).
* **Spatial-Temporal Synthesis:** Developed a custom GIS process to convert raw NASA raster coordinate points into Simple Features, dynamically clipping them to Maharashtra’s administrative boundaries using **CRS 4326**.
* **GIS Workaround:** Implemented a manual server-pull method via `ne_download()` to bypass broken library dependencies (`rnaturalearthhires`), ensuring stable deployment on cloud platforms.
* **Reactive Optimization:** A unified reactive engine synchronizes a single year-slider across five distinct statistical and spatial visualizations simultaneously.



### **Visualisation Design & Theory**
Following Ben Shneiderman’s "Information-Seeking Mantra" (Overview first, zoom and filter, then details-on-demand), the app features:

1.  **National GIS Map:** Employs an AQI-standard divergent color scale for instant health-risk interpretation of pollution "plumes."
2.  **Maharashtra Deep-Dive:** Includes localized GIS mapping and a **Comparative Bar Chart** (Maha vs. National) to establish regional inequality.
3.  **Statistical Spread:** Features **Alpha-Blended boxplots** with jittering to reveal hazardous outliers (60+ $\mu g/m^3$) that are typically obscured by state-level averages.
4.  **Pollution Density Plots:** Illustrates the "Statistical Signature" and the "long tail" of probability for extreme pollution exposure.



### **How to Use**
* **National Tab:** Use the slider to view the 25-year expansion of pollution across the subcontinent.
* **Maharashtra Tab:** Examine localized hotspots and the specific statistical distribution of the state's air quality.
* **National Stats:** Compare any selected state's "pollution signature" against the national baseline.

### **Reference List (Harvard Style)**
* **Chowdhury, S. et al.** (2019) 'Indian annual ambient air quality standard is achievable...', *PNAS*, 116(24).
* **Guttikunda, S.** (2022) *India Air Quality: Satellite-derived PM2.5 database*. Urban Emissions (India).
* **Van Donkelaar, A. et al.** (2022) *V5.GL.04: Global Annual PM2.5 Grids*. Washington University in St. Louis.

---
**Author:** Rishikesh Mahendra Dharane (R0027719)  
**Course:** Data Analytics & Visualisation (Data9005)  
**Institution:** Munster Technological University (MTU)
