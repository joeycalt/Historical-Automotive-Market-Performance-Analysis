SELECT * FROM car_data;

select * from car_performance;

select * from cars;

select * from manufacturers;

SET SQL_SAFE_UPDATES = 0;

CREATE TABLE manufacturers (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE cars (
    car_id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT,
    car_name VARCHAR(255) NOT NULL,
    car_price INT, 
    fuel_type VARCHAR(100),
    seats INT,
    FOREIGN KEY (company_id) REFERENCES manufacturers(company_id) ON DELETE CASCADE
);

CREATE TABLE car_performance (
    spec_id INT AUTO_INCREMENT PRIMARY KEY,
    car_id INT UNIQUE,
    engine VARCHAR(100),
    battery_capacity VARCHAR(100),
    horse_power INT,
    total_speed INT,
    performance_0_100 DECIMAL(4,2),
    torque INT,
    FOREIGN KEY (car_id) REFERENCES cars(car_id) ON DELETE CASCADE
);

INSERT INTO manufacturers (company_name)
SELECT DISTINCT company_names 
FROM car_data 
WHERE company_names IS NOT NULL;

SET sql_mode = '';

INSERT INTO cars (company_id, car_name, car_price, fuel_type, seats)
SELECT 
    m.company_id,
    cd.cars_names,
    CAST(REPLACE(REPLACE(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cd.cars_prices, '-', 1), '/', 1)), '$', ''), ',', '') AS UNSIGNED) AS clean_price,
    cd.fuel_types,
    CAST(cd.seats AS UNSIGNED)
FROM car_data cd
JOIN manufacturers m ON cd.company_names = m.company_name;


SET sql_mode = '';

INSERT INTO car_performance (car_id, engine, battery_capacity, horse_power, total_speed, performance_0_100, torque)
SELECT 
    c.car_id,
    MAX(cd.engines),            
    MAX(cd.battery_capacity),
    CAST(REPLACE(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(MAX(cd.horse_power), '-', 1), '/', 1)), ' hp', '') AS UNSIGNED),
    CAST(REPLACE(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(MAX(cd.total_speed), '-', 1), '/', 1)), ' km/h', '') AS UNSIGNED),
    CAST(REPLACE(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(MAX(cd.performance), '-', 1), '/', 1)), ' sec', '') AS DECIMAL(4,2)),
    CAST(REPLACE(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(MAX(cd.torque), '-', 1), '/', 1)), ' Nm', '') AS UNSIGNED)
FROM car_data cd
JOIN manufacturers m ON cd.company_names = m.company_name
JOIN cars c ON cd.cars_names = c.car_name AND m.company_id = c.company_id
GROUP BY c.car_id; 

SELECT 
    car_name, 
    car_price, 
    seats
FROM cars
WHERE fuel_type = 'Electric' AND seats >= 5
ORDER BY car_price ASC;

ALTER TABLE cars 
ADD COLUMN company_names VARCHAR(255);

SET SQL_SAFE_UPDATES = 0;
UPDATE cars c
JOIN manufacturers m ON c.company_id = m.company_id
SET c.company_names = m.company_name;

SELECT 
	company_names,
    car_name, 
    fuel_type, 
    car_price
FROM cars
ORDER BY car_price DESC
LIMIT 10;

SELECT 
    m.company_name, 
    c.car_name, 
    c.car_price
FROM cars c
JOIN manufacturers m ON c.company_id = m.company_id
ORDER BY m.company_name ASC;

SELECT 
    company_names,
    car_name,
    car_price,
    CASE 
        WHEN car_price < 30000 THEN 'Budget Segment'
        WHEN car_price BETWEEN 30000 AND 80000 THEN 'Premium Segment'
        ELSE 'Luxury Segment'
    END AS price_tier
FROM cars
WHERE car_price > 0
ORDER BY car_price DESC;

SELECT 
    company_names,
    COUNT(car_id) AS total_models_offered,
    ROUND(AVG(car_price), 2) AS brand_average_price
FROM cars
GROUP BY company_names
HAVING brand_average_price > 60000
ORDER BY brand_average_price DESC;

SELECT 
    m.company_name,
    c.car_name,
    c.car_price,
    c.fuel_type,
    p.horse_power,
    p.performance_0_100
FROM cars c
JOIN manufacturers m ON c.company_id = m.company_id
JOIN car_performance p ON c.car_id = p.car_id;

SELECT company_names, LENGTH(company_names) 
FROM car_data
WHERE company_names LIKE 'KIA%' OR company_names LIKE 'ROLLS ROYCE%';

UPDATE car_data
SET company_names = TRIM(company_names);

UPDATE car_data
SET `fuel_types` = CASE 
	WHEN LOWER(`fuel_types`) LIKE '%hybrid%electric%' 
      OR LOWER(`fuel_types`) LIKE '%electric%hybrid%' 
      OR LOWER(`fuel_types`) LIKE '%hybrid/electric%' THEN 'Hybrid'
    WHEN `fuel_types` LIKE '%hybrid%' OR `fuel_types` LIKE '%plug%' THEN 'Hybrid'
    WHEN `fuel_types` LIKE '%petrol%' THEN 'Petrol'
    WHEN `fuel_types` LIKE '%diesel%' THEN 'Diesel'
    WHEN `fuel_types` LIKE '%electric%' OR `fuel_types` LIKE '%EV%' THEN 'Electric'
    ELSE `fuel_types` 
END;

CREATE VIEW automotive_analysis AS
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

SELECT * FROM automotive_analysis;

SELECT * FROM automotive_analysis LIMIT 10;