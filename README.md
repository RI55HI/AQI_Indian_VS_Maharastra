---
title: AQI Rishikesh
emoji: 📚
colorFrom: blue
colorTo: yellow
sdk: docker
app_port: 7860
pinned: false
license: mit
---

# AQI Rishikesh: Indian vs. Maharashtra Air Quality Dashboard

This interactive R Shiny application visualizes and compares Air Quality Index (AQI) data across India and specifically within the state of Maharashtra. It utilizes ground-station datasets and satellite-derived PM2.5 estimates to provide a comprehensive environmental analysis.

## 🔗 Live Links
* **Interactive Dashboard:** [Hugging Face Space](https://huggingface.co/spaces/ri55hi/AQI_rishikesh)
* **Source Code:** [GitHub Repository](https://github.com/RI55HI/AQI_Indian_VS_Maharastra.git)

---

## 🛠️ Technical Implementation

### Containerization (Docker)
To ensure that complex spatial libraries (`sf`, `gdal`, `geos`) run consistently in the cloud, this project is containerized using **Docker**.
* **Base Image:** `rocker/shiny:latest`
* **System Dependencies:** Installed `libgdal-dev`, `libproj-dev`, and `libssl-dev` via `apt-get` within the Dockerfile.
* **Network Configuration:** Configured to listen on `0.0.0.0:7860` to comply with Hugging Face infrastructure requirements.

### Data Engineering & Cleaning
The raw data underwent a rigorous cleaning process using the `tidyverse` and `janitor` packages:
1.  **Header Standardization:** Used `clean_names()` to ensure consistent snake_case variable names.
2.  **Type Conversion:** Coerced AQI values to numeric and handled missing observations (`NA`) to prevent plotting errors.
3.  **Spatial Filtering:** Utilized `rnaturalearth` to extract high-resolution shapefiles specifically for the Indian subcontinent and Maharashtra state boundaries.
4.  **Satellite Alignment:** Integrated long-term satellite PM2.5 data (1998–2022) with real-time station data.

---

## 📂 Project Structure
* `app.R`: Main Shiny application file (UI & Server).
* `Dockerfile`: Instructions for building the environment.
* `DATASET.csv`: Ground station AQI data.
* `indiasubcont_satpm_allyears.csv`: Satellite PM2.5 dataset.
* `README.md`: Project documentation and Space configuration.

---

## 🚀 How to Run Locally

1. **Clone the Repo:**
   ```bash
   git clone [https://github.com/RI55HI/AQI_Indian_VS_Maharastra.git](https://github.com/RI55HI/AQI_Indian_VS_Maharastra.git)
