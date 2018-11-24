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
LOAD DATA LOCAL INFILE 'data/person.csv' INTO TABLE person
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (id,forename,middle_initials,surname,date_of_birth);

/*
Average word in English is 5 characters long, so 2500 allows a 500 words biography,
this seems reasonable due to wikipedia summaries being roughly 500 words.
*/
CREATE TABLE contributor (
    person_id INTEGER UNIQUE NOT NULL,
    biography VARCHAR(2500) NOT NULL,
    PRIMARY KEY (person_id),
    FOREIGN KEY (person_id) REFERENCES person (id)
);
LOAD DATA LOCAL INFILE 'data/contributor.csv' INTO TABLE contributor
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (person_id,biography);

/*
REGEX for email
https://stackoverflow.com/questions/50330109/simple-regex-pattern-for-email

Emails can have a maximum length of 320 as the user name can be 64 characters,
the '@' symbol requires 1 character, and the domain can be 255 characters.
*/
CREATE TABLE customer (
    person_id INTEGER UNIQUE NOT NULL,
    email_address VARCHAR(320) NOT NULL UNIQUE,
    FOREIGN KEY (person_id) REFERENCES person (id),
    PRIMARY KEY (person_id)
);
LOAD DATA LOCAL INFILE 'data/customer.csv' INTO TABLE customer
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (person_id,email_address);

/*
REGEX for phone number
https://stackoverflow.com/questions/20054770/regex-for-numbers-with-spaces-plus-sign-hyphen-and-brackets

Not all phone numbers are unique (i.e. house numbers)
*/
CREATE TABLE phone_number (
    customer_id INTEGER NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (phone_number, customer_id),
    FOREIGN KEY (customer_id) REFERENCES customer (person_id)
);
LOAD DATA LOCAL INFILE 'data/phone_number.csv' INTO TABLE phone_number
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (customer_id,phone_number);

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
    name VARCHAR(200) UNIQUE NOT NULL,
    building VARCHAR(75) NOT NULL,
    street VARCHAR(75),
    city VARCHAR(200) NOT NULL,
    country VARCHAR(75) NOT NULL,
    postcode VARCHAR(25),
    phone_number VARCHAR(20),
    established_date DATE NOT NULL,
    PRIMARY KEY (name)
);
LOAD DATA LOCAL INFILE 'data/publisher.csv' INTO TABLE publisher
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (name,building,street,city,country,postcode,phone_number,established_date);

/**
ISBN 13 max length: https://www.isbn-international.org/content/what-isbn

Time would ideally be stored in a large integer type as seconds in case an audiobook
is longer than a day.

Chose LONGBLOB to allow for audio book files up to 4GB (e.g. the bible on audible
which is 65 hours long)
**/
CREATE TABLE audiobook (
    ISBN VARCHAR(17) UNIQUE NOT NULL CHECK (ISBN LIKE '^[0-9-]*$'),
    title VARCHAR(250) NOT NULL,
    narrator_id INTEGER UNIQUE NOT NULL,
    running_time TIME NOT NULL CHECK (running_time > 0),
    age_rating INTEGER CHECK (age_rating >= 0),
    purchase_price FLOAT(10,2) NOT NULL DEFAULT 0,
    publisher_name VARCHAR(200) UNIQUE NOT NULL,
    published_date DATE NOT NULL,
    audiofile LONGBLOB NOT NULL,
    FOREIGN KEY (narrator_id) REFERENCES contributor (person_id),
    FOREIGN KEY (publisher_name) REFERENCES publisher (name),
    PRIMARY KEY (ISBN)
);
LOAD DATA LOCAL INFILE 'data/audiobook.csv' INTO TABLE audiobook
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (ISBN,title,narrator_id,running_time,age_rating,purchase_price,publisher_name,published_date,audiofile);


CREATE TABLE chapter (
    ISBN VARCHAR(17) UNIQUE NOT NULL CHECK (ISBN LIKE '^[0-9-]*$'),
    number INTEGER NOT NULL,
    title VARCHAR(250) NOT NULL,
    start TIME NOT NULL CHECK (start >= 0),
    PRIMARY KEY (ISBN, number),
    FOREIGN KEY (ISBN) REFERENCES audiobook (ISBN)
);
LOAD DATA LOCAL INFILE 'data/chapter.csv' INTO TABLE chapter
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (ISBN,number,title,start);


CREATE TABLE audiobook_authors (
    contributor_id INTEGER NOT NULL UNIQUE,
    ISBN VARCHAR(17) UNIQUE NOT NULL CHECK (ISBN LIKE '^[0-9-]*$'),
    FOREIGN KEY (contributor_id) REFERENCES contributor (person_id),
    FOREIGN KEY (ISBN) REFERENCES audiobook (ISBN),
    PRIMARY KEY (contributor_id, ISBN)
);
LOAD DATA LOCAL INFILE 'data/audiobook_authors.csv' INTO TABLE audiobook_authors
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (contributor_id,ISBN);


CREATE TABLE audiobook_purchases (
    customer_id INTEGER NOT NULL UNIQUE,
    ISBN VARCHAR(17) UNIQUE NOT NULL CHECK (ISBN LIKE '^[0-9-]*$'),
    purchase_date DATETIME NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer (person_id),
    FOREIGN KEY (ISBN) references audiobook (ISBN),
    PRIMARY KEY (customer_id, ISBN)
);
LOAD DATA LOCAL INFILE 'data/audiobook_purchases.csv' INTO TABLE audiobook_purchases
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (customer_id,ISBN,purchase_date);


CREATE TABLE audiobook_reviews (
    customer_id INTEGER NOT NULL UNIQUE,
    ISBN VARCHAR(17) UNIQUE NOT NULL CHECK (ISBN LIKE '^[0-9-]*$'),
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(250),
    comment VARCHAR(2500),
    verified Boolean NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer (person_id),
    FOREIGN KEY (ISBN) REFERENCES audiobook (ISBN),
    PRIMARY KEY (customer_id, ISBN)
);
LOAD DATA LOCAL INFILE 'data/audiobook_reviews.csv' INTO TABLE audiobook_reviews
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (customer_id,ISBN,rating,title,comment,verified);
