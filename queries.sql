--Query 1
SELECT person_id AS 'customer_id',
(SELECT concat(forename, ' ', middle_initials, ' ', surname) FROM person WHERE customer_id = person_id) as 'full name',
email_address, count(purchase_date) as 'Number of Purchases'
FROM (customer NATURAL LEFT OUTER JOIN audiobook_purchases NATURAL LEFT OUTER JOIN audiobook) GROUP BY customer_id;

SELECT * FROM audiobook_purchases;

(SELECT audiobook_purchases.person_id as id, SUM(purchase_price) FROM audiobook, audiobook_purchases WHERE audiobook.ISBN = audiobook_purchases.ISBN GROUP BY id);

SELECT * FROM audiobook;
--Query 2


--Query 3
