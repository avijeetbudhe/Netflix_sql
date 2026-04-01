-- netflix project yt

drop table if exists Netflix;
create table Netflix
(
	show_id varchar(10), 
	type	varchar(15),
	title	varchar(150),
	director varchar(250),	
	casts	varchar(1000),
	country	varchar(150),
	date_added	varchar(25),
	release_year int,
	rating	varchar(25),
	duration varchar(25),	
	listed_in varchar(100),
	description varchar(300)
);

select * from Netflix;



-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

	select type as total_types from Netflix;
	
	select type, count(*) as total_content
	from Netflix
	group by type;



-- 2. Find the most common rating for movies and TV shows

	select type, rating from netflix;

	select type, rating, count(*)
	from Netflix
	group by type, rating 
	order by 1, 3 desc;

	--OR use rank to filter out more logistically
	
	select 
		type, 
		rating, 
		count(*), 
		rank () over(partition by type order by count(*) desc) as ranking
	from Netflix
	group by type, rating ;
	--order by 1, 3 desc;

	-- OR make a subquery for better undersatnding

select 
	type,
	rating,
	ranking
from
(	select 
		type, 
		rating, 
		count(*), 
		rank () over(partition by type order by count(*) desc) as ranking
	from Netflix
	group by type, rating
	--order by 1, 3 desc;
) as t1
where ranking = 1;
	
	


-- 3. List all movies released in a specific year (e.g., 2020)

	select * from Netflix;

	select type, title, release_year
	from netflix
	where type = 'Movie' AND release_year = 2020;



-- 4. Find the top 5 countries with the most content on Netflix

	select * from Netflix;

	select country, count(show_id) as total_content
	from Netflix
	group by country;

-- problem with above code is that it will return combinations of country present in db and not individual country names

	select
		UNNEST (string_to_array(country,',')) as new_country,  -- unnest makes the conjugated countries into distinct 
		count(show_id) as total_contents                       -- string to array converts each string of countries into array(shown in inverted commas) but ae still in conjugated forms 
	from Netflix
	group by 1
	order by 2 DESC
	limit 5;




--5. Identify the longest movie

	select * from Netflix

SELECT 
    title,
    CAST(REPLACE(duration, 'min',' ') AS INTEGER) AS duration_minutes
FROM 
    Netflix
WHERE 
    type = 'Movie' AND duration IS NOT NULL
ORDER BY 
    duration_minutes DESC
LIMIT 1;


-- Problem: duration is stored as text, not a number
-- Solution: REPLACE(duration, 'min',' ') → removes ' min' → becomes '90'
			--CAST(... AS INTEGER) → converts '90' → 90
			--Final result: numeric duration stored as duration_minutes
-- Limit is used to show the first value only and not the rest




--6. Find content added in the last 5 years

	select * from netflix

-- use direct conversion of varchar into date format as date is in varchar using TO_DATE func and filtering using current_date - interval segment

	select * from netflix
	where 
		to_date(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years' ;




--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

	select * from netflix


	select 
		title,
	    type,
	    director
	from netflix
	where director ILIKE '%Rajiv Chilaka%'
	

--OR      = ANY(...) Checks if 'Rajiv Chilaka' exists in that array

	SELECT 
	    title,
	    type,
	    director
	FROM netflix
	WHERE 
	    director IS NOT NULL
	    AND 'Rajiv Chilaka' = ANY(string_to_array(director, ','));	
			



--8. List all TV shows with more than 5 seasons

	select * from netflix


	SELECT 
	    title,
	    CAST(REPLACE(REPLACE(duration, ' Seasons', ''), ' Season', '') AS INTEGER) AS seasons
	FROM 
	    Netflix
	WHERE 
	    type = 'TV Show' 
		AND duration IS NOT NULL
		AND CAST(REPLACE(REPLACE(duration, ' Seasons', ''), ' Season', '') AS INTEGER) > 5; 

-- OR easy way 

	SELECT * FROM Netflix
	WHERE 
	    type = 'TV Show' 
		AND duration IS NOT NULL
		AND split_part(duration,' ',1)::numeric >5 ;   -- 1 is used for first part of word i.e. 5 in 5 seasons
	



--9. Count the number of content items in each genre

	select * from netflix

	select                                    -- group by is necessary with unnest
		count(show_id) as total_contents,
		unnest(string_to_array(listed_in, ',')) as genre
	from netflix
	group by 2
	order by 1 ASC;


--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

select * from netflix

	select 
		extract(year from to_date(date_added, 'Month DD, YYYY')) as date,
		count(*) as content,
--avg		count(*):: numeric/(select count(*) from netflix where country = 'India')*100:: numeric as avg_content
	from netflix
	where country = 'India'
	group by 1
	order by 1;
	

--11. List all movies that are documentaries

	select * from netflix
	where
		type = 'Movie'
		AND
		listed_in ILIKE '%Documentaries%' ;




--12. Find all content without a director

	select * from netflix
	where director IS NULL;



--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

	select * from netflix
	where 
		casts ILIKE '%Salman Khan%'
		AND 
		release_year >= extract(year from CURRENT_DATE) - 10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

	select 
		--show_id,
		--casts,
		unnest(string_to_array(casts, ',')) as true_casts,
		count(*) as total_movies
	from netflix
	where country ILIKE '%India%'
	group by 1
	order by 2 DESC
	limit 10;




--15.
--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

	WITH new_table
	AS
	(
		select *, 
				CASE
					WHEN description ILIKE '%kill%' OR description ILIKE '%violence%'
					THEN 'Bad Content'
					ELSE 'Good Content'
				END category    -- name of new column
		from netflix
	)
	SELECT category, count(*)
	FROM new_table
	group by 1;



