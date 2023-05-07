DROP DATABASE IF EXISTS projectdb CASCADE;

CREATE DATABASE projectdb;
USE projectdb;

SET mapreduce.map.output.compress = true;
SET mapreduce.map.output.compress.codec = org.apache.hadoop.io.compress.SnappyCodec;

-- Create tables
CREATE EXTERNAL TABLE acquisitions STORED AS AVRO LOCATION '/project/acquisitions' TBLPROPERTIES ('avro.schema.url' = '/project/avsc/acquisitions.avsc');
CREATE EXTERNAL TABLE objects STORED AS AVRO LOCATION '/project/objects' TBLPROPERTIES ('avro.schema.url' = '/project/avsc/objects.avsc');
CREATE EXTERNAL TABLE people STORED AS AVRO LOCATION '/project/people' TBLPROPERTIES ('avro.schema.url' = '/project/avsc/people.avsc');
CREATE EXTERNAL TABLE offices STORED AS AVRO LOCATION '/project/offices' TBLPROPERTIES ('avro.schema.url' = '/project/avsc/offices.avsc');
CREATE EXTERNAL TABLE relationships STORED AS AVRO LOCATION '/project/relationships' TBLPROPERTIES ('avro.schema.url' = '/project/avsc/relationships.avsc');
CREATE EXTERNAL TABLE milestones STORED AS AVRO LOCATION '/project/milestones' TBLPROPERTIES ('avro.schema.url' = '/project/avsc/milestones.avsc');
CREATE EXTERNAL TABLE ipos STORED AS AVRO LOCATION '/project/ipos' TBLPROPERTIES ('avro.schema.url' = '/project/avsc/ipos.avsc');
CREATE EXTERNAL TABLE degrees STORED AS AVRO LOCATION '/project/degrees' TBLPROPERTIES ('avro.schema.url' = '/project/avsc/degrees.avsc');
CREATE EXTERNAL TABLE investments STORED AS AVRO LOCATION '/project/investments' TBLPROPERTIES ('avro.schema.url' = '/project/avsc/investments.avsc');
CREATE EXTERNAL TABLE funds STORED AS AVRO LOCATION '/project/funds' TBLPROPERTIES ('avro.schema.url' = '/project/avsc/funds.avsc');
CREATE EXTERNAL TABLE funding_rounds STORED AS AVRO LOCATION '/project/funding_rounds' TBLPROPERTIES ('avro.schema.url' = '/project/avsc/funding_rounds.avsc');

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