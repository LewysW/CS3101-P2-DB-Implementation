DROP DATABASE [IF EXISTS] locw_bookstream;

CREATE DATABASE locw_bookstream;

USE locw_bookstream;

/*
Suggested name length:
https://stackoverflow.com/questions/30485/what-is-a-reasonable-length-limit-on-person-name-fields
*/
CREATE TABLE person (
    id INTEGER UNSIGNED NOT NULL UNIQUE AUTO_INCREMENT,
    forename VARCHAR(50) NOT NULL,
    middle_initials VARCHAR (10),
    surname VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL CHECK (date_of_birth <= GetDate()),
    PRIMARY KEY (id)
);

/*
Average word in English is 5 characters long, so 2500 allows a 500 words biography,
this seems reasonable due to wikipedia summaries being roughly 500 words.
*/
CREATE TABLE contributor (
    biography VARCHAR(2500),
    FOREIGN KEY (person_id) REFERENCES person (id)
);

/*
REGEX for email
https://stackoverflow.com/questions/50330109/simple-regex-pattern-for-email

Emails can have a maximum length of 320 as the user name can be 64 characters,
the '@' symbol requires 1 character, and the domain can be 255 characters.
*/
CREATE TABLE customer (
    email_address VARCHAR(320) UNIQUE CHECK (email_address LIKE '^[^@]+@[^@]+\.[^@]+$'),
    FOREIGN KEY (person_id) REFERENCES person (id)
);

/*
REGEX for phone number
https://stackoverflow.com/questions/20054770/regex-for-numbers-with-spaces-plus-sign-hyphen-and-brackets

Not all phone numbers are unique (i.e. house numbers)
*/
CREATE TABLE phone_number (
    phone_number VARCHAR(20) CHECK (phone_number LIKE '^\(?\+?[\d\(\-\s\)]+$'),
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
    name VARCHAR(200) UNIQUE NOT NULL,
    building VARCHAR(75) NOT NULL,
    street VARCHAR(75),
    city VARCHAR(200) NOT NULL,
    country VARCHAR(75) NOT NULL,
    postcode VARCHAR(25),
    phone_number VARCHAR(20) CHECK (phone_number LIKE '^\(?\+?[\d\(\-\s\)]+$'),
    established_date DATE NOT NULL CHECK (established_date <= GetDate()),
    PRIMARY KEY (name)
);

/**
ISBN 13 max length: https://www.isbn-international.org/content/what-isbn
**/
CREATE TABLE audiobook (
    ISBN VARCHAR(17) UNIQUE NOT NULL CHECK(ISBN LIKE '^[0-9-]*$'),
    title VARCHAR(250) NOT NULL,

);
