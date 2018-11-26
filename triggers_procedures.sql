DELIMITER $$
DROP TRIGGER IF EXISTS validate_review;
CREATE TRIGGER validate_review BEFORE INSERT ON audiobook_reviews FOR EACH ROW
BEGIN
    IF (NEW.rating < 1 OR NEW.rating > 5)
    THEN
        SIGNAL sqlstate '45001' set message_text = "Invalid Rating! Out of range.";
    END IF;

    IF EXISTS (SELECT * FROM audiobook_purchases WHERE NEW.customer_id = audiobook_purchases.customer_id AND NEW.ISBN = audiobook_purchases.ISBN)
    THEN
        SET NEW.verified = 1;
    ELSE
        SET NEW.verified = 0;
    END IF;
END
$$
DELIMITER ;

DELIMITER $$
DROP TRIGGER IF EXISTS validate_age;
CREATE TRIGGER validate_age BEFORE INSERT ON audiobook_purchases FOR EACH ROW
BEGIN
    DECLARE age INTEGER;
    DECLARE rating INTEGER;
    SELECT TIMESTAMPDIFF(YEAR, (SELECT date_of_birth FROM person WHERE person.id = NEW.customer_id), NEW.purchase_date) INTO age;
    SELECT age_rating INTO rating FROM audiobook WHERE audiobook.ISBN = NEW.ISBN;

    IF (age < rating)
    THEN
        SIGNAL sqlstate '45001' set message_text = "You are not old enough to by that book!";
    END IF;
END
$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS insertCustomer;
CREATE PROCEDURE insertCustomer(
    IN ID INTEGER, IN forename VARCHAR(50),
    IN midInitials VARCHAR(10), IN surname VARCHAR(50),
    IN dob DATE, IN email VARCHAR(320)
)
BEGIN
    INSERT INTO person VALUES (ID, forename, midInitials, surname, dob);

    IF EXISTS (SELECT id FROM person WHERE id = ID)
    THEN
        INSERT INTO customer VALUES (id, email);
    ELSE
        SIGNAL sqlstate '45001' set message_text = "Invalid credentials, failed to insert as customer.";
    END IF;
END

DROP PROCEDURE IF EXISTS insertContributor;
CREATE PROCEDURE insertContributor(
    IN ID INTEGER, IN forename VARCHAR(50),
    IN midInitials VARCHAR(10), IN surname VARCHAR(50),
    IN dob DATE, IN biography VARCHAR(2500)
)
BEGIN
    INSERT INTO person VALUES (ID, forename, midInitials, surname, dob);

    IF EXISTS (SELECT id FROM person WHERE id = ID)
    THEN
        INSERT INTO contributor VALUES (id, biography);
    ELSE
        SIGNAL sqlstate '45001' set message_text = "Invalid credentials, failed to insert as contributor.";
    END IF;
END
$$
DELIMITER ;
