\c project;

-- Add tables
-- acquisitions table
DROP TABLE IF EXISTS acquisitions;
CREATE TABLE acquisitions
(
    id                  SERIAL PRIMARY KEY,
    acquisition_id      INTEGER NOT NULL,
    acquiring_object_id VARCHAR(255),
    acquired_object_id  VARCHAR(255),
    term_code           VARCHAR(255),
    price_amount        NUMERIC(19, 2),
    price_currency_code VARCHAR(3),
    acquired_at         DATE,
    source_url          TEXT,
    source_description  TEXT,
    created_at          TIMESTAMP,
    updated_at          TIMESTAMP
);

-- objects table
DROP TABLE IF EXISTS objects;
CREATE TABLE objects
(
    id                  VARCHAR(255) PRIMARY KEY NOT NULL,
    entity_type         VARCHAR(50),
    entity_id           BIGINT,
    parent_id           VARCHAR(255), -- all NULL
    name                VARCHAR(255),
    normalized_name     VARCHAR(255),
    permalink           VARCHAR(255),
    category_code       VARCHAR(50),
    status              VARCHAR(50),
    founded_at          DATE,
    closed_at           DATE,
    domain              VARCHAR(255),
    homepage_url        VARCHAR(500),
    twitter_username    VARCHAR(50),
    logo_url            VARCHAR(500),
    logo_width          SMALLINT,
    logo_height         SMALLINT,
    short_description   TEXT,
    description         TEXT,
    overview            TEXT,
    tag_list            TEXT,
    country_code        VARCHAR(3),
    state_code          VARCHAR(2),
    city                VARCHAR(255),
    region              VARCHAR(255),
    first_investment_at DATE,
    last_investment_at  DATE,
    investment_rounds   SMALLINT,
    invested_companies  SMALLINT,
    first_funding_at    DATE,
    last_funding_at     DATE,
    funding_rounds      SMALLINT,
    funding_total_usd   NUMERIC(19, 2),
    first_milestone_at  DATE,
    last_milestone_at   DATE,
    milestones          SMALLINT,
    relationships       SMALLINT,
    created_by          VARCHAR(255),
    created_at          TIMESTAMP,
    updated_at          TIMESTAMP
);

-- people table
DROP TABLE IF EXISTS people;
CREATE TABLE people
(
    id               SERIAL PRIMARY KEY NOT NULL,
    object_id        VARCHAR(10),
    first_name       VARCHAR(255),
    last_name        VARCHAR(255),
    birthplace       VARCHAR(255),
    affiliation_name VARCHAR(255)
);

-- offices table
DROP TABLE IF EXISTS offices;
CREATE TABLE offices
(
    id           SERIAL PRIMARY KEY NOT NULL,
    object_id    VARCHAR(255),
    office_id    INTEGER,
    description  VARCHAR(255),
    region       VARCHAR(255),
    address1     VARCHAR(255),
    address2     VARCHAR(255),
    city         VARCHAR(255),
    zip_code     VARCHAR(255),
    state_code   VARCHAR(2),
    country_code VARCHAR(3),
    latitude     DOUBLE PRECISION,
    longitude    DOUBLE PRECISION,
    created_at   TIMESTAMP,
    updated_at   TIMESTAMP
);

-- relationships table
DROP TABLE IF EXISTS relationships;
CREATE TABLE relationships
(
    id                     SERIAL PRIMARY KEY NOT NULL,
    relationship_id        BIGINT,
    person_object_id       VARCHAR(255),
    relationship_object_id VARCHAR(255),
    start_at               DATE,
    end_at                 DATE,
    is_past                BOOLEAN,
    sequence               BIGINT,
    title                  TEXT,
    created_at             TIMESTAMP,
    updated_at             TIMESTAMP
);

-- milestones table
DROP TABLE IF EXISTS milestones;
CREATE TABLE milestones
(
    id                 SERIAL PRIMARY KEY NOT NULL,
    object_id          VARCHAR(255),
    milestone_at       DATE,
    milestone_code     VARCHAR(255),
    description        TEXT,
    source_url         TEXT,
    source_description TEXT,
    created_at         TIMESTAMP,
    updated_at         TIMESTAMP
);

-- ipos table
DROP TABLE IF EXISTS ipos;
CREATE TABLE ipos
(
    id                      SERIAL PRIMARY KEY NOT NULL,
    ipo_id                  BIGINT             NOT NULL,
    object_id               VARCHAR(255),
    valuation_amount        NUMERIC(19, 2),
    valuation_currency_code VARCHAR(3),
    raised_amount           NUMERIC(19, 2),
    raised_currency_code    VARCHAR(3),
    public_at               DATE,
    stock_symbol            VARCHAR(255),
    source_url              TEXT,
    source_description      TEXT,
    created_at              TIMESTAMP,
    updated_at              TIMESTAMP
);

-- degrees table
DROP TABLE IF EXISTS degrees;
CREATE TABLE degrees
(
    id           SERIAL PRIMARY KEY NOT NULL,
    object_id    VARCHAR(255),
    degree_type  VARCHAR(255),
    subject      VARCHAR(255),
    institution  VARCHAR(255),
    graduated_at DATE,
    created_at   TIMESTAMP,
    updated_at   TIMESTAMP
);

-- investments table
DROP TABLE IF EXISTS investments;
CREATE TABLE investments
(
    id                 SERIAL PRIMARY KEY NOT NULL,
    funding_round_id   INTEGER,
    funded_object_id   VARCHAR(255),
    investor_object_id VARCHAR(255),
    created_at         TIMESTAMP,
    updated_at         TIMESTAMP
);

-- funds table
DROP TABLE IF EXISTS funds;
CREATE TABLE funds
(
    id                   INTEGER PRIMARY KEY NOT NULL,
    fund_id              INTEGER,
    object_id            VARCHAR(255),
    name                 TEXT,
    funded_at            DATE,
    raised_amount        NUMERIC(19, 2),
    raised_currency_code VARCHAR(3),
    source_url           TEXT,
    source_description   TEXT,
    created_at           TIMESTAMP,
    updated_at           TIMESTAMP
);

-- funding_rounds table
DROP TABLE IF EXISTS funding_rounds;
CREATE TABLE funding_rounds
(
    id                       SERIAL PRIMARY KEY NOT NULL,
    funding_round_id         BIGINT,
    object_id                VARCHAR(255),
    funded_at                DATE,
    funding_round_type       VARCHAR(255),
    funding_round_code       VARCHAR(255),
    raised_amount_usd        NUMERIC(19, 2),
    raised_amount            NUMERIC(19, 2),
    raised_currency_code     VARCHAR(3),
    pre_money_valuation_usd  NUMERIC(19, 2),
    pre_money_valuation      NUMERIC(19, 2),
    pre_money_currency_code  VARCHAR(3),
    post_money_valuation_usd NUMERIC(19, 2),
    post_money_valuation     NUMERIC(19, 2),
    post_money_currency_code VARCHAR(3),
    participants             SMALLINT,
    is_first_round           SMALLINT,
    is_last_round            SMALLINT,
    source_url               TEXT,
    source_description       TEXT,
    created_by               VARCHAR(255),
    created_at               TIMESTAMP,
    updated_at               TIMESTAMP
);

-- Add constraints
-- FKs
-- ALTER TABLE emps
--     ADD CONSTRAINT fk_emps_mgr_empno FOREIGN KEY (mgr) REFERENCES emps (empno);

SET datestyle TO iso, ymd;

\COPY acquisitions FROM 'data/acquisitions.csv' DELIMITER ',' CSV HEADER;
\COPY objects FROM 'data/objects.csv' DELIMITER ',' CSV HEADER;
\COPY people FROM 'data/people.csv' DELIMITER ',' CSV HEADER;
\COPY offices FROM 'data/offices.csv' DELIMITER ',' CSV HEADER;
\COPY relationships FROM 'data/relationships.csv' DELIMITER ',' CSV HEADER;
\COPY milestones FROM 'data/milestones.csv' DELIMITER ',' CSV HEADER;
\COPY ipos FROM 'data/ipos.csv' DELIMITER ',' CSV HEADER;
\COPY degrees FROM 'data/degrees.csv' DELIMITER ',' CSV HEADER;
\COPY investments FROM 'data/investments.csv' DELIMITER ',' CSV HEADER;
\COPY funds FROM 'data/funds.csv' DELIMITER ',' CSV HEADER;
\COPY funding_rounds FROM 'data/funding_rounds.csv' DELIMITER ',' CSV HEADER;

-- For checking the content of tables
SELECT *
FROM acquisitions
LIMIT 1;
SELECT *
FROM objects
LIMIT 1;
SELECT *
FROM people
LIMIT 1;
SELECT *
FROM offices
LIMIT 1;
SELECT *
FROM relationships
LIMIT 1;
SELECT *
FROM milestones
LIMIT 1;
SELECT *
FROM ipos
LIMIT 1;
SELECT *
FROM degrees
LIMIT 1;
SELECT *
FROM investments
LIMIT 1;
SELECT *
FROM funds
LIMIT 1;
SELECT *
FROM funding_rounds
LIMIT 1;
