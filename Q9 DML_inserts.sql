

-- Films
INSERT INTO films (film_id, title, episode_id, opening_crawl, director, producer, release_date, url)
VALUES 
    (1, 'A New Hope', 4, 'It is a period of civil war...', 'George Lucas', 'Gary Kurtz', '1977-05-25', 'https://swapi.dev/api/films/1/'),
    (2, 'The Empire Strikes Back', 5, 'It is a dark time for the Rebellion...', 'Irvin Kershner', 'Gary Kurtz', '1980-05-17', 'https://swapi.dev/api/films/2/')
ON CONFLICT (film_id) DO NOTHING;

-- Planets
INSERT INTO planets (planet_id, name, rotation_period, orbital_period, diameter, climate, gravity, terrain, surface_water, population, url)
VALUES 
    (1, 'Tatooine', 23, 304, 10465, 'arid', '1 standard', 'desert', '1', 200000, 'https://swapi.dev/api/planets/1/')
ON CONFLICT (planet_id) DO NOTHING;

-- People
INSERT INTO people (person_id, name, height, mass, hair_color, skin_color, eye_color, birth_year, gender, homeworld, url)
VALUES 
    (1, 'Luke Skywalker', '172', '77', 'blond', 'fair', 'blue', '19BBY', 'male', 'https://swapi.dev/api/planets/1/', 'https://swapi.dev/api/people/1/')
ON CONFLICT (person_id) DO NOTHING;

-- OMDB Ratings
INSERT INTO omdb_ratings (imdb_id, title, year, source, rating, url) 
VALUES ('tt0076759', 'A New Hope', 1977, 'Internet Movie Database', '8.6/10', 'https://www.imdb.com/title/tt0076759/')
ON CONFLICT ON CONSTRAINT unique_rating DO NOTHING;


-- Rating Providers
INSERT INTO rating_providers (id, source)
VALUES 
    (1, 'Internet Movie Database'),
    (2, 'Rotten Tomatoes')
ON CONFLICT (id) DO NOTHING;

-- Ratings
INSERT INTO ratings (imdb_id, provider_id, rating, movie_title, year)
VALUES 
('tt0076759', 1, '8.6/10', 'A New Hope', 1977),
('tt0076759', 2, '93%', 'A New Hope', 1977)
ON CONFLICT ON CONSTRAINT unique_rating_per_provider DO NOTHING;

-- Keywords
INSERT INTO keywords (id, movie_id, keyword)
VALUES 
    (1, 1, 'Jedi'),
    (2, 1, 'Lightsaber'),
    (3, 2, 'Jedi'),
    (4, 2, 'Empire'),
    (5, 3, 'Death Star'),
    (6, 3, 'Jedi'),
    (7, 3, 'Empire'),
    (8, 4, 'Sith'),
    (9, 5, 'Clone')
ON CONFLICT ON CONSTRAINT unique_keyword_per_movie DO NOTHING;
