--Общее количество покупателей

SELECT COUNT(customer_id) as customers_count
FROM customers


--Топ 10 продавцов за все время

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.product_id) AS operations,
    SUM(FLOOR(s.quantity * p.price)) AS income
FROM sales AS s
LEFT JOIN employees AS e
    ON s.sales_person_id = e.employee_id
LEFT JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY 1
ORDER BY income DESC
LIMIT 10


--Продавцы, чья средняя выручка за сделку ниже средней выручки за сделку по всем продавцам 

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
ORDER BY average_income


--Выручка по продавцам и по дням недели

WITH sales_summary AS (
    SELECT
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        EXTRACT(ISODOW FROM s.sale_date) AS number_of_week,
        SUM(FLOOR(s.quantity * p.price)) AS income
    FROM sales AS s
    LEFT JOIN employees AS e
        ON s.sales_person_id = e.employee_id
    LEFT JOIN products AS p
        ON s.product_id = p.product_id
    GROUP BY 1, 2
    ORDER BY number_of_week, seller
)

SELECT
    seller,
    CASE
        WHEN number_of_week = 1 THEN 'Monday'
        WHEN number_of_week = 2 THEN 'Tuesday'
        WHEN number_of_week = 3 THEN 'Wednesday'
        WHEN number_of_week = 4 THEN 'Thursday'
        WHEN number_of_week = 5 THEN 'Friday'
        WHEN number_of_week = 6 THEN 'Saturday'
        ELSE 'Sunday'
    END AS day_of_week,
    income
FROM sales_summary
