DROP DATABASE IF EXISTS locw_bookstream;

CREATE DATABASE locw_bookstream;

USE locw_bookstream;

--Suggested name length:https://stackoverflow.com/questions/30485/what-is-a-reasonable-length-limit-on-person-name-fields
CREATE TABLE person (
    id INTEGER UNIQUE NOT NULL AUTO_INCREMENT,
    forename VARCHAR(50) NOT NULL,
    middle_initials VARCHAR(10),
    surname VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    PRIMARY KEY (id)
);

/*
Average word in English is 5 characters long, so 2500 allows a 500 words biography,
this seems reasonable due to wikipedia summaries being roughly 500 words.
*/
CREATE TABLE contributor (
    person_id INTEGER,
    biography VARCHAR(2500) NOT NULL,
    FOREIGN KEY (person_id) REFERENCES person (id),
    PRIMARY KEY (person_id)
);

/*
REGEX for email
https://stackoverflow.com/questions/50330109/simple-regex-pattern-for-email

Emails can have a maximum length of 320 as the user name can be 64 characters,
the '@' symbol requires 1 character, and the domain can be 255 characters.
*/
CREATE TABLE customer (
    person_id INTEGER,
    email_address VARCHAR(320) NOT NULL UNIQUE CHECK (email_address RLIKE '^[^@]+@[^@]+\.[^@]+$'),
    FOREIGN KEY (person_id) REFERENCES person (id),
    PRIMARY KEY (person_id)
);

/*
Not all phone numbers are unique to a single person (i.e. house numbers)
*/
CREATE TABLE phone_number (
    customer_id INTEGER,
    phone_number VARCHAR(20) NOT NULL CHECK (phone_number RLIKE '[\+0-9()\-\s]$'),
    FOREIGN KEY (customer_id) REFERENCES customer (person_id),
    PRIMARY KEY (phone_number, customer_id)
);

/*
Longest company name in UK (160 characters):
https://beta.companieshouse.gov.uk/company/04120480

Longest place names in the world (181) characters:
https://en.wikipedia.org/wiki/List_of_long_place_names

Longest country name in the world:
The United Kingdom of Great Britain and Northern Ireland (56)

Some countries don't have postcodes so can be NULL. The U.S. and Saudi Arabia
have quite long postcodes so 25 characters has been allowed
*/
CREATE TABLE publisher (
    name VARCHAR(200),
    building VARCHAR(75) NOT NULL,
    street VARCHAR(75),
    city VARCHAR(200) NOT NULL,
    country VARCHAR(75) NOT NULL,
    postcode VARCHAR(25),
    phone_number VARCHAR(20) CHECK (phone_number RLIKE '[\+0-9()\-\s]$'),
    established_date DATE NOT NULL,
    PRIMARY KEY (name)
);

/**
ISBN 13 max length: https://www.isbn-international.org/content/what-isbn

Time would ideally be stored in a large integer type as seconds in case an audiobook
is longer than a day.

Chose LONGBLOB to allow for audio book files up to 4GB (e.g. the bible on audible
which is 65 hours long)
**/
CREATE TABLE audiobook (
    ISBN VARCHAR(17) CHECK (ISBN RLIKE '[0-9\-]$'),
    title VARCHAR(250) NOT NULL,
    narrator_id INTEGER NOT NULL,
    running_time TIME NOT NULL CHECK (running_time > 0),
    age_rating INTEGER CHECK (age_rating >= 0),
    purchase_price FLOAT(10,2) NOT NULL DEFAULT 0,
    publisher_name VARCHAR(200) NOT NULL,
    published_date DATE NOT NULL,
    audiofile LONGBLOB NOT NULL,
    FOREIGN KEY (narrator_id) REFERENCES contributor (person_id),
    FOREIGN KEY (publisher_name) REFERENCES publisher (name),
    PRIMARY KEY (ISBN)
);


CREATE TABLE chapter (
    ISBN VARCHAR(17) CHECK (ISBN RLIKE '[0-9\-]$'),
    number INTEGER,
    title VARCHAR(250) NOT NULL,
    start TIME NOT NULL CHECK (start >= 0),
    FOREIGN KEY (ISBN) REFERENCES audiobook (ISBN),
    PRIMARY KEY (ISBN, number)
);

CREATE TABLE audiobook_authors (
    contributor_id INTEGER,
    ISBN VARCHAR(17) NOT NULL CHECK (ISBN RLIKE '[0-9\-]$'),
    FOREIGN KEY (contributor_id) REFERENCES contributor (person_id),
    FOREIGN KEY (ISBN) REFERENCES audiobook (ISBN),
    PRIMARY KEY (contributor_id, ISBN)
);


CREATE TABLE audiobook_purchases (
    customer_id INTEGER,
    ISBN VARCHAR(17) CHECK (ISBN RLIKE '[0-9\-]$'),
    purchase_date DATETIME NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer (person_id),
    FOREIGN KEY (ISBN) references audiobook (ISBN),
    PRIMARY KEY (customer_id, ISBN)
);


CREATE TABLE audiobook_reviews (
    customer_id INTEGER,
    ISBN VARCHAR(17) CHECK (ISBN RLIKE '[0-9\-]$'),
    rating INTEGER NOT NULL,
    title VARCHAR(250),
    comment VARCHAR(2500),
    verified BOOLEAN DEFAULT 0 NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer (person_id),
    FOREIGN KEY (ISBN) REFERENCES audiobook (ISBN),
    PRIMARY KEY (customer_id, ISBN)
);

/**
Code to load data from CSV files into database.
Allows easy modification of data in database
**/
LOAD DATA LOCAL INFILE 'data/persons.csv' INTO TABLE person
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (id,forename,middle_initials,surname,date_of_birth);

LOAD DATA LOCAL INFILE 'data/contributors.csv' INTO TABLE contributor
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (person_id,biography);

LOAD DATA LOCAL INFILE 'data/customers.csv' INTO TABLE customer
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (person_id,email_address);

LOAD DATA LOCAL INFILE 'data/phone_numbers.csv' INTO TABLE phone_number
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (customer_id,phone_number);

LOAD DATA LOCAL INFILE 'data/publishers.csv' INTO TABLE publisher
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (name,building,street,city,country,postcode,phone_number,established_date);

LOAD DATA LOCAL INFILE 'data/audiobooks.csv' INTO TABLE audiobook
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (ISBN,title,narrator_id,running_time,age_rating,purchase_price,publisher_name,published_date,audiofile);

LOAD DATA LOCAL INFILE 'data/chapters.csv' INTO TABLE chapter
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (ISBN,number,title,start);

LOAD DATA LOCAL INFILE 'data/audiobook_authors.csv' INTO TABLE audiobook_authors
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (contributor_id,ISBN);

LOAD DATA LOCAL INFILE 'data/audiobook_purchases.csv' INTO TABLE audiobook_purchases
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (customer_id,ISBN,purchase_date);

LOAD DATA LOCAL INFILE 'data/audiobook_reviews.csv' INTO TABLE audiobook_reviews
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (customer_id,ISBN,rating,title,comment,verified);

/**
VIEWS OF
**/
CREATE VIEW q1 AS
    SELECT
        person_id AS customer_id,
        (SELECT concat(surname, ' ', middle_initials, ' ', forename) FROM person WHERE person.id = customer.person_id) as full_name,
        email_address,
        count(purchase_date) as books_purchased,
        COALESCE(SUM((SELECT SUM(purchase_price) FROM audiobook WHERE audiobook.ISBN = audiobook_purchases.ISBN)), 0.00) as total_spent
        FROM customer
        LEFT JOIN audiobook_purchases ON customer.person_id = audiobook_purchases.customer_id
        GROUP BY person_id ORDER BY total_spent DESC, full_name ASC;

CREATE VIEW q2 AS
    SELECT ISBN, title FROM audiobook WHERE ISBN NOT IN (SELECT ISBN FROM audiobook_purchases) ORDER BY title ASC;

CREATE VIEW q3 AS
    SELECT person_id as contributor_id,
           (SELECT concat(surname, ' ', middle_initials, ' ', forename) FROM person WHERE person.id = contributor.person_id) as full_name,
           GROUP_CONCAT(title ORDER BY title ASC) AS bought_and_contributed_to
           FROM contributor, audiobook_purchases, audiobook
           WHERE person_id = customer_id AND audiobook_purchases.ISBN = audiobook.ISBN
           GROUP BY person_id ORDER BY contributor_id ASC;
