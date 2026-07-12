--SQL Project: Netflix Dataset

CREATE TABLE netflix 
(
	show_id VARCHAR(6),
	type1	VARCHAR(10),
	title	VARCHAR(150),
	director	VARCHAR(250),
	cast1	VARCHAR(800),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year INT,
	rating	VARCHAR(10),
	duration	VARCHAR(15),
	listed_in	VARCHAR(80),
	description VARCHAR(300)
);

SELECT  count (*) as total_count
FROM netflix;

SELECT DISTINCT type1 FROM netflix;

-- Problems
-- 1. Count the number of Movies vs TV Shows
SELECT type1, COUNT(*) as total_content
FROM netflix
GROUP BY type1

-- 2. Find the most common rating for movies and TV shows
SELECT 
type1,
rating 
FROM
(
	SELECT 
		type1, 
		rating, 
		COUNT(*),
		RANK() OVER(PARTITION BY type1 ORDER BY COUNT(*) DESC) as ranking
		FROM netflix
	GROUP BY 1,2
) AS ranking_col
WHERE ranking = 1

-- 3. List all movies released in a specific year

SELECT * FROM netflix
WHERE type1 = 'Movie' AND release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix

SELECT
    TRIM(country_name) AS new_country,
    COUNT(*) AS total_content
FROM netflix,
LATERAL UNNEST(STRING_TO_ARRAY(country, ',')) AS country_name
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT * FROM netflix
WHERE type1 = 'Movie'
AND
duration = (SELECT MAX(duration) FROM netflix)

-- 6. Find content added in the last 5 years

SELECT *,
TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'
FROM netflix
WHERE date_added

-- 7. First all the movies/TVshows by director 'Olivier Megaton'

SELECT * FROM netflix
WHERE director ILIKE '%Olivier Megaton%'

-- 8. List all TV shows with more than 5 seasons

SELECT 
*
FROM netflix
WHERE type1 = 'TV Show' AND SPLIT_PART(duration, ' ',1)::numeric > 5

-- 9. Count the number of content Items in each genre

SELECT 
UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
COUNT(show_id) as total_content
FROM netflix
GROUP BY 1

-- 10.Find each year, the average number of content released in India on netflix. Return top 5 year with highet average content release.

SELECT
EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
 COUNT(*) as yearly_content,
 ROUND (COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100, 2) as avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1

-- 11. List all the movies that are documentries

SELECT * FROM netflix
WHERE listed_in ILIKE '%documentaries%'

-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL

-- 13. Find in how many movies, 'Salman Khan' appeared in the last 10 years

SELECT * FROM netflix
WHERE cast1 ILIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India
SELECT 
UNNEST(STRING_TO_ARRAY(cast1, ',')) AS actors,
COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%india'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- 15 Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
WITH new_table
AS
(
SELECT *,
CASE
WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad_Content'
ELSE 'Good_Content'
END category
FROM netflix
)
SELECT 
category,
COUNT(*) as total_content
FROM new_table
GROUP BY 1

-- 16. Find the Top 3 Directors with the Highest Number of Movies

SELECT
UNNEST(STRING_TO_ARRAY(director, ', ')) AS directors_new,
COUNT(*) as total_content
FROM netflix
WHERE type1 = 'Movie'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3

-- 17. Find the Most Common Genre for Each Content Type

SELECT 
type1, 
TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ', '))) AS genre,
COUNT(*) AS total_content
FROM netflix
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

-- 18. Find Directors Who Have Directed Both Movies and TV Shows
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) AS director
FROM netflix
WHERE director IS NOT NULL
GROUP BY 1
HAVING COUNT(DISTINCT type1) = 2;

-- 19. Find the Top 5 Years with the Highest Number of Movies Released

SELECT 
type1,
release_year,
COUNT(*) AS total_content
FROM netflix
WHERE type1 ='Movie'
GROUP BY 1, 2
ORDER BY 2 DESC
LIMIT 5

-- 20. Find the Longest Movie for Each Rating

SELECT
    title,
    rating,
    duration,
    SPLIT_PART(duration, ' ', 1)::INT AS minutes
FROM netflix
WHERE type1 = 'Movie'
AND duration IS NOT NULL;

