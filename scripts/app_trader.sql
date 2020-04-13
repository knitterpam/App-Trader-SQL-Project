/*
SELECT app_store_apps.name, play_store_apps.name
FROM app_store_apps LEFT JOIN play_store_apps
USING(name)
WHERE app_store_apps.name is not null AND play_store_apps.name is not null;

SELECT app_store_apps.name AS app_name, play_store_apps.name AS play_name, app_store_apps.price AS app_price, play_store_apps.price AS play_price
FROM app_store_apps LEFT JOIN play_store_apps
USING(name)
WHERE app_store_apps.name is not null AND play_store_apps.name is not null
ORDER by app_price DESC;

-Comparing prices - cheaper on Apple
SELECT app_store_apps.name AS app_name, play_store_apps.name AS play_name, app_store_apps.price AS app_price, play_store_apps.price AS play_price
FROM app_store_apps LEFT JOIN play_store_apps
USING(name)
WHERE app_store_apps.name is not null AND play_store_apps.name is not null
ORDER by app_price DESC;

ASSUMPTION A:

SELECT app_store_apps.name AS app_name, play_store_apps.name AS play_name,
(CAST(app_store_apps.price as decimal) *10000) AS app_purchase_price,
(CAST(REPLACE(TRIM(play_store_apps.price), '$', '') AS decimal) *10000) AS play_purchase_price
FROM app_store_apps LEFT JOIN play_store_apps
USING(name)
WHERE app_store_apps.name is not null
AND play_store_apps.name is not null
ORDER by play_purchase_price DESC;

--Install count for play store:
SELECT CAST(REPLACE (REPLACE(install_count,'+',''),',','')as decimal)AS new_install_count, name
FROM play_store_apps
ORDER BY new_install_count DESC;


-- looks like 328 common apps between stores?
SELECT
	app_store_apps.name, 
	ROUND(AVG(app_store_apps.rating)) as appstore_avg_rating,
	play_store_apps.name,
	ROUND(AVG(play_store_apps.rating)) as playstore_avg_rating
FROM app_store_apps INNER JOIN play_store_apps
USING (name)
GROUP BY app_store_apps.name, play_store_apps.name
ORDER BY appstore_avg_rating DESC, playstore_avg_rating DESC;
*/

--Summarize price info for app_store_apps
-- initially used WHERE price <> 0 after FROM stmt, but that excludes free apps:
SELECT primary_genre,
	MIN(price),
	ROUND(AVG(price),2) AS avg_price,
	ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP
		  (ORDER BY price)::numeric, 2) AS median_price,
	MAX(price)
FROM app_store_apps
GROUP BY primary_genre; 

--Summarize price info for play_store_apps
--Mary offered:  to_number(p.price, ‘G999D99’) as play_store_price
--Mahesh offered: try using REPLACE or TRANSLATE to remove the $ and . 
--before casting it to a different type
--CAST(REPLACE(TRIM(play_store_apps.price), '$', '') AS decimal)

SELECT genres,
	MIN(price::numeric),(REPLACE(TRIM(play_store_apps.price), '$', '') AS decimal
	ROUND(AVG(price::numeric),0) AS avg_price,
	PERCENTILE_CONT(0.50) WITHIN GROUP 
		(ORDER BY price::numeric) AS median_price
FROM play_store_apps
GROUP BY genres;
						 
SELECT primary_genre, count(primary_genre), rating,
	MIN(price),
	ROUND(AVG(price),2) AS avg_price,
	ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP
		  (ORDER BY price)::numeric, 2) AS median_price,
	MAX(price)
FROM app_store_apps
GROUP BY primary_genre, rating
ORDER BY primary_genre DESC, rating DESC; 

