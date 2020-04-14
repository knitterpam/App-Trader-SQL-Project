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

--Explore app genres and categories from each db.
-- 23 rows in Apple store, 119 in Android store
-- (NOTE: Android genres offer subcategories using genres,
-- wider genre is covered by Category field info, 33 categories available)
SELECT DISTINCT primary_genre
FROM app_store_apps;

SELECT DISTINCT genres
FROM play_store_apps;

SELECT DISTINCT category
FROM play_store_apps;


--Summarize price info by genre for app_store_apps
-- initially used WHERE price <> 0 after FROM stmt, but that excludes free apps:
SELECT primary_genre,
	MIN(price),
	ROUND(AVG(price),2) AS avg_price,
	ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP
		  (ORDER BY price)::numeric, 2) AS median_price,
	MAX(price)
FROM app_store_apps
GROUP BY primary_genre; 

--Summarize price info by genre for play_store_apps

SELECT DISTINCT genres,
	MIN(to_number(price, 'G999D99')),
	ROUND(AVG(to_number(price, 'G999D99')),2) AS avg_price,
	PERCENTILE_CONT(0.50) WITHIN GROUP 
		(ORDER BY to_number(price, 'G999D99')) AS median_price,
	MAX(to_number(price, 'G999D99'))
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

--testing profit column calc for each database		
SELECT name, rating, to_number(price, 'G999D99') AS play_store_price, PROFIT HERE
FROM app_store_apps
ORDER BY app_store_price DESC
LIMIT 25;	

SELECT name, rating, to_number(price, 'G999D99') AS play_store_price, PROFIT HERE
FROM play_store_apps
ORDER BY play_store_price DESC
LIMIT 25;	

--Nicole and Jacob contributed to joining app tables, calculating purch price
--Pam added genre and rating, and order by info
SELECT app_store_apps.name AS app_name,
	app_store_apps.primary_genre,
	play_store_apps.name AS play_name,
	play_store_apps.genres,
	play_store_apps.rating AS ps_apps_rating,
	app_store_apps.rating AS app_apps_rating,
	CASE WHEN CAST(app_store_apps.price as money) <='0.99' THEN '$10,000'
		 WHEN CAST(app_store_apps.price as money) >'0.99' 
		 THEN CAST(app_store_apps.price as money)*10000
		 END AS app_purch_price,
	CASE WHEN CAST(REPLACE(TRIM(play_store_apps.price), '$', '') AS money) <='0.99'
		 THEN '$10,000'
		 WHEN CAST(REPLACE(TRIM(play_store_apps.price), '$', '') AS money) >'0.99' 
		 THEN CAST(play_store_apps.price as money)*10000
		 END AS play_purch_price
FROM app_store_apps LEFT JOIN play_store_apps
USING(name)
WHERE app_store_apps.name is not null 
	AND play_store_apps.name is not null
	AND play_store_apps.rating > 4.5
	AND app_store_apps.rating > 4.0
ORDER by ps_apps_rating DESC, app_store_apps.rating DESC
LIMIT 25;

--version using review_count instead of rating
--need to combine with Jacob's joined tables to reduce duplicate names
--and work in Cat's install_count case stmts possibly
SELECT app_store_apps.name AS app_name,
	app_store_apps.primary_genre,
	play_store_apps.name AS play_name,
	play_store_apps.genres,
	play_store_apps.review_count AS ps_apps_review,
	app_store_apps.review_count AS app_apps_review,
	play_store_apps.rating AS ps_apps_rating,
	CASE WHEN CAST(app_store_apps.price as money) <='0.99' THEN '$10,000'
		 WHEN CAST(app_store_apps.price as money) >'0.99' 
		 THEN CAST(app_store_apps.price as money)*10000
		 END AS app_purch_price,
	CASE WHEN CAST(REPLACE(TRIM(play_store_apps.price), '$', '') AS money) <='0.99'
		 THEN '$10,000'
		 WHEN CAST(REPLACE(TRIM(play_store_apps.price), '$', '') AS money) >'0.99' 
		 THEN CAST(play_store_apps.price as money)*10000
		 END AS play_purch_price
FROM app_store_apps LEFT JOIN play_store_apps
USING(name)
WHERE app_store_apps.name is not null 
	AND play_store_apps.name is not null
	AND play_store_apps.rating > 4.5
ORDER by ps_apps_review DESC, ps_apps_rating DESC
LIMIT 25;

