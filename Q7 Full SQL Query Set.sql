
--9.1::Find the total number of movies, total number of planets, total number of people in the database. Use one query.

SELECT
    (SELECT COUNT(*) FROM films) AS total_movies,
    (SELECT COUNT(*) FROM planets) AS total_planets,
    (SELECT COUNT(*) FROM people) AS total_people;


-- For 9.2 & 9.3 You will need to insert a dummy data to make sure it will fetch.

-- DUMMY DATA
INSERT INTO keywords (movie_id, keyword) VALUES
(1, 'Jedi'),
(1, 'Lightsaber'),
(2, 'Jedi'),
(2, 'Empire'),
(3, 'Death Star'),
(3, 'Jedi'),
(3, 'Empire'),
(4, 'Sith'),
(5, 'Clone');

--9.2::Find top 3 movies with highest number of keywords.
SELECT f.title, COUNT(k.keyword) AS keyword_count
FROM keywords k
JOIN films f ON k.movie_id = f.film_id
GROUP BY f.title
ORDER BY keyword_count DESC
LIMIT 3;


--9.3::Find popular keyword(s) and movies associated with them.

WITH keyword_counts AS (
    SELECT keyword, COUNT(*) AS usage_count
    FROM keywords
    GROUP BY keyword
),
max_count AS (
    SELECT MAX(usage_count) AS max_val FROM keyword_counts
)
SELECT k.keyword, f.title
FROM keywords k
JOIN films f ON k.movie_id = f.film_id
JOIN keyword_counts kc ON k.keyword = kc.keyword
JOIN max_count mc ON kc.usage_count = mc.max_val;

--9.4::Find top ranked movies for each rating provider.
WITH ranked AS (
    SELECT
        r.movie_title,
        r.provider_id,
        r.rating,
        rp.source,
        RANK() OVER (PARTITION BY r.provider_id ORDER BY
            CASE
                WHEN r.rating ~ '^\d+(\.\d+)?$' THEN r.rating::FLOAT
                WHEN r.rating ~ '^\d+/\d+$' THEN SPLIT_PART(r.rating, '/', 1)::FLOAT / SPLIT_PART(r.rating, '/', 2)::FLOAT
                ELSE NULL
            END DESC
        ) AS rank
    FROM ratings r
    JOIN rating_providers rp ON r.provider_id = rp.id
)
SELECT source, movie_title, rating
FROM ranked
WHERE rank = 1;

--9.5::Write a batch-update query that rounds up all the ratings.

UPDATE ratings
SET rating = CASE
    WHEN rating ~ '^\d+(\.\d+)?$' THEN CEIL(rating::FLOAT)::TEXT
    WHEN rating ~ '^\d+/\d+$' THEN CEIL(
        SPLIT_PART(rating, '/', 1)::FLOAT /
        SPLIT_PART(rating, '/', 2)::FLOAT * 10
    )::TEXT || '/10'
    ELSE rating
END;
