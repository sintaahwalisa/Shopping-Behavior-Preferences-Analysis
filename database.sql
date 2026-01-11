CREATE TABLE staging (
    customer_id INT,
    age INT,
    gender VARCHAR(50),
    item_purchased VARCHAR(255),
    category VARCHAR(100),
    purchase_amount_usd NUMERIC(10, 2), -- Menggunakan NUMERIC untuk mata uang
    location VARCHAR(100),
    size VARCHAR(20),
    color VARCHAR(50),
    season VARCHAR(50),
    review_rating NUMERIC(2, 1),      -- Menggunakan NUMERIC untuk rating 1-5
    subscription_status VARCHAR(50),
    shipping_type VARCHAR(50),
    discount_applied BOOLEAN,         -- Asumsi: TRUE/FALSE atau 1/0 di CSV
    promo_code_used BOOLEAN,          -- Asumsi: TRUE/FALSE atau 1/0 di CSV
    previous_purchases INT,
    payment_method VARCHAR(50),
    frequency_of_purchases VARCHAR(50)
);

COPY staging (customer_id, age, gender, item_purchased, category, purchase_amount_usd, location, size, color, season, review_rating, subscription_status, shipping_type, discount_applied, promo_code_used, previous_purchases, payment_method, frequency_of_purchases)
FROM 'C:\\tmp\\shopping_behavior_updated.csv' 
DELIMITER ','
CSV HEADER;  


CREATE TABLE dim_customers (
    customer_id INT PRIMARY KEY,
    age INT,
    gender VARCHAR(50),
    location VARCHAR(100),
    subscription_status VARCHAR(50),
    frequency_of_purchases VARCHAR(50),
    previous_purchases INT
);

CREATE TABLE dim_products (
    item_name VARCHAR(255) PRIMARY KEY,
    category VARCHAR(100),
    review_rating NUMERIC(2, 1),
    size VARCHAR(20),
    color VARCHAR(50),
    season VARCHAR(50)
);

CREATE TABLE fact_transactions (
    transaction_id SERIAL PRIMARY KEY, 
    customer_id INT REFERENCES dim_customers(customer_id),
    item_name VARCHAR(255) REFERENCES dim_products(item_name),
    purchase_amount_usd NUMERIC(10, 2),
    shipping_type VARCHAR(50),
    discount_applied BOOLEAN,
    promo_code_used BOOLEAN,
    payment_method VARCHAR(50)
);


INSERT INTO dim_customers (customer_id, age, gender, location, subscription_status, frequency_of_purchases, previous_purchases)
SELECT DISTINCT
    "customer_id",
    "age",
    "gender",
    "location",
    "subscription_status",
    "frequency_of_purchases",
    "previous_purchases"
FROM staging
ON CONFLICT (customer_id) DO NOTHING; 




INSERT INTO dim_products (item_name, category, review_rating, size, color, season)
SELECT DISTINCT
    "item_purchased",
    "category",
    "review_rating",
    "size",
    "color",
    "season"
FROM staging
ON CONFLICT (item_name) DO NOTHING; 

INSERT INTO fact_transactions (customer_id, item_name, purchase_amount_usd, shipping_type, discount_applied, promo_code_used, payment_method)
SELECT
    "customer_id",
    "item_purchased",
    "purchase_amount_usd",
    "shipping_type",
    "discount_applied",
    "promo_code_used",
    "payment_method"
FROM staging;

SELECT * FROM staging;
SELECT * FROM dim_customers;
SELECT * FROM dim_products;
SELECT * FROM fact_transactions;