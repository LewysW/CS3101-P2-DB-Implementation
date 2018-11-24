--Query 1
SELECT person_id AS customer_id, concat(surname, ' ', middle_initials, ' ', forename) as full_name, email_address, count(purchase_date) as books_purchased, COALESCE(SUM((SELECT SUM(purchase_price)
FROM audiobook WHERE audiobook.ISBN = audiobook_purchases.ISBN)), 0.00) as total_spent
FROM customer
NATURAL LEFT JOIN audiobook_purchases
NATURAL LEFT JOIN person GROUP BY person_id ORDER BY total_spent DESC, full_name ASC;
--Query 2


--Query 3
