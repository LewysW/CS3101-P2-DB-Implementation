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
END $$
DELIMITER ;
