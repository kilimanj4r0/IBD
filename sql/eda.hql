USE projectdb;


INSERT OVERWRITE LOCAL DIRECTORY 'output/q1' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','

SELECT category_code, AVG(funding_total_usd) / 1000000 AS avg_funding_m, COUNT(funding_total_usd) AS funding_count
FROM projectdb.objects
WHERE entity_type = 'Company' AND funding_total_usd != 0
GROUP BY category_code
ORDER BY avg_funding_m DESC;


INSERT OVERWRITE LOCAL DIRECTORY 'output/q2' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','

SELECT country_code, AVG(funding_total_usd) / 1000000 AS avg_funding_m, COUNT(funding_total_usd) AS funding_count
FROM projectdb.objects
WHERE entity_type = 'Company' AND funding_total_usd != 0
GROUP BY country_code
ORDER BY avg_funding_m DESC;


WITH empl_by_com AS
(
    SELECT relationship_object_id as company_id, COUNT(*) as employees FROM projectdb.relationships
    GROUP BY relationship_object_id
), companies AS 
(
    SELECT * FROM projectdb.objects
    WHERE entity_type = 'Company'
)

INSERT OVERWRITE LOCAL DIRECTORY 'output/q3' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','

SELECT e.*, c.funding_total_usd FROM empl_by_com AS e
JOIN companies AS c ON e.company_id = c.id;


WITH companies AS 
(
    SELECT * FROM projectdb.objects
    WHERE entity_type = 'Company'
), count_by_degree AS (
    SELECT degree_type, COUNT(*) AS count
    FROM projectdb.degrees
    GROUP BY degree_type
    ORDER BY count DESC
    LIMIT 30
), funds_by_degree AS(
    SELECT d.degree_type, SUM(c.funding_total_usd) AS count_fundrasings
    FROM projectdb.relationships AS r
    JOIN projectdb.degrees AS d ON r.person_object_id = d.object_id
    JOIN companies AS c ON r.relationship_object_id = c.id
    WHERE c.funding_total_usd != 0
    GROUP BY d.degree_type
)

INSERT OVERWRITE LOCAL DIRECTORY 'output/q4' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','


SELECT c.degree_type, CAST((count_fundrasings / count) AS decimal(15,5)) AS avg_degree_fundings FROM count_by_degree AS c
JOIN funds_by_degree AS f ON c.degree_type = f.degree_type
ORDER BY avg_degree_fundings DESC;


INSERT OVERWRITE LOCAL DIRECTORY 'output/q5' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','

SELECT YEAR(from_unixtime(CAST((funded_at / 1000) AS bigint))) AS year, CAST(SUM(raised_amount) AS decimal(20,5)) AS sum_raised
FROM projectdb.funds
WHERE raised_currency_code = 'USD'
GROUP BY YEAR(from_unixtime(CAST((funded_at / 1000) AS bigint)))
ORDER BY year;
