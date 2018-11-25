--Query 1
SELECT
    person_id AS customer_id,
    (SELECT concat(surname, ' ', middle_initials, ' ', forename) FROM person WHERE person.id = customer.person_id) as full_name,
    email_address,
    count(purchase_date) as books_purchased,
    COALESCE(SUM((SELECT SUM(purchase_price) FROM audiobook WHERE audiobook.ISBN = audiobook_purchases.ISBN)), 0.00) as total_spent
    FROM customer
    LEFT JOIN audiobook_purchases ON customer.person_id = audiobook_purchases.customer_id
    GROUP BY person_id ORDER BY total_spent DESC, full_name ASC;

--Query 2
SELECT ISBN, title FROM audiobook WHERE ISBN NOT IN (SELECT ISBN FROM audiobook_purchases) ORDER BY title ASC;

--Query 3
SELECT person_id as contributor_id,
       (SELECT concat(surname, ' ', middle_initials, ' ', forename) FROM person WHERE person.id = contributor.person_id) as full_name,
       GROUP_CONCAT(title ORDER BY title ASC) AS bought_and_contributed_to
       FROM contributor, audiobook_purchases, audiobook
       WHERE person_id = customer_id AND audiobook_purchases.ISBN = audiobook.ISBN
       GROUP BY person_id ORDER BY contributor_id ASC;
