-- NETFLIX PROJECT

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

SELECT * FROM netflix


-- Count the Number of Movies vs TV Shows

SELECT type,COUNT(type)
FROM netflix
GROUP BY 1

-- Find the Most Common Rating for Movies and TV Shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

-- List All Movies Released in a Specific Year (e.g., 2020)

SELECT * FROM 
netflix
WHERE type = 'Movie' AND release_year = '2020' 

-- Find the Top 5 Countries with the Most Content on Netflix


SELECT country,COUNT(*) AS Total_Content
FROM netflix
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- Identify the Longest Movie

SELECT type,duration 
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY 2 DESC

-- Find Content Added in the Last 5 Years

SELECT * 
FROM netflix
WHERE cast(date_added AS DATE) >= CURRENT_DATE - interval '5 years'

-- Find All Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT * 
FROM netflix 
WHERE director = 'Rajiv Chilaka'


-- List All TV Shows with More Than 5 Seasons

SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;


-- Count the Number of Content Items in Each Genre

SELECT 
UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,
COUNT(*) AS No_of_Contents
FROM netflix
GROUP BY 1
ORDER BY 2 DESC


-- Find each year and the average numbers of content release in India on netflix.

SELECT 
EXTRACT(YEAR FROM CAST(date_added AS DATE )) as year,
COUNT(*) as content_released 
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY 1
ORDER BY 1 

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric / (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

-- List All Movies that are Documentaries

SELECT * FROM 
netflix
WHERE listed_in ILIKE '%Documentaries%' -- ILIKE handles both upper and lower case 


SELECT * FROM netflix
WHERE listed_in = 'Documentaries';  -- If you only want the rows with Documentaries


-- Find All Content Without a Director

SELECT * FROM
netflix
WHERE director IS NULL 


-- Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years 

SELECT * FROM netflix
WHERE casts ILIKE '%Salman Khan%' 
AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10


-- Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT 

RANK() OVER(ORDER BY COUNT(*) DESC) AS RANK ,
ACTORS,
COUNT(*) AS Appeared

FROM (
SELECT
UNNEST(STRING_TO_ARRAY(casts,',')) AS ACTORS
FROM netflix) SUBQUERY

GROUP BY ACTORS
ORDER BY 3 DESC
LIMIT 10


-- Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

WITH new_table AS
(
SELECT *,
CASE 
WHEN 
    description ILIKE '%kill%' 
	OR
	description ILIKE '%voilence%' THEN 'BAD CONTENT'
ELSE
    'GOOD CONTENT'
END category
FROM netflix
)
SELECT category,COUNT(*)
FROM new_table
GROUP BY 1
	






























