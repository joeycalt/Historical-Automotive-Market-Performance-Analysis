# Historical Automotive Market & Performance Analysis 🚗💨

## Project Overview
An end-to-end data analytics project designed to clean, transform, and evaluate multi-table automotive performance metrics. This project models vehicle specifications to classify them into commercial pricing tiers and resolves complex data-scaling conflicts across core metrics using interactive, dual-axis dashboards.

## Tools & Technologies Used
* **Database Engine:** MySQL Workbench 26 (Relational schemas, SQL view compilation, feature engineering, string parsing)
* **Visualization Layer:** Tableau Desktop (Dual-axis charts, demographic profiling, dashboard layouts)
* **Data Sources:** Relational datasets containing dimensions (`cars`) and performance metrics (`car_performance`).

<img width="600" height="400" alt="carData EER Diagram" src="https://github.com/user-attachments/assets/386fd6be-dd42-4ccd-9381-03f5fcc62646" />

<div class='tableauPlaceholder' id='viz1792887949471' style='position: relative'><noscript><a href='#'><img width="600" height="400" alt='Dashboard 1 ' src='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;Au&#47;AutomotiveMarketPerformanceAnalysisDashboard&#47;Dashboard1&#47;1_rss.png' style='border: none' /></a></noscript><object class='tableauViz'  style='display:none;'><param name='host_url' value='https%3A%2F%2Fpublic.tableau.com%2F' /> <param name='embed_code_version' value='3' /> <param name='site_root' value='' /><param name='name' value='AutomotiveMarketPerformanceAnalysisDashboard&#47;Dashboard1' /><param name='tabs' value='no' /><param name='toolbar' value='yes' /><param name='static_image' value='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;Au&#47;AutomotiveMarketPerformanceAnalysisDashboard&#47;Dashboard1&#47;1.png' /> <param name='animate_transition' value='yes' /><param name='display_static_image' value='yes' /><param name='display_spinner' value='yes' /><param name='display_overlay' value='yes' /><param name='display_count' value='yes' /><param name='language' value='en-US' /><param name='filter' value='publish=yes' /></object></div>


---

## Core Technical Solutions & SQL Architecture

### 1. Advanced String Standardization & Cleansing
To resolve string fragmentation and eliminate messy duplicate rows (such as trailing spaces or conflicting variations like `hybrid/electric`, `plug-in hybrid`, and `Hybrid`), I implemented a robust, lowercase-insensitive pattern matching algorithm directly into the view layer. This automatically collapsed chaotic user-input fields into 4 distinct, production-ready fuel classifications.

### 2. Analytical Feature Engineering
Leveraged logical valuation conditionals to automatically construct custom business metrics (`price_tier`) across all product records on a rolling scale based on commercial pricing thresholds.

### 3. Database View Optimization
Rather than permanently altering base table records or running slow, repetitive scripts, I compiled a flexible SQL View (`automotive_analysis`) to preserve relational integrity and ensure instant synchronization between the data pipeline and the visualization layers.

```sql
CREATE OR REPLACE VIEW automotive_analysis AS
SELECT 
    c.company_names,
    c.car_name,
    c.car_price,
    CASE 
        WHEN LOWER(c.fuel_type) LIKE '%hybrid%electric%' 
          OR LOWER(c.fuel_type) LIKE '%electric%hybrid%' 
          OR LOWER(c.fuel_type) LIKE '%hybrid/electric%' THEN 'Hybrid'
        WHEN LOWER(c.fuel_type) LIKE '%hybrid%' THEN 'Hybrid'
        WHEN LOWER(c.fuel_type) LIKE '%petrol%' THEN 'Petrol'
        WHEN LOWER(c.fuel_type) LIKE '%diesel%' THEN 'Diesel'
        WHEN LOWER(c.fuel_type) LIKE '%electric%' OR LOWER(c.fuel_type) LIKE '%ev%' THEN 'Electric'
        ELSE c.fuel_type 
    END AS fuel_type,
    c.seats,
    p.engine,
    p.horse_power,
    p.total_speed,
    p.performance_0_100 AS acceleration_secs,
    p.torque,
    CASE 
        WHEN c.car_price < 30000 THEN 'Budget'
        WHEN c.car_price BETWEEN 30000 AND 80000 THEN 'Premium'
        ELSE 'Luxury'
    END AS price_tier
FROM cars c
LEFT JOIN car_performance p ON c.car_id = p.car_id
WHERE c.car_price > 0;
```

---

## Interactive Dashboard Insights

* **The Scale Paradox Solved:** Successfully engineered an advanced **Dual-Axis Chart** in Tableau to map Top Speed against Acceleration. This design allows stakeholders to analyze low-value seconds alongside high-value velocities on a single, scannable layout without compressing critical visual data.
* **Optimized Visual Hierarchy:** Sorted historical vehicle metrics in descending order by speed to ensure top-performing brands immediately command visual focus, eliminating information noise for executive inventory reviews.
* **Business Outcomes:** Provided an intuitive commercial framework that segments performance metrics by price classification, shifting data analysis from simple flat tables to high-impact operational summaries.

👉 **View the Live, Interactive Dashboard Here:** [Interactive Car Data](https://public.tableau.com/views/AutomotiveMarketPerformanceAnalysisDashboard/Dashboard1?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
