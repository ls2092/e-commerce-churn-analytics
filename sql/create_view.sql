CREATE OR REPLACE VIEW vw_ecommerce_sales AS 
SELECT 
    c.customer_unique_id, 
    o.order_id, 
    o.order_purchase_timestamp, 
    oi.price, 
    oi.freight_value, 
    (oi.price + oi.freight_value) AS total_order_value
FROM olist_order o 
JOIN olist_order_items oi 
    ON o.order_id = oi.order_id 
JOIN olist_customer c 
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered';

SELECT * FROM vw_ecommerce_sales;


-- no. of distinct orders customers have made = distinct order ids
CREATE TABLE customer_rfm AS
-- no. of days since customer has made last purchase/last order date
WITH dataset_max_date AS (
    SELECT MAX(order_purchase_timestamp) AS max_date 
    FROM vw_ecommerce_sales
)

SELECT s.customer_unique_id, 
EXTRACT (DAY FROM d.max_date - MAX(s.order_purchase_timestamp)) AS recency_days,
COUNT(DISTINCT s.order_id) AS frequency, 
SUM(s.total_order_value) AS total_spent 
FROM vw_ecommerce_sales s
CROSS JOIN dataset_max_date d
GROUP BY s.customer_unique_id, d.max_date;

SELECT * FROM customer_rfm LIMIT 100;
