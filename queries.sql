--Общее количество покупателей

SELECT COUNT(customer_id) AS customers_count
FROM customers;


--Топ 10 продавцов за все время

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.product_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
LEFT JOIN employees AS e
    ON s.sales_person_id = e.employee_id
LEFT JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 1 DESC
LIMIT 10;


--Продавцы, чья средняя выручка за сделку ниже 
--средней выручки за сделку по всем продавцам 

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    FLOOR(AVG(s.quantity * p.price)) AS average_income
FROM sales AS s
LEFT JOIN employees AS e
    ON s.sales_person_id = e.employee_id
LEFT JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY 1
HAVING
    FLOOR(AVG(s.quantity * p.price))
    < (
        SELECT FLOOR(AVG(s.quantity * p.price)) AS total_avg
        FROM sales AS s
        LEFT JOIN products AS p
            ON s.product_id = p.product_id
    )
ORDER BY 2;


--Выручка по продавцам и по дням недели

WITH sales_summary AS (
    SELECT
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        EXTRACT(isodow FROM s.sale_date) AS number_of_week,
        FLOOR(SUM(s.quantity * p.price)) AS income
    FROM sales AS s
    LEFT JOIN employees AS e
        ON s.sales_person_id = e.employee_id
    LEFT JOIN products AS p
        ON s.product_id = p.product_id
    GROUP BY 1, 2
    ORDER BY 2, 1
)

SELECT
    seller,
    income,
    CASE
        WHEN number_of_week = 1 THEN 'monday'
        WHEN number_of_week = 2 THEN 'tuesday'
        WHEN number_of_week = 3 THEN 'wednesday'
        WHEN number_of_week = 4 THEN 'thursday'
        WHEN number_of_week = 5 THEN 'friday'
        WHEN number_of_week = 6 THEN 'saturday'
        ELSE 'sunday'
    END AS day_of_week
FROM sales_summary;


--Возрастные группы покупателей

SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(customer_id) AS age_count
FROM customers
GROUP BY 1
ORDER BY 1;


---Количество покупателей и выручка по месяцам

SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
LEFT JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 1;


--Покупатели, чья первая покупка пришлась на время 
-- проведения специальных акций

WITH sales_data AS (
    SELECT
        s.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer,
        s.sale_date,
        p.price,
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        ROW_NUMBER()
            OVER (PARTITION BY s.customer_id ORDER BY s.sale_date)
            AS row
    FROM sales AS s
    LEFT JOIN products AS p
        ON s.product_id = p.product_id
    LEFT JOIN customers AS c
        ON s.customer_id = c.customer_id
    LEFT JOIN employees AS e
        ON s.sales_person_id = e.employee_id
    ORDER BY 1
)

SELECT
    customer,
    sale_date,
    seller
FROM sales_data
WHERE row = 1 AND price = 0;
