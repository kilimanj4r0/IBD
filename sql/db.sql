DROP DATABASE IF EXISTS project;
CREATE DATABASE project;

\c project;

-- Add tables
-- acquisitions table
DROP TABLE IF EXISTS acquisitions;
CREATE TABLE acquisitions
(
    id                  SERIAL PRIMARY KEY,                     -- auto-incrementing ID
    acquisition_id      INTEGER NOT NULL,                       -- ID of the acquisition
    acquiring_object_id VARCHAR(255),                           -- ID of the acquiring object
    acquired_object_id  VARCHAR(255),                           -- ID of the acquired object
    term_code           VARCHAR(255),                           -- code for the acquisition term, if any
    price_amount        NUMERIC(19, 2),                         -- amount of money paid for the acquisition
    price_currency_code VARCHAR(3),                             -- currency code for the price
    acquired_at         DATE,                                   -- date of the acquisition, with time zone
    source_url          TEXT,                                   -- URL of the source for the acquisition data
    source_description  TEXT,                                   -- description of the source for the acquisition data
    created_at          TIMESTAMP DEFAULT NOW(),                -- date and time the record was created, with time zone
    updated_at          TIMESTAMP DEFAULT NOW() ON UPDATE NOW() -- date and time the record was last updated, with time zone and automatic update on change
);

-- Add constraints
-- FKs
-- ALTER TABLE emps
--     ADD CONSTRAINT fk_emps_mgr_empno FOREIGN KEY (mgr) REFERENCES emps (empno);

SET datestyle TO iso, ymd;

\COPY emps FROM 'data/acquisitions.csv' DELIMITER ',' CSV HEADER;

-- optional
COMMIT;

-- For checking the content of tables
SELECT *
FROM acquisitions
LIMIT 10;
