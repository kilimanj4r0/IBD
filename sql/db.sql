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
CREATE TABLE objects
(
    id                  VARCHAR(255) PRIMARY KEY NOT NULL,
    entity_type         VARCHAR(50),
    entity_id           BIGINT,
    parent_id           VARCHAR(255),
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

-- degrees table
-- CREATE TABLE degrees
-- (
--     id           SERIAL PRIMARY KEY,
--     object_id    VARCHAR(255) NOT NULL,
--     degree_type  VARCHAR(255) NOT NULL,
--     subject      VARCHAR(255),
--     institution  VARCHAR(255),
--     graduated_at DATE,
--     created_at   TIMESTAMP DEFAULT NOW(),
--     updated_at   TIMESTAMP DEFAULT NOW(),
--     CONSTRAINT fk_degrees_objects
--         FOREIGN KEY (object_id)
--             REFERENCES objects (id)
--             ON DELETE CASCADE
-- );


-- Add constraints
-- FKs
-- ALTER TABLE emps
--     ADD CONSTRAINT fk_emps_mgr_empno FOREIGN KEY (mgr) REFERENCES emps (empno);

SET datestyle TO iso, ymd;

\COPY acquisitions FROM 'data/acquisitions.csv' DELIMITER ',' CSV HEADER;
\COPY objects FROM 'data/objects.csv' DELIMITER ',' CSV HEADER;

-- optional
COMMIT;

-- For checking the content of tables
SELECT *
FROM acquisitions
LIMIT 1;
SELECT *
FROM objects
LIMIT 1;
